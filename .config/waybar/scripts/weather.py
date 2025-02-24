#!/usr/bin/env python3

# OG SCRIPT SOURCE: https://git.tjdev.de/thetek/waybar-weather

import datetime
import json
import requests
import statistics
import sys
import os

# TODO
# - snowfall data
# - weather warnings

### CONSTANTS ###
env_path = os.path.expanduser('~/.env')

def load_env_file(path):
    with open(path) as f:
        for line in f:
            # Ignore comments and empty lines
            if line.strip() and not line.startswith("#"):
                key, value = line.strip().split("=", 1)
                os.environ[key] = value

# Load environment variables from the specified .env file
load_env_file(env_path)

# api key - get it at https://openweathermap.org/
API_KEY = os.getenv("OPENWEATHER_API_KEY")


# latitude and longitude of the city you want to query
# can be obtained through `./weather.py geocoding <city[,state,country]>`
LATITUDE  = os.getenv("OPENWEATHER_LAT")
LONGITUDE = os.getenv("OPENWEATHER_LONG")

# waybar colors
GRAY   = '#d9d9d9'
DARK   = '#5a6772'
GREEN  = '#d8c5fa'
YELLOW = '#c4bed1'
ORANGE = '#e69875'
RED    = '#e67e80'
PURPLE = '#d699b6'
BLUE   = '#7fbbb3'


### UTILITIES ###

def print_error(msg: str):
    '''
    print an error message with appropriate prefix.

    @param str: the message to print
    '''
    print('\x1b[90m[\x1b[31merr\x1b[90m]\x1b[0m', msg)


def print_help():
    '''
    print help message, to be used for the `--help` flag and as response to
    incorrect usage
    '''
    print('usage: \x1b[33m./weather.py <subcommand> [options]\x1b[0m')
    print()
    print('available subcommands:')
    print(' - \x1b[32mgeocoding\x1b[0m <city[,state][,country]> : search for city to get its coordinates')
    print(' - \x1b[32mcurrent\x1b[0m                            : print current weather information')
    print(' - \x1b[32mforecast[-daily]\x1b[0m                   : print forecast for the next ~5 days')
    print(' - \x1b[32mforecast-detail\x1b[0m                    : print detailed forecast in 3h intervals')
    print(' - \x1b[32mwaybar\x1b[0m                             : get output for usage with waybar')


def make_request(call: str) -> list | dict:
    '''
    make a request to an openweathermap api and returns the response as either
    a list or a dictionary. the api key is added automatically. quits on error.

    @param call: the api path, e.g. `data/2.5/weather?...`

    @return response of the api request as a list or dict
    '''
    try:
        req = requests.get(f'https://api.openweathermap.org/{call}&appid={API_KEY}')
        return req.json()
    except:
        print_error(f'failed to make request to `/{call}`')
        quit(1)


def get_wind_direction(deg: int) -> str:
    '''
    turn a wind direction specified by meteorological degrees into a
    human-readable form

    @param deg: degrees. expected to be in range [0..360]

    @return human-readable form (e.g. 'NE' for `deg == 45`)
    '''
    if deg < 22.5:  return 'N'
    if deg < 67.5:  return 'NE'
    if deg < 112.5: return 'E'
    if deg < 157.5: return 'SE'
    if deg < 202.5: return 'S'
    if deg < 247.5: return 'SW'
    if deg < 292.5: return 'W'
    if deg < 337.5: return 'NW'
    else:           return 'N'


def print_entry(label: str, content: str, indent: int = 0, label_width: int = 8):
    '''
    print an 'entry' that consists of a label (printed in gray) and some
    content. the labels are automatically filled with whitespace to align
    multiple lines properly.

    @param label:       the label of the line
    @param content:     content, printed after the label
    @param indent:      number of spaces to indent with
    @param label_width: width of label
    '''
    label_with_whitespace = label.ljust(label_width)
    print(f'{" " * indent}\x1b[90m{label_with_whitespace}\x1b[0m  {content}')


def get_weekday(date: str) -> str:
    '''
    get weekday from date

    @param date: date as ISO-8601-formatted string (YYYY-mm-dd)

    @return weekday as lowercase string (e.g. 'monday')
    '''
    return datetime.datetime.strptime(date, '%Y-%m-%d').strftime('%A').lower()


def colorize(text: str, color: str) -> str:
    '''
    wrap `text` with pango markup to colorize it for usage with waybar.

    @param text: the text to colorize
    @param color: the color as string ('#rrggbb')
    '''
    return f'<span foreground="{color}">{text}</span>'


