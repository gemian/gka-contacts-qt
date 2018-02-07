import QtQuick 2.6
import QtQuick.Controls 2.0

TextField {
    id: control
    readOnly: true
    selectByMouse: true
    font.pixelSize: app.appFontSize

    background: Rectangle {
        color: control.enabled ? "transparent" : "#353637"
        border.color: control.activeFocus ? sysPalette.highlight : "transparent"
    }

    onFocusChanged: {
        if (activeFocus) {
            cursorPosition = 0;
            makeItemVisible(control, personalScrollview)
        }
    }
}
