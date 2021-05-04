// TODO: load default config

var changeScrollTarget;
var lastScrollIndex;
{
    if (changeScrollTarget == null) {
        const cs = Normal.mappings.find('cs');
        if (cs != null) {
            changeScrollTarget = cs.meta.code;
        }

        lastScrollIndex = 0;
    }
}
function selectScrollTarget() {
    // Available Operations
    //   * changeScrollTarget()
    //   * Normal.getScrollableElements()

    const elems = Normal.getScrollableElements();

    Hints.create(elems, function(e) {
        for (const i in elems) { // i is String
            if (elems[i] == e) {
                const diff = (parseInt(i, 10) + elems.length - lastScrollIndex) % elems.length;
                const changes = (diff + elems.length - 1) % elems.length;

                const highlight = Front.highlightElement;
                const scroll = scrollIntoViewIfNeeded;
                Front.highlightElement = () => {};
                scrollIntoViewIfNeeded = () => {};
                [...Array(changes)].map(() => {
                    changeScrollTarget();
                });
                Front.highlightElement = highlight;
                scrollIntoViewIfNeeded = scroll;

                changeScrollTarget();

                lastScrollIndex = i;
                break;
            }
        }
    });
}

function modifyUrl() {
    const url = location.href;
    switch (true) {
    case /^https?:\/\/www\.amazon\.co\.jp\/s(?:\?.*)?$/.test(url):
        // const magic = '&emi=AN1VRQENFRJN5';
        const magic = '&rh=p_6%3AAN1VRQENFRJN5';
        const pat = new RegExp(String.raw`${magic}(&.*)?$`);
        if (pat.test(url)) {
            location.href = url.replace(pat, '$1');
        } else {
            location.href = url + magic;
        }
        break;
    }
}

// Mouse Click
map('F', 'gf');    // Open a link in non-active new tab
mapkey(';', '#1Select scroll target', selectScrollTarget);
unmap('cf');       // Open multiple links in a new tab
unmap('af');       // Open a link in new tab
unmap('C');        // Open a link in non-active new tab
unmap('<Ctrl-h>'); // Mouse over elements
unmap('<Ctrl-j>'); // Mouse out elements
unmap('[[');       // Click on the previous link on current page
unmap(']]');       // Click on the next link on current page
unmap('q');        // Click on an Image or a button

// Scroll Page / Element #2
map('g', 'gg'); // Scroll to the top of the page
mapkey('<Space>', '#2Scroll full page down', function() {
    Normal.scroll('fullPageDown');
});
mapkey('b', '#2Scroll full page up', function() {
    Normal.scroll('fullPageUp');
});
unmap('0');     // Scroll all the way to the left
unmap('cS');    // Reset scroll target
unmap('cs');    // Change scroll target
unmap('e');     // Scroll a page up
unmap('$');     // Scroll all the way to the right
unmap(';w');    // Focus top window

// Page Navigation
map('p', 'S');  // Go back in history
map('n', 'D');  // Go forward in history

// Omnibar
map('O', 't');      // Open a URL
map('t', 'og');     // Open Search with alias g
map('H', 'oh');     // Open URL from history
map('o', 'ox');     // Open recently closed URL
cmap('<PageDown>', '<Ctrl-.>'); // Show results of next page
cmap('<PageUp>', '<Ctrl-,>'); // Show results of previous page
unmap('ab');        // Bookmark current page to selected folder
unmap('Q');         // Open omnibar for word translation

// Tabs
map(',', 'E');        // Go one tab left
map('.', 'R');        // Go one tab right
map('<', '<<');       // Move current tab to left
map('>', '>>');       // Move current tab to right
map('e', 'W');        // New window with current tab
map('m', 'T');        // Choose a tab
map('w', 'x');        // Close current tab
map('W', 'X');        // Restore closed tab
map('T', 'yt');       // Duplicate current tab
map('<Alt-z>', 'zr'); // Zoom reset
map('Z', 'zo');       // Zoom out
map('z', 'zi');       // Zoom in
unmap('yt');          // Duplicate current tab
unmap('E');           // Go one tab left
unmap('R');           // Go one tab right
unmap('<Alt-p>');     // pin/unpin current tab
unmap('<Alt-m>');     // mute/unmute current tab
unmap('x');           // Close current tab
unmap('X');           // Restore closed tab

// Page Navigation
mapkey('x', '#4Modify the url with the URL-dependent method', modifyUrl);

Hints.characters = 'fjdksla;rueiwop';
Hints.style('font-family: monospace; font-size: 9pt !important'); // need !important for some properties
settings.hintAlign = 'left';
settings.tabsThreshold = 0;
settings.theme = `
    .sk_theme input {
        font-family: sans-serif;
    }
`;