def waybar_entry(label: str, content: str, indent: int = 2, label_width: int = 9):
    '''
    create an 'entry' for a waybar tooltip that consists of a label (printed in
    gray) and some content. the labels are automatically filled with whitespace
    to align multiple lines properly.

    @param label:       the label of the line
    @param content:     content, printed after the label
    @param indent:      number of spaces to indent with
    @param label_width: width of label

    @return the entry for use within waybar
    '''

    label_with_whitespace = label.ljust(label_width)
    return f'{" " * indent}{colorize(label_with_whitespace, GRAY)}  {content}\n'



### GEOCODING ###

def geocoding(search: str):
    '''
    call openweathermap's geocoding api to find the coordinates of cities. can
    be used to find the values required for the `LATITUDE` and `LONGITUDE`
    constants within this script. the results are printed.

    @param: search term in the format 'city[,state][,country]'
    '''

    res = make_request(f'geo/1.0/direct?q={search}&limit=5')
    num_results = len(res)

    if (num_results == 0):
        print_error('no results found')
    else:
        print(f'found {num_results} result{"" if num_results == 1 else "s"}:')
        for entry in res:
            # obtain data
            name      = entry['name']
            state     = entry['state'] if 'state' in entry.keys() else None
            country   = entry['country']
            latitude  = entry['lat']
            longitude = entry['lon']

            # print data
            print(f' - \x1b[32m{name}\x1b[90m',
                  f'({f"{state}, " if state else ""}{country})\x1b[0m:',
                  f'latitude = \x1b[35m{latitude}\x1b[0m,',
                  f'longitude = \x1b[35m{longitude}\x1b[0m')


### CURRENT WEATHER ###

def get_current_weather_data() -> dict:
    '''
    get current weather data from openweathermap api. when the `rain` is not
    set (due to there not being any rain), it will be added with a rain amount
    of 0 mm over the last hour.

    @return api response
    '''

    res = make_request(f'data/2.5/weather?lat={LATITUDE}&lon={LONGITUDE}&units=metric')

    if 'rain' not in res.keys():
        res['rain'] = { '1h': 0 }

    return res


def current_weather():
    '''
    print current weather information
    '''

    data = get_current_weather_data()

    # collect relevant data
    weather          = data['weather'][0]['description'].lower()
    temperature      = round(data['main']['temp'], 1)
    temperature_felt = round(data['main']['feels_like'], 1)
    humidity         = data['main']['humidity']
    wind_speed       = round(data['wind']['speed'], 1)
    wind_direction   = get_wind_direction(data['wind']['deg'])
    rainfall         = data['rain']['1h']

    # print data
    print_entry('weather',  f'\x1b[32m{weather}\x1b[0m')
    print_entry('temp',     f'\x1b[33m{temperature} °C\x1b[90m, feels like \x1b[33m{temperature_felt} °C\x1b[0m')
    print_entry('humidity', f'\x1b[31m{humidity} % RH\x1b[0m')
    print_entry('wind',     f'\x1b[35m{wind_speed} m/s\x1b[90m ({wind_direction})\x1b[0m')
    print_entry('rain',     f'\x1b[34m{rainfall} mm\x1b[0m')



### FORECAST ###

def get_forecast_data() -> dict:
    '''
    get forecast data for the next ~5 days from the openweathermap api, with
    data points separated by 3 hours. the data is grouped by date (the api does
    not group the data by default and instead sends it as one sequence).

    @return api response grouped by date
    '''

    res = make_request(f'data/2.5/forecast?lat={LATITUDE}&lon={LONGITUDE}&units=metric')

    days = dict()
    for i in res['list']:
        day = i['dt_txt'].split(' ')[0]
        if day not in days.keys():
            days[day] = list()
        if 'rain' not in i.keys():
            i['rain'] = { '3h': 0 }
        days[day].append(i)

    return days


