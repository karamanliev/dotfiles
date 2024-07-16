const {
  aceVimMap,
  mapkey,
  unmap,
  unmapAllExcept,
  vunmap,
  iunmap,
  imap,
  imapkey,
  getClickableElements,
  vmapkey,
  vmap,
  map,
  cmap,
  addSearchAlias,
  removeSearchAlias,
  tabOpenLink,
  readText,
  Clipboard,
  Front,
  Hints,
  Visual,
  Normal,
  RUNTIME,
} = api;

// -----------------------------------------------------------------------------------------------------------------------
// -- [ SETTINGS ]
// -----------------------------------------------------------------------------------------------------------------------
settings.defaultSearchEngine = "b"; // (b)rave, (n)eeva, etc
settings.focusAfterClosed = "right";
settings.hintAlign = "left";
settings.hintExplicit = true;
settings.hintShiftNonActive = true;
settings.richHintsForKeystroke = 1;
settings.omnibarPosition = "middle";
settings.focusFirstCandidate = true;
settings.scrollStepSize = 90;
settings.tabsThreshold = 0;
settings.modeAfterYank = "Normal";
// settings.historyMUOrder = false;
// settings.tabsMRUOrder = false;
settings.cursorAtEndOfInput = false;
settings.nextLinkRegex = /((>|›|→|»|≫|>>|следваща|forward|more|newer|next)+)/i;
settings.prevLinkRegex = /((<|‹|←|«|≪|<<|предишна|back|older|prev(ious)?)+)/i;

// previous/next tab
map("<Ctrl-n>", "R");
map("<Ctrl-p>", "E");
map("h", "E");
map("l", "R");

// history Back/Forward
map("H", "S");
map("L", "D");

// open link in new tab
map("F", "gf");

// Open Multiple Links
map("<Alt-f>", "cf");

// Paste clipboard
mapkey("p", "Open the clipboard's URL in the current tab", function () {
  navigator.clipboard.readText().then((text) => {
    if (text.startsWith("http://") || text.startsWith("https://")) {
      window.location = text;
    } else {
      window.location = text = "https://www.google.com/search?q=" + text;
    }
  });
});
mapkey("P", "Open link from clipboard in new tab", function () {
  navigator.clipboard.readText().then((text) => {
    if (text.startsWith("http://") || text.startsWith("https://")) {
      tabOpenLink(text);
    } else {
      tabOpenLink("https://www.google.com/search?q=" + text);
    }
  });
});

// use ` for marks
map("`", "'");

// go to last tab
mapkey("gl", "#4Go to last used tab", function () {
  RUNTIME("goToLastTab");
});

// copy url of an image
mapkey("ye", "Copy src URL of an image", function () {
  Hints.create("img[src]", (element, _evt) => {
    Clipboard.write(element.src);
  });
});

// set quick-tab-opening for `<C-1>`-`<C-0>` for tabs 1-10
for (let i = 1; i <= 9; i++) {
  unmap(`<Ctrl-${i}>`);
  mapkey(`<Ctrl-${i}>`, `Jump to tab ${i}`, function () {
    Normal.feedkeys(`${i}T`);
  });
}

// add / remove search engines
removeSearchAlias("b"); // baidu
removeSearchAlias("w"); // bing
removeSearchAlias("e"); // wikipedia
removeSearchAlias("y"); // youtube

