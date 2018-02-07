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

    Rectangle {
        id: cursorIndicator
        x: cursorRectangle.x
        y: cursorRectangle.y
        width: cursorRectangle.width
        height: cursorRectangle.height
        visible: control.activeFocus
        color: "#353637"
        border.color: sysPalette.highlight
    }
}
