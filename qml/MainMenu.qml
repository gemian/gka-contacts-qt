import QtQuick 2.7
import QtQuick.Controls 1.4

MenuBar {
    id: menuBar

    property var model;
    property var settings;

    Menu {
        title: qsTr("&File")
        id: fileMenu
        MenuItem {
            action: quitAction
        }
    }

    Menu {
        title: qsTr("&Edit")
        id: editMenu
        MenuItem {
            id: editMenuAdd
            text: qsTr("&Add Item")
            onTriggered: {
                dialogLoader.setSource("EditContactDialog.qml", {"model":contactsModel});
            }
        }
//        MenuItem {
//            action: collectionsDialogAction
//        }
    }

    Menu {
        title: qsTr("&View")
        id: viewMenu
        MenuItem {
            action: zoomInAction
        }
        MenuItem {
            action: zoomOutAction
        }
    }

    Menu {
        title: qsTr("&Tools")
        id: toolsMenu
        MenuItem {
            id: toolsMenuSettings
            text: qsTr("&Settings")
            onTriggered: {
                dialogLoader.setSource("SettingsDialog.qml", {"settings": menuBar.settings});
            }
        }
    }
}