addSearchAlias("t", "twitter", "https://twitter.com/search/");
addSearchAlias(
  "i",
  "images",
  "https://www.google.com/search?tbm=isch&q=",
  "s",
  "https://www.google.com/complete/search?client=chrome-omni&gs_ri=chrome-ext&oit=1&cp=1&pgcl=7&ds=i&q=",
  function (response) {
    var res = JSON.parse(response.text);
    return res[1];
  },
);
addSearchAlias("ama", "amazon", "https://www.amazon.com/s?k=", "s");
addSearchAlias(
  "ap",
  "arch pkg",
  "https://www.archlinux.org/packages/?sort=&q=",
  "s",
);
addSearchAlias(
  "aur",
  "aur",
  "https://aur.archlinux.org/packages/?O=0&SeB=nd&K=",
  "s",
);
addSearchAlias(
  "aw",
  "arch wiki",
  "https://wiki.archlinux.org/index.php?title=Special:Search&search=",
  "s",
);
addSearchAlias(
  "gh",
  "github",
  "https://github.com/search?q=",
  "s",
  "https://api.github.com/search/repositories?order=desc&q=",
  function (response) {
    var res = JSON.parse(response.text)["items"];
    return res
      ? res.map(function (r) {
          return {
            title: r.description,
            url: r.html_url,
          };
        })
      : [];
  },
);
addSearchAlias("pdb", "proton", "https://www.protondb.com/search?q=", "s");
addSearchAlias(
  "r",
  "reddit",
  "https://reddit.com/r/",
  "s",
  "https://www.reddit.com/subreddits/search.json?sort=relevance&limit=10&q=",
  function (response) {
    return JSON.parse(response.text).data.children.map(
      (p) => p.data.display_name,
    );
  },
);
addSearchAlias(
  "st",
  "steam",
  "https://store.steampowered.com/search/?term=",
  "s",
);
addSearchAlias(
  "wiki",
  "wikipedia",
  "https://en.wikipedia.org/wiki/Special:Search/",
  "s",
  "https://en.wikipedia.org/w/api.php?action=query&format=json&generator=prefixsearch&gpssearch=",
  function (response) {
    return Object.values(JSON.parse(response.text).query.pages).map(
      (p) => p.title,
    );
  },
);
addSearchAlias(
  "yt",
  "youtube",
  "https://www.youtube.com/results?search_query=",
  "s",
  "https://clients1.google.com/complete/search?client=youtube&ds=yt&callback=cb&q=",
  function (response) {
    var res = JSON.parse(response.text.substr(9, response.text.length - 10));
    return res[1].map(function (d) {
      return d[0];
    });
  },
);

// set theme
// Tomorrow-Night
// ---- Hints ----
Hints.style(
  "border: solid 2px #373B41; color:#9d7cd8; background: initial; background-color: #1D1F21;",
);
Hints.style(
  "border: solid 2px #373B41 !important; padding: 1px !important; color: #C5C8C6 !important; background: #1D1F21 !important;",
  "text",
);
Visual.style("marks", "background-color: #9d7cd899;");
Visual.style("cursor", "background-color: #81A2BE;");

