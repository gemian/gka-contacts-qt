import QtQuick 2.7
import QtContacts 5.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

Window {
    id: deleteDialog
    visible: true
    modality: Qt.ApplicationModal
    width: Math.max(questionRow.width, buttonRow.width)
    height: dialogColumn.height
    x: Screen.width / 2 - width / 2
    y: Screen.height / 2 - height / 2

    property var contactObject;
    property var model;
    property int padding: app.appFontSize/5

    function deleteAndClose() {
        deleteDialog.model.removeContact(contactObject.contactId);
        deleteDialog.model.updateIfNecessary();
        deleteDialog.close()
    }

    Component.onCompleted: {
        cancelButton.forceActiveFocus()
    }

    title: i18n.tr("Delete Contact")

    Column {
        id: dialogColumn
        width: questionLabel.width
        topPadding: deleteDialog.padding
        bottomPadding: deleteDialog.padding
        spacing: deleteDialog.padding

        Row {
            id: questionRow
            leftPadding: deleteDialog.padding
            rightPadding: deleteDialog.padding
            Label {
                id: questionLabel
                text: i18n.tr("Are you sure you want to delete the contact: %1?").arg(contactObject.displayLabel.label);
                font.pixelSize: app.appFontSize
                wrapMode: Text.Wrap
            }
        }
        Row {
            id: buttonRow
            leftPadding: deleteDialog.padding
            rightPadding: deleteDialog.padding
            spacing: deleteDialog.padding

            ZoomButton {
                id: deleteIndividualButton
                text: i18n.tr("Delete (ctrl-d)")
                activeFocusOnTab: true
                activeFocusOnPress: true
                KeyNavigation.right: cancelButton
                onClicked: {
                    deleteAndClose();
                }
                Keys.onEnterPressed: {
                    deleteAndClose();
                }
                Keys.onReturnPressed: {
                    deleteAndClose();
                }
            }

            ZoomButton {
                id: cancelButton
                text: i18n.tr("Cancel (esc)")
                activeFocusOnTab: true
                activeFocusOnPress: true
                focus: true
                onClicked: {
                    deleteDialog.close()
                }
                Keys.onEnterPressed: {
                    deleteDialog.close()
                }
                Keys.onReturnPressed: {
                    deleteDialog.close()
                }
            }
        }
        Keys.onEscapePressed: {
            deleteDialog.close()
        }
        Shortcut {
            sequence: "Ctrl+d"
            onActivated: {
                deleteAndClose();
            }
        }
    }
}
