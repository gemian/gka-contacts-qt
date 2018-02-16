import QtQuick 2.7
import QtQuick.Controls 1.4

MenuBar {
    id: menuBar

    property var model;
    property var settings;

    Menu {
        title: i18n.tr("&File")
        id: fileMenu
        MenuItem {
            action: quitAction
        }
    }

    Menu {
        title: i18n.tr("&Edit")
        id: editMenu
        MenuItem {
            action: addAction
        }
        MenuItem {
            action: editSelectedAction
        }
        MenuItem {
            action: deleteSelectedAction
        }
//--
//        MenuItem {
//            action: collectionsDialogAction
//        }
    }

    Menu {
        title: i18n.tr("&View")
        id: viewMenu
        MenuItem {
            action: zoomInAction
        }
        MenuItem {
            action: zoomOutAction
        }
    }

//    Menu {
//        title: i18n.tr("&Tools")
//        id: toolsMenu
//        MenuItem {
//            id: toolsMenuSettings
//            text: i18n.tr("&Settings")
//            onTriggered: {
//                dialogLoader.setSource("SettingsDialog.qml", {"settings": menuBar.settings});
//            }
//        }
//    }
}