settings.theme = `
:root {
  /* Font */
  --font: 'JetBrains Mono', 'Source Code Pro', Ubuntu, sans;
  --font-size: 13;
  --font-weight: bold;
  --fg: #C5C8C6;
  --bg: #1e1f29;
  --bg-dark: #1e1f29;
  --border: #44475a;
  --main-fg:  #41a6b5;
  --accent-fg: #9d7cd8;
  --info-fg:  #7aa2f7;
  --select: #44475a;

  /* Unused Alternate Colors */
  /* --cyan: #4CB3BC; */
  /* --orange: #DE935F; */
  /* --red: #CC6666; */
  /* --yellow: #CBCA77; */


/* ---------- Generic ---------- */
.sk_theme {
background: var(--bg);
color: var(--fg);
  background-color: var(--bg);
  border-color: var(--border);
  font-family: var(--font);
  font-size: var(--font-size);
  font-weight: var(--font-weight);
}

input {
  font-family: var(--font);
  font-weight: var(--font-weight);
}

.sk_theme tbody {
  color: var(--fg);
}

.sk_theme input {
  color: var(--fg);
}

/* Hints */
#sk_hints .begin {
  color: var(--accent-fg) !important;
}

#sk_tabs .sk_tab {
  background: var(--bg-dark);
  border: 1px solid var(--border);
}

#sk_tabs .sk_tab_title {
  color: var(--fg);
}

#sk_tabs .sk_tab_url {
  color: var(--main-fg);
}

#sk_tabs .sk_tab_hint {
  background: var(--bg);
  border: 1px solid var(--border);
  color: var(--accent-fg);
}

.sk_theme #sk_frame {
  background: var(--bg);
  opacity: 0.2;
  color: var(--accent-fg);
}

.sk_theme .title {
  color: var(--accent-fg);
}

.sk_theme .url {
  color: var(--main-fg);
}

.sk_theme .annotation {
  color: var(--accent-fg);
}

.sk_theme .omnibar_highlight {
  color: var(--accent-fg);
}

.sk_theme .omnibar_timestamp {
  color: var(--info-fg);
}

.sk_theme .omnibar_visitcount {
  color: var(--accent-fg);
}

#sk_omnibarSearchResult>ul>li {
  padding: 0.4rem 0.8rem;
}

.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
  background: var(--bg-dark);
}

.sk_theme #sk_omnibarSearchResult ul li.focused {
  background: var(--border);
}

.sk_theme #sk_omnibarSearchArea {
  border-top-color: var(--border);
  border-bottom-color: var(--border);
}

.sk_theme #sk_omnibarSearchArea input,
.sk_theme #sk_omnibarSearchArea span {
  font-size: var(--font-size);
}

.sk_theme .separator {
  color: var(--accent-fg);
}

/* ---------- Popup Notification Banner ---------- */
#sk_banner {
  font-family: var(--font);
  font-size: var(--font-size);
  font-weight: var(--font-weight);
  background: var(--bg);
  border-color: var(--border);
  color: var(--fg);
  opacity: 0.9;
}

/* ---------- Popup Keys ---------- */
#sk_keystroke {
  background-color: var(--bg);
}

.sk_theme kbd .candidates {
  color: var(--info-fg);
}

.sk_theme span.annotation {
  color: var(--accent-fg);
}

/* ---------- Popup Translation Bubble ---------- */
#sk_bubble {
  background-color: var(--bg) !important;
  color: var(--fg) !important;
  border-color: var(--border) !important;
}

#sk_bubble * {
  color: var(--fg) !important;
}

#sk_bubble div.sk_arrow div:nth-of-type(1) {
  border-top-color: var(--border) !important;
  border-bottom-color: var(--border) !important;
}

#sk_bubble div.sk_arrow div:nth-of-type(2) {
  border-top-color: var(--bg) !important;
  border-bottom-color: var(--bg) !important;
}

/* ---------- Search ---------- */
#sk_status,
#sk_find {
  font-size: var(--font-size);
  border-color: var(--border);
}

.sk_theme kbd {
  background: var(--bg-dark);
  border-color: var(--border);
  box-shadow: none;
  color: var(--fg);
}

.sk_theme .feature_name span {
  color: var(--main-fg);
}

/* ---------- ACE Editor ---------- */
#sk_editor {
  background: var(--bg-dark) !important;
  height: 50% !important;
  /* Remove this to restore the default editor size */
}

.ace_dialog-bottom {
  border-top: 1px solid var(--bg) !important;
}

.ace-chrome .ace_print-margin,
.ace_gutter,
.ace_gutter-cell,
.ace_dialog {
  background: var(--bg) !important;
}

.ace-chrome {
  color: var(--fg) !important;
}

.ace_gutter,
.ace_dialog {
  color: var(--fg) !important;
}

.ace_cursor {
  color: var(--fg) !important;
}

.normal-mode .ace_cursor {
  background-color: var(--fg) !important;
  border: var(--fg) !important;
  opacity: 0.7 !important;
}

.ace_marker-layer .ace_selection {
  background: var(--select) !important;
}

.ace_editor,
.ace_dialog span,
.ace_dialog input {
  font-family: var(--font);
  font-size: var(--font-size);
  font-weight: var(--font-weight);
}
`;