def get_daily_forecast_data() -> dict[dict]:
    '''
    obtain forecast data for the next ~5 days, where values are grouped by day.
    since the api only provides the data in 3h intervals, the properties of
    different data points are combined in order to provide appropriate data for
    each day.

    @return the processed data as a dict with key = date and value = data as
            another dict
    '''

    res = get_forecast_data()

    output = dict()

    for day in sorted(res):
        data = res[day]
        number_of_data_points = len(data)

        # collect relevant from data for each day
        temperatures         = [i['main']['temp'] for i in data]
        weather_descriptions = [i['weather'][0]['description'].lower() for i in data]
        humidity             = [i['main']['humidity'] for i in data]
        rainfall             = [i['rain']['3h'] for i in data]
        precipitation_prob   = [i['pop'] for i in data]
        wind_speeds          = [i['wind']['speed'] for i in data]
        weekday              = get_weekday(day)

        # min and max temperature for the day
        min_temperature = round(min(temperatures))
        max_temperature = round(max(temperatures))

        # obtain the average weather by finding the weather description with the highest number of occurances in `weather_descriptions`
        weather_count     = {i: weather_descriptions.count(i) for i in set(weather_descriptions)}
        weather_count_max = max(weather_count.values())
        weather_average   = tuple(filter(lambda x: weather_count[x] == weather_count_max, weather_count.keys()))[0]

        # humidiy
        humidity_average = round(statistics.mean(humidity))

        # total rainfall and probability of precipitation. also, estimate the total rainfall if not all data points for a day are available
        rainfall_total           = round(sum(rainfall), 1)
        rainfall_total_estimated = round(rainfall_total / number_of_data_points * 8, 1)
        max_precipitation_prob   = round(max(precipitation_prob) * 100)

        # average wind
        wind_average = round(statistics.mean(wind_speeds), 1)

        output[day] = {
            'number_of_data_points': number_of_data_points,
            'min_temperature': min_temperature,
            'max_temperature': max_temperature,
            'weather_average': weather_average,
            'humidity_average': humidity_average,
            'rainfall_total': rainfall_total,
            'rainfall_total_estimated': rainfall_total_estimated,
            'max_precipitation_prob': max_precipitation_prob,
            'wind_average': wind_average,
            'weekday': weekday,
        }

    return output


def daily_forecast():
    '''
    print forecast data for the next ~5 days
    '''

    daily_data = get_daily_forecast_data()

    for day in sorted(daily_data):
        data = daily_data[day]

        # only display data point if at least half of the data points are available
        if data['number_of_data_points'] < 4:
            continue

        # print data
        print(f'\x1b[1m{day}\x1b[0m ({data["weekday"]}):')
        print_entry('weather',  f'\x1b[32m{data["weather_average"]}\x1b[0m', indent = 2)
        print_entry('temp',     f'\x1b[33m{data["max_temperature"]} °C\x1b[0m / \x1b[33m{data["min_temperature"]} °C\x1b[0m', indent = 2)
        print_entry('humidity', f'\x1b[31m{data["humidity_average"]} % RH\x1b[0m', indent = 2)
        print_entry('wind',     f'\x1b[35m{data["wind_average"]} m/s\x1b[0m', indent = 2)
        print_entry('rain',     f'\x1b[34m{data["rainfall_total_estimated"]} mm\x1b[0m' +
                                f'\x1b[90m{f""" ({data["max_precipitation_prob"]}%)""" if data["max_precipitation_prob"] > 0 else ""}' +
                                f'{f" (estimated)" if data["rainfall_total"] != data["rainfall_total_estimated"] else ""}\x1b[0m\n', indent = 2)



### DETAILED FORECAST ###

def detailed_forecast():
    '''
    print forecast data for the next ~5 days, where values are printed for
    every 3h interval provided by the api. some data (e.g. humidity or wind
    speeds) are omitted.
    '''

    res = get_forecast_data()

    for day in sorted(res):
        weekday = get_weekday(day)
        print(f'\x1b[1m{day}\x1b[0m ({weekday})')

        for entry in res[day]:
            # collect data
            weather            = entry['weather'][0]['description'].lower()
            temperature        = round(entry['main']['temp'], 1)
            rainfall           = entry['rain']['3h']
            precipitation_prob = round(entry['pop'] * 100)
            time               = f"{int(entry['dt_txt'].split(' ')[1].split(':')[0]):2}h"

            # print data
            output = ''
            output += f'\x1b[33m{temperature:4} °C\x1b[90m, '
            output += f'\x1b[32m{weather}\x1b[0m'
            if rainfall > 0:
                output += f'\x1b[90m: \x1b[34m{rainfall} mm \x1b[90m({precipitation_prob}%)\x1b[0m'
            print_entry(time, output, indent = 2, label_width = 3)

        print()



### WAYBAR ###

def waybar_widget(data: dict) -> str:
    '''
    get the widget component of the waybar output. contains the current weather
    group and temperature.

    @param current weather data

    @return widget component
    '''

    weather = data['weather'][0]['main'].lower()
    temperature = round(data['main']['temp'])

    weather_icons = {
        'clear': '☀️',                 # Clear sky
        'clouds': '☁️',                # Cloudy
        'rain': '🌧️',                  # Rain
        'drizzle': '🌦️',               # Drizzle
        'thunderstorm': '⚡',           # Thunderstorm
        'snow': '❄️',                  # Snow
        'atmosphere': '🌫️',            # Fog/mist
        'haze': '🌫️',                  # Haze
        'mist': '🌫️',                  # Mist
        'smoke': '🌫️',                 # Smoke
        'sand': '🏜️',                  # Sand
        'dust': '🌪️',                  # Dust
        'volcanic': '🌋',               # Volcanic ash
        'squall': '🌬️',                # Squall
        'tornado': '🌪️',               # Tornado
    }

    icon = weather_icons.get(weather, '🌍')  # Default icon for unknown conditions

    return f'{icon}  {temperature}°'


