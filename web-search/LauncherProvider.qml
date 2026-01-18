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
