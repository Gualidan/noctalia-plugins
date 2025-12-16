import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI

Rectangle {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""

    property int updateInterval: pluginApi?.pluginSettings.updateInterval || pluginApi?.manifest?.metadata.defaultSettings?.updateInterval
    property string configuredTerminal: pluginApi?.pluginSettings.configuredTerminal || pluginApi?.manifest?.metadata.defaultSettings?.configuredTerminal
    property int count: checkForUpdates() || 0
    property bool isVisible: root.count > 0 || true
    property bool hideOnZero: pluginApi?.pluginSettings.hideOnZero || pluginApi?.manifest?.metadata.defaultSettings?.hideOnZero

    readonly property string barPosition: Settings.data.bar.position
    readonly property bool isVertical: barPosition === "left" || barPosition === "right"
    readonly property string updateScriptDir: (pluginApi?.pluginDir || Settings.configDir + "/plugins/update-count") + "/scripts"

    implicitWidth: isVertical ? Style.capsuleHeight : layout.implicitWidth + Style.marginM * 2
    implicitHeight: isVertical ? layout.implicitHeight + Style.marginM * 2 : Style.capsuleHeight

    color: Style.capsuleColor
    radius: Style.radiusM

    function hiddenWidgetMode() {
        if (root.hideOnZero) {
            if (root.isVertical && root.count === 0) {
                root.visible = false;
            }
            if (!root.isVertical && root.count === 0) {
                root.visible = false;
            }
            if (root.isVertical && root.count > 0) {
                root.visible = true;
            }
            if (!root.isVertical && root.count > 0) {
                root.visible = true;
            }
        }
    }

    function checkForUpdates() {
        updateDataHandler.running = true;
    }

    function updateSystemPopup() {
        updateSystemHandler.running = true;
    }

    function buildTooltip() {
        if (root.count == 0) {
            TooltipService.show(root, "No updates available", BarService.getTooltipDirection());
        } else {
            TooltipService.show(root, "Click to update your system", BarService.getTooltipDirection());
        }
    }

    Process {
        id: updateDataHandler
        command: ["sh", "-c", root.updateScriptDir + "/update-count.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                var count = parseInt(text.trim());
                root.count = isNaN(count) ? 0 : count;
            }
        }
    }

    Process {
        id: updateSystemHandler
        command: ["sh", "-c", root.configuredTerminal + " " + (pluginApi?.pluginDir || Settings.configDir + "/plugins/update-count") + "/scripts/update.sh"]
    }

    Timer {
        interval: root.updateInterval
        running: true
        repeat: true
        onTriggered: {
            root.checkForUpdates();
            root.hiddenWidgetMode();
        }
    }

    Item {
        id: layout
        anchors.centerIn: parent
        implicitWidth: rowLayout.visible ? rowLayout.implicitWidth : colLayout.implicitWidth
        implicitHeight: rowLayout.visible ? rowLayout.implicitHeight : colLayout.implicitHeight

        RowLayout {
            id: rowLayout
            visible: !root.isVertical
            spacing: Style.marginS

            NIcon {
                icon: pluginApi?.pluginSettings?.configuredIcon || pluginApi?.manifest?.metadata?.defaultSettings?.configuredIcon
                color: Settings.data.colorSchemes.darkMode ? Color.mOnSurface : Color.mOnPrimary
            }

            NText {
                text: root.count.toString()
                color: Settings.data.colorSchemes.darkMode ? Color.mOnSurface : Color.mOnPrimary
                pointSize: Style.fontSizeS
            }
        }

        ColumnLayout {
            id: colLayout
            visible: root.isVertical
            spacing: Style.marginS

            NIcon {
                Layout.alignment: Qt.AlignHCenter
                icon: pluginApi?.pluginSettings?.configuredIcon || pluginApi?.manifest?.metadata?.defaultSettings?.configuredIcon
                color: Settings.data.colorSchemes.darkMode ? Color.mOnSurface : Color.mOnPrimary
            }

            NText {
                Layout.alignment: Qt.AlignHCenter
                text: root.count.toString()
                color: Settings.data.colorSchemes.darkMode ? Color.mOnSurface : Color.mOnPrimary
                pointSize: Style.fontSizeS
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                updateSystemPopup();
            }

            onEntered: {
                root.color = Qt.lighter(Style.capsuleColor, 1.1);
                buildTooltip();
            }

            onExited: {
                root.color = Style.capsuleColor;
                TooltipService.hide();
            }
        }
    }
}