def waybar_current(data: dict) -> str:
    '''
    get the current weather overview for the tooltip of the waybar output.

    @param current weather data

    @return formatted current weather overview
    '''

    # retrieve relevant data
    weather          = data['weather'][0]['description'].lower()
    temperature      = round(data['main']['temp'], 1)
    temperature_felt = round(data['main']['feels_like'], 1)
    humidity         = data['main']['humidity']
    wind_speed       = round(data['wind']['speed'], 1)
    wind_direction   = get_wind_direction(data['wind']['deg'])
    rainfall         = data['rain']['1h']

    # generate output
    output = ''
    output += waybar_entry('weather',  colorize(weather, YELLOW))
    output += waybar_entry('temp',     f'{colorize(f"{temperature} °C", ORANGE)}{colorize(", feels like ", GRAY)}{colorize(f"{temperature_felt} °C", ORANGE)}')
    output += waybar_entry('humidity', colorize(f'{humidity} % RH', RED))
    output += waybar_entry('wind',     f'{colorize(f"{wind_speed} m/s", PURPLE)} {colorize(f"({wind_direction})", GRAY)}')
    output += waybar_entry('rain',     colorize(f"{rainfall} mm", BLUE))
    return output


def waybar_forecast(data: dict) -> str:
    '''
    get the daily forecast for the tooltip of the waybar output.

    @param forecast weather data

    @return formatted daily forecast
    '''

    output = ''

    daily_data = get_daily_forecast_data()

    for day in sorted(daily_data):
        data = daily_data[day]

        line_content = colorize(f'{data["max_temperature"]:2}°', ORANGE) + \
                       colorize(' / ', GRAY) + \
                       colorize(f'{data["min_temperature"]:2}°', ORANGE) + \
                       colorize(', ', GRAY) + \
                       colorize(data['weather_average'], YELLOW)

        if data['rainfall_total_estimated'] > 0:
            line_content += colorize(': ', GRAY) + \
                            colorize(f'{data["rainfall_total_estimated"]} mm ', BLUE) + \
                            colorize(f'({data["max_precipitation_prob"]}%)', GRAY)

        output += waybar_entry(data['weekday'], line_content)

    return output.rstrip()


def waybar():
    '''
    get current and forecast weather data and output it formatted in a way that
    allows it to be included as a widget in waybar. only shows weather category
    and temperature in the widget, but reveals detailed weather information and
    a ~5 day forecast in the tooltip.
    '''

    current_data = get_current_weather_data()
    forecast_data = get_forecast_data()

    widget = waybar_widget(current_data)
    current = waybar_current(current_data)
    forecast = waybar_forecast(forecast_data)
    tooltip = colorize('<span font_size="large">current weather</span>', GREEN) + '\n' + current + '\n' + \
              colorize('<span font_size="large">forecast</span>', GREEN) + '\n' + forecast

    print(json.dumps({
        'text': widget,
        'tooltip': tooltip,
    }))



### MAIN ###

def main():
    '''
    main function
    '''

    # no parameters or `--help`
    if len(sys.argv) == 1 or sys.argv[1] in ('help', '-h', '--help'):
        print_help()

    # >= 1 parameter provided
    else:
        # geocoding
        if sys.argv[1] == 'geocoding':
            if len(sys.argv) == 3:
                geocoding(sys.argv[2])
            else:
                print_error('expected argument `<city[,state][,country]>`')
                print_help()
        # constants not set
        elif API_KEY is None or LATITUDE is None or LONGITUDE is None:
            print_error('please modify the constants within the script before use.')
        # current weather
        elif sys.argv[1] == 'current':
            current_weather()
        # daily forecast
        elif sys.argv[1] == 'forecast' or sys.argv[1] == 'forecast-daily':
            daily_forecast()
        # detailed forecast
        elif sys.argv[1] == 'forecast-detail':
            detailed_forecast()
        # waybar
        elif sys.argv[1] == 'waybar':
            waybar()
        # unknown command
        else:
            print_error(f'unknown command `{sys.argv[1]}`')
            print_help()

if __name__ == '__main__':
    main()

