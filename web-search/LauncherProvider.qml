import QtQuick
import Quickshell
import qs.Commons

Item {
    id: root

    property var launcher: null
    property string name: I18n.tr("launcher.providers.websearch")
    property string iconMode: Settings.data.appLauncher.iconMode
    property bool handleSearch: false // contribute to regular search
    property string supportedLayouts: "list"
    property bool handleCommands: true

    // Available engines and templates
    readonly property var engines: [
        {
            id: "google",
            name: "Google",
            icon: "material:travel_explore",
            url: "https://www.google.com/search?q=%s",
            keywords: ["google", "search"]
        },
        {
            id: "duckduckgo",
            name: "DuckDuckGo",
            icon: "material:shield",
            url: "https://duckduckgo.com/?q=%s",
            keywords: ["ddg", "duckduckgo", "privacy"]
        },
        {
            id: "brave",
            name: "Brave Search",
            icon: "material:security",
            url: "https://search.brave.com/search?q=%s",
            keywords: ["brave", "privacy"]
        },
        {
            id: "bing",
            name: "Bing",
            icon: "material:language",
            url: "https://www.bing.com/search?q=%s",
            keywords: ["bing", "microsoft"]
        },
        {
            id: "youtube",
            name: "YouTube",
            icon: "material:youtube_activity",
            url: "https://www.youtube.com/results?search_query=%s",
            keywords: ["youtube", "video", "yt"]
        },
        {
            id: "github",
            name: "GitHub",
            icon: "unicode:",
            url: "https://github.com/search?q=%s",
            keywords: ["github", "code", "git"]
        },
        {
            id: "stackoverflow",
            name: "Stack Overflow",
            icon: "unicode:",
            url: "https://stackoverflow.com/search?q=%s",
            keywords: ["stackoverflow", "stack", "coding"]
        },
        {
            id: "reddit",
            name: "Reddit",
            icon: "unicode:",
            url: "https://www.reddit.com/search?q=%s",
            keywords: ["reddit"]
        },
        {
            id: "wikipedia",
            name: "Wikipedia",
            icon: "material:menu_book",
            url: "https://en.wikipedia.org/wiki/Special:Search?search=%s",
            keywords: ["wikipedia", "wiki"]
        },
        {
            id: "amazon",
            name: "Amazon",
            icon: "material:shopping_cart",
            url: "https://www.amazon.com/s?k=%s",
            keywords: ["amazon", "shop", "shopping"]
        },
        {
            id: "ebay",
            name: "eBay",
            icon: "material:local_mall",
            url: "https://www.ebay.com/sch/i.html?_nkw=%s",
            keywords: ["ebay", "shop", "auction"]
        },
        {
            id: "maps",
            name: "Google Maps",
            icon: "material:map",
            url: "https://www.google.com/maps/search/%s",
            keywords: ["maps", "location", "directions"]
        },
        {
            id: "images",
            name: "Google Images",
            icon: "material:photo_library",
            url: "https://www.google.com/search?tbm=isch&q=%s",
            keywords: ["images", "pictures", "photos"]
        },
        {
            id: "twitter",
            name: "Twitter/X",
            icon: "unicode:",
            url: "https://twitter.com/search?q=%s",
            keywords: ["twitter", "x", "social"]
        },
        {
            id: "linkedin",
            name: "LinkedIn",
            icon: "unicode:",
            url: "https://www.linkedin.com/search/results/all/?keywords=%s",
            keywords: ["linkedin", "job", "professional"]
        },
        {
            id: "imdb",
            name: "IMDb",
            icon: "unicode:",
            url: "https://www.imdb.com/find?q=%s",
            keywords: ["imdb", "movies", "tv"]
        },
        {
            id: "translate",
            name: "Google Translate",
            icon: "material:g_translate",
            url: "https://translate.google.com/?text=%s",
            keywords: ["translate", "translation"]
        },
        {
            id: "archlinux",
            name: "Arch Linux Wiki",
            icon: "material:terminal",
            url: "https://wiki.archlinux.org/index.php?search=%s",
            keywords: ["arch", "linux", "packages"]
        },
        {
            id: "aur",
            name: "AUR",
            icon: "unicode:",
            url: "https://aur.archlinux.org/packages?K=%s",
            keywords: ["aur", "arch", "packages"]
        },
        {
            id: "npmjs",
            name: "npm",
            icon: "unicode:",
            url: "https://www.npmjs.com/search?q=%s",
            keywords: ["npm", "node", "javascript"]
        },
        {
            id: "pypi",
            name: "PyPI",
            icon: "unicode:",
            url: "https://pypi.org/search/?q=%s",
            keywords: ["pypi", "python", "pip"]
        },
        {
            id: "crates",
            name: "crates.io",
            icon: "material:inventory_2",
            url: "https://crates.io/search?q=%s",
            keywords: ["crates", "rust", "cargo"]
        },
        {
            id: "mdn",
            name: "MDN Web Docs",
            icon: "material:code_blocks",
            url: "https://developer.mozilla.org/en-US/search?q=%s",
            keywords: ["mdn", "mozilla", "web", "docs"]
        }
    ]

    // Helper: get selected engine key from Settings (fallback to duckduckgo)
    function getSelectedEngineKey() {
        var key = Settings.data.appLauncher && Settings.data.appLauncher.searchEngine ? String(Settings.data.appLauncher.searchEngine) : "";
        key = key ? key.toLowerCase() : "";
        if (!key || !(key in engines)) {
            return "duckduckgo";
        }
        return key;
    }

    // Helper: set selected engine key in Settings and notify the user
    function setSelectedEngineKey(key) {
        if (!key)
            return;
        if (!Settings.data.appLauncher) {
            Settings.data.appLauncher = {};
        }
        Settings.data.appLauncher.searchEngine = key;

        // Try to persist if Settings.save is available
        if (typeof Settings.save !== "undefined") {
            try {
                Settings.save();
            } catch (e) {
                // ignore save errors
            }
        }

        var name = engines[key] ? engines[key].name : key;
        if (typeof ToastService !== "undefined" && ToastService.showNotice) {
            ToastService.showNotice(I18n.tr("launcher.providers.websearch-change-engine-notice", {
                "engine": name
            }), I18n.tr("launcher.providers.websearch-change-engine"));
        }

        Logger.d("WebSearchProvider", "Search engine changed to: " + key);

        // If custom template selected, open settings so user can set the custom template
        if (key === "custom" && typeof SettingsService !== "undefined" && SettingsService.openSection) {
            SettingsService.openSection("appLauncher.search");
        }
    }

    function getEngineTemplate(key) {
        if (!key)
            key = getSelectedEngineKey();
        if (key === "custom") {
            var t = Settings.data.appLauncher && Settings.data.appLauncher.searchEngineCustomTemplate ? Settings.data.appLauncher.searchEngineCustomTemplate : "";
            return t || "";
        }
        return engines[key] ? engines[key].template : "";
    }

    function buildUrlFromTemplate(template, q) {
        if (!template)
            return "";
        // encode q
        var encoded = encodeURIComponent(q);
        return template.replace(/\{q\}/g, encoded);
    }

    function handleCommand(query) {
        return query.startsWith(">web");
    }

    function commands() {
        return [
            {
                "name": ">web",
                "description": I18n.tr("launcher.providers.websearch-description-alt"),
                "icon": iconMode === "tabler" ? "world" : "web-browser",
                "isTablerIcon": true,
                "isImage": false,
                "onActivate": function () {
                    launcher.setSearchText(">web ");
                }
            }
        ];
    }

    // For regular search contributions and explicit command
    function getResults(query) {
        if (!query && query !== "")
            return [];

        // Trim
        var q = query ? query.trim() : "";

        // If command mode (">search" or ">web")
        if (q.startsWith(">web")) {
            var expression = q.indexOf(" ") >= 0 ? q.substring(q.indexOf(" ")).trim() : "";
            if (!expression) {
                // Prompt entry telling user to type query
                return [
                    {
                        "name": I18n.tr("launcher.providers.websearch-empty"),
                        "description": I18n.tr("launcher.providers.websearch-empty-description"),
                        "icon": iconMode === "tabler" ? "search" : "system-search",
                        "isTablerIcon": true,
                        "isImage": false,
                        "onActivate": function () {/* noop */ }
                    }
                ];
            }

            // Build primary search result using selected engine
            var engineKey = getSelectedEngineKey();
            var template = getEngineTemplate(engineKey);
            var url = template ? buildUrlFromTemplate(template, expression) : "";

            var results = [];

            if (url) {
                results.push({
                    "name": I18n.tr("launcher.providers.websearch-search-with", {
                        "engine": (engines[engineKey] ? engines[engineKey].name : engineKey),
                        "query": expression
                    }),
                    "description": url,
                    "icon": iconMode === "tabler" ? "link" : "internet-web-browser",
                    "isTablerIcon": true,
                    "isImage": false,
                    "provider": root,
                    "onActivate": function () {
                        // Open in default browser
                        if (launcher)
                            launcher.closeImmediately();
                        Qt.callLater(() => {
                            // Use xdg-open; shell-escape the URL
                            var safe = url.replace(/'/g, "'\\''");
                            Quickshell.execDetached(["sh", "-c", "xdg-open '" + safe + "'"]);
                        });
                    }
                });
            }

            // Add quick alternative searches (Wikipedia, YouTube, Images using engine where possible)
            var wiki = buildUrlFromTemplate(getEngineTemplate("wikipedia"), expression);
            var yt = buildUrlFromTemplate(getEngineTemplate("youtube"), expression);

            if (wiki) {
                results.push({
                    "name": I18n.tr("launcher.providers.websearch-search-wikipedia", {
                        "query": expression
                    }),
                    "description": wiki,
                    "icon": iconMode === "tabler" ? "book" : "text-x-generic",
                    "isTablerIcon": true,
                    "isImage": false,
                    "provider": root,
                    "onActivate": function () {
                        if (launcher)
                            launcher.closeImmediately();
                        Qt.callLater(() => {
                            var safe = wiki.replace(/'/g, "'\\''");
                            Quickshell.execDetached(["sh", "-c", "xdg-open '" + safe + "'"]);
                        });
                    }
                });
            }

            if (yt) {
                results.push({
                    "name": I18n.tr("launcher.providers.websearch-search-youtube", {
                        "query": expression
                    }),
                    "description": yt,
                    "icon": iconMode === "tabler" ? "brand-youtube" : "video-x-generic",
                    "isTablerIcon": true,
                    "isImage": false,
                    "provider": root,
                    "onActivate": function () {
                        if (launcher)
                            launcher.closeImmediately();
                        Qt.callLater(() => {
                            var safe = yt.replace(/'/g, "'\\''");
                            Quickshell.execDetached(["sh", "-c", "xdg-open '" + safe + "'"]);
                        });
                    }
                });
            }

            return results;
        }

        // Regular search contributions: show web search suggestion plus 1-2 quick links
        var trimmed = (q || "").trim();
        if (!trimmed) {
            return [];
        }

        var engineKey = getSelectedEngineKey();
        var templateMain = getEngineTemplate(engineKey);
        var mainUrl = templateMain ? buildUrlFromTemplate(templateMain, trimmed) : "";

        var res = [];
        if (mainUrl) {
            res.push({
                "name": I18n.tr("launcher.providers.websearch-search-with", {
                    "engine": (engines[engineKey] ? engines[engineKey].name : engineKey),
                    "query": trimmed
                }),
                "description": mainUrl,
                "icon": iconMode === "tabler" ? "search" : "system-search",
                "isTablerIcon": true,
                "isImage": false,
                "provider": root,
                "onActivate": function () {
                    if (launcher)
                        launcher.closeImmediately();
                    Qt.callLater(() => {
                        var safe = mainUrl.replace(/'/g, "'\\''");
                        Quickshell.execDetached(["sh", "-c", "xdg-open '" + safe + "'"]);
                    });
                }
            });
        }

        // Add Wikipedia and YouTube quick results (if they would differ)
        var wikiUrl = buildUrlFromTemplate(getEngineTemplate("wikipedia"), trimmed);
        if (wikiUrl && wikiUrl !== mainUrl) {
            res.push({
                "name": I18n.tr("launcher.providers.websearch-search-wikipedia-short", {
                    "query": trimmed
                }),
                "description": wikiUrl,
                "icon": iconMode === "tabler" ? "book" : "text-x-generic",
                "isTablerIcon": true,
                "isImage": false,
                "provider": root,
                "onActivate": function () {
                    if (launcher)
                        launcher.closeImmediately();
                    Qt.callLater(() => {
                        var safe = wikiUrl.replace(/'/g, "'\\''");
                        Quickshell.execDetached(["sh", "-c", "xdg-open '" + safe + "'"]);
                    });
                }
            });
        }

        var ytUrl = buildUrlFromTemplate(getEngineTemplate("youtube"), trimmed);
        if (ytUrl && ytUrl !== mainUrl && ytUrl !== wikiUrl) {
            res.push({
                "name": I18n.tr("launcher.providers.websearch-search-youtube-short", {
                    "query": trimmed
                }),
                "description": ytUrl,
                "icon": iconMode === "tabler" ? "brand-youtube" : "video-x-generic",
                "isTablerIcon": true,
                "isImage": false,
                "provider": root,
                "onActivate": function () {
                    if (launcher)
                        launcher.closeImmediately();
                    Qt.callLater(() => {
                        var safe = ytUrl.replace(/'/g, "'\\''");
                        Quickshell.execDetached(["sh", "-c", "xdg-open '" + safe + "'"]);
                    });
                }
            });
        }

        // Limit to a few results so it stays usable in the combined results list
        return res.slice(0, 3);
    }

    // Optional item actions: allow quick-change of engine if desired by user
    function getItemActions(item) {
        if (!item)
            return [];

        var actions = [];

        // Per-engine quick actions (shows current selection with check icon)
        var selected = getSelectedEngineKey();
        for (var k in engines) {
            // capture k
            (function (engineKey) {
                    var engineName = engines[engineKey] ? engines[engineKey].name : engineKey;
                    actions.push({
                        "icon": engineKey === selected ? "check" : "web-browser",
                        "tooltip": I18n.tr("launcher.providers.websearch-change-to", {
                            "engine": engineName
                        }),
                        "action": function () {
                            setSelectedEngineKey(engineKey);
                            // close launcher after change for immediate feedback
                            if (root.launcher)
                                root.launcher.close();
                        }
                    });
                })(k);
        }

        // Provide an "Open engine selection settings" fallback action (kept for compatibility)
        actions.push({
            "icon": "settings",
            "tooltip": I18n.tr("launcher.providers.websearch-change-engine"),
            "action": function () {
                // Open settings screen (if available in Noctalia) - best-effort
                if (root.launcher) {
                    // If a settings module/service is present, attempt to open it
                    if (typeof SettingsService !== "undefined" && SettingsService.openSection) {
                        SettingsService.openSection("appLauncher.search");
                    } else {
                        ToastService.showNotice(I18n.tr("toast.open-settings"), I18n.tr("launcher.providers.websearch-change-engine"));
                    }
                    root.launcher.close();
                }
            }
        });

        return actions;
    }

    // Initialization
    function init() {
        Logger.d("WebSearchProvider", "Initialized (engine: " + getSelectedEngineKey() + ")");
    }
}
