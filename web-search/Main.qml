import QtQuick
import Quickshell.Io
import qs.Services.UI

Item {
    property var pluginApi: null

    IpcHandler {
        target: "plugin:web"
        function toggle() {
            pluginApi.withCurrentScreen(screen => {
                var launcherPanel = PanelService.getPanel("launcherPanel", screen);
                if (!launcherPanel)
                    return;
                var searchText = launcherPanel.searchText || "";
                var isInUnicodeMode = searchText.startsWith(">web");
                if (!launcherPanel.isPanelOpen) {
                    launcherPanel.open();
                    launcherPanel.setSearchText(">web ");
                } else if (isInWebMode) {
                    launcherPanel.close();
                } else {
                    launcherPanel.setSearchText(">web ");
                }
            });
        }
    }
}
