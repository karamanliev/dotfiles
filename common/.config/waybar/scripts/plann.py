#!/usr/bin/env python3
# Author: Chmouel Boudjnah <chmouel@chmouel.com>
# Modified for plann/CalDAV support
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

import argparse
import datetime
import hashlib
import html
import json
import os
import os.path
import pathlib
import re
import shutil
import subprocess
import sys
import typing

from collections import defaultdict
import dateutil.parser as dtparse
import dateutil.relativedelta as dtrel

# Regex to parse plann output
# Format: "start:2025-12-06 17:00 | end:2025-12-06 18:00 | summary:Event Title | loc:Location"
REG_PLANN = re.compile(
    r"start:(?P<start_datetime>\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2})\s*\|\s*end:(?P<end_datetime>\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2})\s*\|\s*summary:(?P<title>.*?)\s*\|\s*loc:(?P<location>.*)$"
)

# Regex patterns to extract meeting URLs from location field
MEETING_URL_PATTERNS = [
    re.compile(r'(https://meet\.google\.com/[a-z\-]+)', re.IGNORECASE),
    re.compile(r'(https://[a-z0-9\-]+\.zoom\.us/j/[0-9]+[^\s]*)', re.IGNORECASE),
    re.compile(r'(https://teams\.microsoft\.com/l/meetup-join/[^\s]+)', re.IGNORECASE),
    re.compile(r'(https://teams\.live\.com/meet/[^\s]+)', re.IGNORECASE),
]

TITLE_ELIPSIS_LENGTH = 50
MAX_CACHED_ENTRIES = 30
NOTIFY_MIN_BEFORE_EVENTS = 5
NOTIFY_MIN_COLOR = "#FF5733"  # red
NOTIFY_MIN_COLOR_FOREGROUND = "#F4F1DE"  # white
CACHE_DIR = pathlib.Path(os.path.expanduser("~/.cache/nextmeeting"))
NOTIFY_PROGRAM: str = shutil.which("notify-send") or ""
NOTIFY_ICON = "/usr/share/icons/hicolor/scalable/apps/org.gnome.Calendar.svg"
ALL_DAYS_MEETING_HOURS = 24


def elipsis(string: str, length: int) -> str:
    # remove all html elements first from it
    hstring = re.sub(r"<[^>]*>", "", string)
    if len(hstring) > length:
        return string[: length - 3] + "..."
    return string


def pretty_date(
    deltad: dtrel.relativedelta, date: datetime.datetime, args: argparse.Namespace
) -> str:
    today = datetime.datetime.now()
    s = ""
    if date.day != today.day:
        if deltad.days == 0:
            s = "> tomorrow"
        else:
            s = f"{date.strftime('%a %d')}"
        s += " at %02d:%02d" % (date.hour, date.minute)
    elif deltad.hours != 0:
        s = f"in {deltad.hours}h {deltad.minutes}m"
    else:
        if (
            deltad.minutes <= NOTIFY_MIN_BEFORE_EVENTS
            and args.notify_min_color
            and args.waybar
        ):
            number = f"""<span background="{args.notify_min_color}" color="{args.notify_min_color_foreground}">{deltad.minutes}</span>"""
        else:
            number = f"{deltad.minutes}"

        s = f"in {number}m"
    return s


def extract_meeting_url(location: str) -> str:
    """Extract meeting URL from location field using common patterns"""
    if not location:
        return ""

    for pattern in MEETING_URL_PATTERNS:
        match = pattern.search(location)
        if match:
            return match.group(1)

    return ""


def parse_plann_output(output: str) -> list[dict]:
    """Parse plann output format"""
    ret = []
    for line in output.strip().split('\n'):
        if not line.strip():
            continue

        match = REG_PLANN.match(line)
        if not match:
            continue

        try:
            startdate = dtparse.parse(match.group('start_datetime'))
            enddate = dtparse.parse(match.group('end_datetime'))
            title = match.group('title').strip()
            location = match.group('location').strip() if match.group('location') else ""

            # Extract meeting URL from location
            meet_url = extract_meeting_url(location)

            # Skip past events (check if end date is in the past)
            if enddate < datetime.datetime.now():
                continue

            # Detect all-day events
            # An all-day event starts at 00:00 and either:
            # - ends at 00:00 on a different day, or
            # - spans multiple days
            is_all_day = (
                startdate.hour == 0 and startdate.minute == 0 and
                enddate.hour == 0 and enddate.minute == 0 and
                (enddate.date() != startdate.date())
            )

            ret.append({
                'startdate': startdate,
                'enddate': enddate,
                'title': title,
                'location': location,
                'meet_url': meet_url,
                'is_all_day': is_all_day
            })
        except Exception as e:
            print(f"Error parsing line: {line}, error: {e}", file=sys.stderr)
            continue

    return ret


