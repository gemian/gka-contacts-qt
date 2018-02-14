import QtQuick 2.6
import QtQuick.Controls 2.0
import "urlType.js" as UrlTypeExt


TextField {
    id: control
    readOnly: true
    selectByMouse: true
    font.pixelSize: app.appFontSize

    property var urlOpenList


    function launchUrl(index) {
        var url = "";
        console.log("urlOpenList: "+urlOpenList);
        if (urlOpenList.length >= index+1) {
            console.log("urlOpenList["+index+"]: "+urlOpenList[index]);
            switch (urlOpenList[index]) {
            case UrlTypeExt.UrlType.Address:
                url = "https://www.openstreetmap.org/search?query=" + control.text;
                break;
            case UrlTypeExt.UrlType.Message:
                url = "message:" + control.text;
                break;
            case UrlTypeExt.UrlType.Dialer:
                url = "tel:" + control.text;
                break;
            case UrlTypeExt.UrlType.Url:
                url = control.text;
                if (url.indexOf("http") == -1) {
                    url = "http://"+url;
                }
                break;
            }
        }
        if (url.length > 0) {
            var ret = Qt.openUrlExternally(url);
            console.log("url open:"+url+", result:"+ret);
        }
    }

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

    Triangle {
        id: arrow
        color: sysPalette.highlight
        fill: true
        visible: control.activeFocus
        height: app.appFontSize*0.75
        width: app.appFontSize*0.5
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: app.appFontSize*0.25
        }
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            launchUrl(0);
        }
        if (event.key === Qt.Key_Space) {
            launchUrl(1);
        }
    }
}