def plann_output(args: argparse.Namespace) -> list[dict]:
    """Execute plann and parse output"""
    cmd = ['plann']
    now = datetime.datetime.now()
    end = now + datetime.timedelta(days=args.horizon_days)

    # Add config section if provided
    if args.config_section:
        cmd.extend(['--config-section', args.config_section])

    cmd.extend([
        'select', '--event',
        '--start', now.strftime('%Y-%m-%d %H:%M'),
        '--end',   end.strftime('%Y-%m-%d %H:%M'),
        '--sort-key', '{DTSTART}',
        'list',
        '--template=start:{DTSTART:%F %H:%M} | end:{DTEND:%F %H:%M} | summary:{SUMMARY} | loc:{LOCATION}'
    ])

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True
        )
        return parse_plann_output(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error running plann: {e}", file=sys.stderr)
        print(f"STDERR: {e.stderr}", file=sys.stderr)
        return []
    except FileNotFoundError:
        print("Error: plann not found. Please install it first.", file=sys.stderr)
        return []


def ret_events(
    events: list[dict], args: argparse.Namespace, hyperlink: bool = False
) -> typing.Tuple[list[dict], str]:
    ret = []
    cssclass = ""

    for event in events:
        title = event['title']
        full_title = title

        if args.max_title_length > 0:
            title = elipsis(title, args.max_title_length)

        if args.waybar:
            title = html.escape(title)
            full_title = html.escape(full_title)

        startdate = event['startdate']
        enddate = event['enddate']
        is_all_day = event.get('is_all_day', False)

        # Skip all-day meetings if requested
        if args.skip_all_day_meeting and is_all_day:
            continue

        event_info = {
            "title": full_title,
            "display_title": title,
            "startdate": startdate,
            "enddate": enddate,
            "is_all_day": is_all_day,
            "meet_url": event.get('meet_url', ''),
        }

        # For all-day events
        if is_all_day:
            if datetime.datetime.now().date() == startdate.date():
                thetime = "all day"
            else:
                thetime = f"all day {startdate.strftime('%a %d')}"
            event_info["time_str"] = thetime
            event_info["display"] = f"{title} ({thetime})"
        elif datetime.datetime.now() > startdate:
            # Currently ongoing meeting
            cssclass = "current"
            timetofinish = dtrel.relativedelta(enddate, datetime.datetime.now())
            if timetofinish.hours == 0:
                s = f"{timetofinish.minutes}m"
            else:
                s = f"{timetofinish.hours}H{timetofinish.minutes}"
            thetime = f"{s} left"
            event_info["time_str"] = thetime
            event_info["display"] = f"{title} > {thetime}"
        else:
            # Upcoming meeting
            timeuntilstarting = dtrel.relativedelta(
                startdate + datetime.timedelta(minutes=1), datetime.datetime.now()
            )

            if (
                not timeuntilstarting.days
                and not timeuntilstarting.hours
                and timeuntilstarting.minutes <= args.notify_min_before_events
            ):
                cssclass = "soon"
                notify(full_title, startdate, enddate, args)

            thetime = pretty_date(timeuntilstarting, startdate, args)
            event_info["time_str"] = thetime
            event_info["display"] = f"{title} {thetime}"

        ret.append(event_info)

    return ret, cssclass


def notify(
    title: str,
    start_date: datetime.datetime,
    end_date: datetime.datetime,
    args: argparse.Namespace,
):
    t = f"{title}{start_date}{end_date}".encode("utf-8")
    uuid = hashlib.md5(t).hexdigest()
    notified = False
    cached = []
    cache_path = args.cache_dir / "cache.json"
    if cache_path.exists():
        with cache_path.open() as f:
            try:
                cached = json.load(f)
            except json.JSONDecodeError:
                cached = []
            if uuid in cached:
                notified = True
    if notified:
        return
    cached.append(uuid)
    with cache_path.open("w") as f:
        if len(cached) >= MAX_CACHED_ENTRIES:
            cached = cached[-MAX_CACHED_ENTRIES:]
        json.dump(cached, f)
    if NOTIFY_PROGRAM == "":
        return
    other_args = []
    if args.notify_expiry > 0:
        milliseconds = args.notify_expiry * 60 * 1000
        other_args += ["-t", str(milliseconds)]
    elif args.notify_expiry < 0:
        milliseconds = NOTIFY_MIN_BEFORE_EVENTS * 60 * 1000
        other_args += ["-t", str(milliseconds)]
    subprocess.call(
        [
            NOTIFY_PROGRAM,
            "-i",
            os.path.expanduser(args.notify_icon),
            *other_args,
            title,
            f"Start: {start_date.strftime('%H:%M')} End: {end_date.strftime('%H:%M')}",
        ]
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()

    # Plann configuration
    parser.add_argument(
        "--config-section",
        help="Plann config section to use (e.g., 'personal', 'work')",
        default=os.environ.get("PLANN_CONFIG_SECTION"),
    )

    parser.add_argument(
        "--waybar", action="store_true", help="get a json for to display for waybar"
    )

    parser.add_argument(
        "--open-meet-url", action="store_true", help="open the next meeting URL"
    )

    parser.add_argument(
        "--waybar-show-all-day-meeting",
        action="store_true",
        help="show all day meeting in next event for waybar",
    )

    parser.add_argument(
        "--all-day-meeting-hours",
        default=ALL_DAYS_MEETING_HOURS,
        help="how long is an all day meeting in hours, (default: %s)"
        % (ALL_DAYS_MEETING_HOURS),
    )

    parser.add_argument(
        "--notify-expiry",
        type=int,
        help="notification expiration in minutes (0 no expiry, -1 show notification until the meeting start)",
        default=0,
    )

    parser.add_argument("--max-title-length", type=int, default=TITLE_ELIPSIS_LENGTH)
    parser.add_argument(
        "--cache-dir", default=CACHE_DIR.expanduser(), help="cache dir location"
    )

    parser.add_argument(
        "--skip-all-day-meeting", "-S", action="store_true", help="skip all day meeting"
    )

    parser.add_argument(
        "--notify-min-before-events",
        type=int,
        default=NOTIFY_MIN_BEFORE_EVENTS,
        help="How many minutes before to notify the event is coming up",
    )
    parser.add_argument(
        "--notify-min-color",
        default=NOTIFY_MIN_COLOR,
        help="Background color for urgent events",
    )

    parser.add_argument(
        "--notify-min-color-foreground",
        default=NOTIFY_MIN_COLOR_FOREGROUND,
        help="Foreground color for urgent events",
    )

    parser.add_argument(
        "--notify-icon",
        default=NOTIFY_ICON,
        help="Notification icon to use for notify-send",
    )

    parser.add_argument(
        "--horizon-days",
        type=int,
        default=14,
        help="Number of days to show in the horizon",
    )

    g = parser.add_mutually_exclusive_group()
    g.add_argument(
        "--hide-recurring",
        action="store_true",
        help="Hide meetings that appear to repeat (based on duplicates in the query window)",
    )
    g.add_argument(
        "--collapse-recurring",
        action="store_true",
        help="Show only the next occurrence of repeating meetings (based on duplicates in the query window)",
    )

    parser.add_argument(
        "--icon-only",
        action="store_true",
        help="Waybar: show only an icon depending on recurring/non-recurring presence",
    )

    parser.add_argument(
        "--icon-symbol",
        default=" ⏺",
        help="Symbol to show in --icon-only mode",
    )

    parser.add_argument(
        "--icon-new-color",
        default="#bd93f9",
        help="Color for icon when non-recurring events exist in addition to recurring ones",
    )

    return parser.parse_args()


def group_events_by_date(events: list[dict]) -> str:
    """Group events by date in the requested format with styled date headers."""
    if not events:
        return "No events"

    # Group events by date
    grouped_events = defaultdict(list)
    for event in events:
        date_key = event["startdate"].strftime("%a %d")

        # Show "All-day" for all-day events instead of time
        if event.get("is_all_day", False):
            event_time = "All-day"
        else:
            event_time = event["startdate"].strftime("%H:%M")

        # Wrap long titles to new lines (around 40 chars, at word boundaries)
        title = event['title']
        if len(title) > 40:
            wrapped_title = ""
            remaining_text = title
            max_length = 40

            while len(remaining_text) > max_length:
                break_pos = max_length

                # Look for spaces or punctuation marks after max_length
                for i in range(max_length, min(len(remaining_text), max_length + 20)):
                    if remaining_text[i] in " ,.;:-/()[]{}":
                        break_pos = i + 1
                        break

                if break_pos == max_length and len(remaining_text) > max_length + 20:
                    last_space = remaining_text[:max_length].rfind(' ')
                    if last_space > max_length // 2:
                        break_pos = last_space + 1

                wrapped_title += remaining_text[:break_pos] + "\n"
                remaining_text = remaining_text[break_pos:]

            wrapped_title += remaining_text
            wrapped_title = wrapped_title.strip()
        else:
            wrapped_title = title

        grouped_events[date_key].append(f"<span color='#c4bed1'>{event_time}</span> {wrapped_title}")

    # Format the output with styled date headers
    result = []
    for date, events_list in grouped_events.items():
        styled_date = f"<span font_size='12pt' color='#d8c5fa'>{date}</span>"
        result.append(styled_date)
        for event in events_list:
            result.append(f"<span font_size='10pt' line_height='1.3'>{event}</span>")
        result.append("")  # Empty line between date groups

    return "\n".join(result).strip()


def get_next_non_all_day_meeting(
    events: list[dict], all_day_meeting_hours: int
) -> None | dict:
    for event in events:
        start_date = event["startdate"]
        end_date = event["enddate"]
        if end_date > (start_date + datetime.timedelta(hours=all_day_meeting_hours)):
            continue
        return event
    return None


def open_meet_url(events: list[dict], args: argparse.Namespace):
    """Open the meeting URL for the next upcoming event"""
    if not events:
        print("No meeting 🏖️")
        return

    # Get the next non-all-day meeting
    next_event = get_next_non_all_day_meeting(
        events, int(args.all_day_meeting_hours)
    )

    if not next_event:
        # Only all-day meetings or no meetings
        if events and not args.skip_all_day_meeting:
            next_event = events[0]
        else:
            print("No upcoming meetings")
            sys.exit(0)

    # Get the meeting URL for the next event only
    url = next_event.get("meet_url", "")

    if url:
        print(f"Opening meeting URL: {url}")
        subprocess.run(["xdg-open", url], check=False)
        sys.exit(0)

    message = "No meeting URL found for the next event"
    print(message)
    if NOTIFY_PROGRAM:
        subprocess.call(
            [
                NOTIFY_PROGRAM,
                "-i",
                "calendar",
                "Next Meeting",
                message,
            ]
        )
    sys.exit(0)

def recurrence_key(ev: dict) -> tuple:
    """
    A stable signature for "same meeting repeats".
    We intentionally ignore the date and keep only:
    - title
    - location
    - meeting URL (if any)
    - start time of day
    - duration
    - all-day flag
    """
    start = ev["startdate"]
    end = ev["enddate"]
    duration_min = int((end - start).total_seconds() // 60)
    return (
        ev.get("title", "").strip(),
        ev.get("location", "").strip(),
        ev.get("meet_url", "").strip(),
        start.hour,
        start.minute,
        duration_min,
        bool(ev.get("is_all_day", False)),
    )

def apply_recurring_policy(events: list[dict], args: argparse.Namespace) -> list[dict]:
    if not (args.hide_recurring or args.collapse_recurring):
        return events

    # Count how many times each "meeting signature" appears in the window
    counts: dict[tuple, int] = defaultdict(int)
    for ev in events:
        counts[recurrence_key(ev)] += 1

    if args.hide_recurring:
        # Keep only meetings that occur once in the window
        return [ev for ev in events if counts[recurrence_key(ev)] == 1]

    # collapse_recurring: keep only the earliest occurrence for each repeating meeting
    seen: set[tuple] = set()
    collapsed: list[dict] = []
    for ev in sorted(events, key=lambda e: e["startdate"]):
        k = recurrence_key(ev)
        if k in seen:
            continue
        seen.add(k)
        collapsed.append(ev)
    return collapsed

def is_upcoming_today(ev: dict, now: datetime.datetime, all_day_meeting_hours: int) -> bool:
    """
    True if event is relevant for the icon:
    - happens today
    - and is upcoming (start >= now) OR currently ongoing (end > now)
    - all-day events count for the whole day as long as it's today
    """
    start = ev["startdate"]
    end = ev["enddate"]

    if start.date() != now.date():
        return False

    # Treat all-day events as relevant for the whole day
    # Your existing logic considers "all-day" as spanning >= all_day_meeting_hours
    if end > (start + datetime.timedelta(hours=all_day_meeting_hours)):
        return end > now  # still ongoing today

    # Normal events: upcoming or currently ongoing
    return end > now


def upcoming_today_events(events: list[dict], all_day_meeting_hours: int) -> list[dict]:
    now = datetime.datetime.now()
    return [ev for ev in events if is_upcoming_today(ev, now, all_day_meeting_hours)]


def recurring_flags(events: list[dict]) -> tuple[bool, bool]:
    """
    Returns:
      has_recurring: at least one meeting signature appears >1 times in this set
      has_nonrecurring: at least one meeting signature appears exactly once in this set
    """
    if not events:
        return (False, False)

    counts = defaultdict(int)
    for ev in events:
        counts[recurrence_key(ev)] += 1

    has_recurring = any(v > 1 for v in counts.values())
    has_nonrecurring = any(v == 1 for v in counts.values())
    return (has_recurring, has_nonrecurring)


def events_today(events: list[dict]) -> list[dict]:
    today = datetime.datetime.now().date()
    return [
        ev for ev in events
        if ev["startdate"].date() == today
    ]


def recurring_flags(events: list[dict]) -> tuple[bool, bool]:
    """
    Returns:
      has_recurring: at least one meeting signature appears >1 times in the window
      has_nonrecurring: at least one meeting signature appears exactly once in the window
    """
    if not events:
        return (False, False)

    counts = defaultdict(int)
    keys = []
    for ev in events:
        k = recurrence_key(ev)
        keys.append(k)
        counts[k] += 1

    has_recurring = any(counts[k] > 1 for k in counts)
    has_nonrecurring = any(counts[k] == 1 for k in counts)
    return (has_recurring, has_nonrecurring)

def main():
    args = parse_args()
    args.cache_dir.mkdir(parents=True, exist_ok=True)

    # Get events from plann
    raw_events = plann_output(args)

    # Icon logic: ONLY upcoming/ongoing events today (including all-day)
    icon_events = upcoming_today_events(raw_events, int(args.all_day_meeting_hours))
    has_rec, has_nonrec = recurring_flags(icon_events)

    # Display/tooltip logic remains based on all events in horizon
    filtered_events = apply_recurring_policy(raw_events, args)
    events, cssclass = ret_events(filtered_events, args)

    if args.open_meet_url:
        open_meet_url(events, args)
        return

    if args.waybar:

        tooltip = group_events_by_date(events) if events else "No events"

        # ICON-ONLY MODE
        if args.icon_only:
            # No upcoming events today -> show nothing
            if not icon_events:
                ret = {
                    "text": "",
                    "tooltip": tooltip,
                    "tooltip-markup": True,
                }

            # Any non-recurring upcoming event today -> red dot
            elif has_nonrec:
                icon_text = (
                    f'<span foreground="{args.icon_new_color}">'
                    f'{html.escape(args.icon_symbol)}'
                    f'</span>'
                )
                ret = {
                    "text": icon_text,
                    "tooltip": tooltip,
                    "tooltip-markup": True,
                    "markup": True,
                    "class": "has-nonrecurring-today",
                }

            # Otherwise, only recurring upcoming events today -> normal dot
            else:
                gray_color = "#5c6370"   # change this to whatever gray you like

                icon_text = (
                    f'<span foreground="{gray_color}">'
                    f'{html.escape(args.icon_symbol)}'
                    f'</span>'
                )

                ret = {
                    "text": icon_text,
                    "tooltip": tooltip,
                    "tooltip-markup": True,
                    "markup": True,
                    "class": "only-recurring-today",
                }

            json.dump(ret, sys.stdout)
            return

        # DEFAULT MODE (no --icon-only)
        if not events:
            ret = {"text": "No meeting 🏖️"}
            json.dump(ret, sys.stdout)
            return

        coming_up_next = get_next_non_all_day_meeting(
            events, int(args.all_day_meeting_hours)
        )
        if not coming_up_next:
            coming_up_next = events[0]

        ret = {
            "text": coming_up_next["display"],
            "tooltip": tooltip,
            "tooltip-markup": True,
        }

        if cssclass:
            ret["class"] = cssclass

        json.dump(ret, sys.stdout)
        return

    else:
        # Non-waybar output
        print(group_events_by_date(events))


if __name__ == "__main__":
    main()
