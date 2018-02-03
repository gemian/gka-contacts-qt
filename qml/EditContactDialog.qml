import QtQuick 2.7
import QtContacts 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "dateExt.js" as DateExt

Window {
    id: editContactDialog
    visible: true
    modality: Qt.ApplicationModal
    title: i18n.tr("Enter contact details")
    height: app.height
    width: app.width
    x: Screen.width / 2 - width / 2
    y: Screen.height / 2 - height / 2

    property var contactObject:null

    property var localeDateInputMask: makeLocaleDateInputMask()

    function makeLocaleDateInputMask() {
        var sample = new Date().toLocaleDateString(Qt.locale(), Locale.ShortFormat);
        return makeLocaleMaskForSample(sample);
    }

    function makeLocaleMaskForSample(sample) {
        var mask = "";
        var lastWasDigit = false;
        for (var i=0; i<sample.length; i++) {
            var c = sample.substr(i,1);
            //console.log("i: "+i+", c: "+c+", text:"+sample);
            if (c === ':' || c === ',' || c === '/') {
                mask += c;
            } else if (c < '0' || c > '9' || c === '\\') {
                mask += 'x';
            } else {
                if (lastWasDigit) {
                    mask += '0';
                } else {
                    mask += '9';
                }
                lastWasDigit = true;
            }
        }
        return mask;
    }

    function makeItemVisible(item) {
        if (!item) {
            return;
        }

        // check if visible
        var bottomY = dialogScrollview.flickableItem.contentY + dialogScrollview.flickableItem.height
        var itemBottom = item.y + (item.height * 3)
        if (item.y >= dialogScrollview.flickableItem.contentY && itemBottom <= bottomY) {
            return;
        }

        // if it is not, try to scroll and make it visible
        var targetY = itemBottom - dialogScrollview.flickableItem.height
        if (targetY >= 0 && item.y) {
            if (targetY > dialogScrollview.contentItem.height-dialogScrollview.flickableItem.height) {
                targetY = dialogScrollview.contentItem.height-dialogScrollview.flickableItem.height;
            }
            dialogScrollview.flickableItem.contentY = targetY;
        } else if (item.y < dialogScrollview.flickableItem.contentY) {
            // if it is hidden at the top, also show it
            dialogScrollview.flickableItem.contentY = item.y-app.appFontSize/2;
        }

        dialogScrollview.flickableItem.returnToBounds();
    }

    function getPhoneNumberOfType(contact, type) {
        if (contact.phoneNumbers) {
            for (var i=0; i < contact.phoneNumbers.length ; ++i) {
                var phoneNumber = contact.phoneNumbers[i];
                console.log(phoneNumber.subTypes.indexOf(type)+ " " + type);
                if (phoneNumber.subTypes.indexOf(type)> -1) {
                    return phoneNumber.number;
                }
            }
        }
        return false;
    }

    function edit(c) {
        if (c.name) {
            if (c.name.firstName) {
                firstNameField.text = c.name.firstName;
            }
            if (c.name.middleName) {
                middleNameField.text = c.name.middleName;
            }
            if (c.name.lastName) {
                lastNameField.text = c.name.lastName;
            }
        }
        if (c.email && c.email.emailAddress) {
            emailAddressField.text = c.email.emailAddress;
        }
        if (getPhoneNumberOfType(c, PhoneNumber.Mobile)) {
            mobilePhoneNumberField.text = getPhoneNumberOfType(c, PhoneNumber.Mobile);
        }
        if (getPhoneNumberOfType(c, PhoneNumber.Voice)) {
            voicePhoneNumberField.text = getPhoneNumberOfType(c, PhoneNumber.Voice);
        }
        if (c.addresses && c.addresses[0]) {
            var address = c.addresses[0];
            if (address.street) {
                addressStreetField.text = address.street;
            }
            if (address.locality) {
                addressLocalityField.text = address.locality;
            }
            if (address.region) {
                addressRegionField.text = address.region;
            }
            if (address.postcode) {
                addressPostcodeField.text = address.postcode;
            }
            if (address.country) {
                addressCountryField.text = address.country;
            }
            if (address.postOfficeBox) {
                addressPostOfficeBoxField.text = address.postOfficeBox;
            }
        }
        if (c.addresses && c.addresses[1]) {
            var addressO = c.addresses[1];
            if (addressO.street) {
                addressOStreetField.text = addressO.street;
            }
            if (addressO.locality) {
                addressOLocalityField.text = addressO.locality;
            }
            if (addressO.region) {
                addressORegionField.text = addressO.region;
            }
            if (addressO.postcode) {
                addressOPostcodeField.text = addressO.postcode;
            }
            if (addressO.country) {
                addressOCountryField.text = addressO.country;
            }
            if (addressO.postOfficeBox) {
                addressOPostOfficeBoxField.text = addressO.postOfficeBox;
            }
        }
        if (c.birthday && c.birthday.birthday.isValid()) {
            birthdayField.text = c.birthday.birthday.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
        }
        if (c.organisation) {
            if (c.organisation.name) {
                organisationNameField.text = c.organisation.name;
            }
            if (contact.organisation.role) {
                organisationRoleField.text = c.organisation.role;
            }
            if (contact.organisation.title) {
                organisationTitleField.text = c.organisation.title;
            }
        }
        if (c.url && c.url.url) {
            urlField.text = c.url.url;
        }
        if (c.hobby && c.hobby.hobby) {
            hobbyField.text = c.hobby.hobby;
        }
        if (c.note && c.note.note) {
            noteField.text = c.note.note;
        }
    }

    function saveContact() {

    }

    Rectangle {
        id: dialogRectangle
        width: editContactDialog.width
        height: editContactDialog.height
        border.color: "black"
        border.width: Math.floor(app.appFontSize/10)
        color: "#edeeef"

        ScrollView {
            id: dialogScrollview
            width: dialogRectangle.width - okCancelButtonsColumn.width - app.appFontSize
            height: dialogRectangle.height

            GridLayout {
                id: contactGrid
                width: dialogScrollview.viewport.width
                columns: 2
                columnSpacing: app.appFontSize
                Layout.topMargin: app.appFontSize

                Item {
                    height: app.appFontSize/2
                    Layout.columnSpan: 2
                }
                ZoomLabel {
                    id: firstNameLabel
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("First Name")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: firstNameField
                    width: contactGrid.width - firstNameLabel.width - app.appFontSize
                    KeyNavigation.down: middleNameField
                    Layout.fillWidth: true
                    focus: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(firstNameField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Middle Name")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: middleNameField
                    KeyNavigation.down: lastNameField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(middleNameField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Last Name")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: lastNameField
                    KeyNavigation.down: emailAddressField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(lastNameField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Email")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: emailAddressField
                    KeyNavigation.down: mobilePhoneNumberField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(emailAddressField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Mobile")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: mobilePhoneNumberField
                    KeyNavigation.down: voicePhoneNumberField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(mobilePhoneNumberField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Voice")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: voicePhoneNumberField
                    KeyNavigation.down: addressStreetField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(voicePhoneNumberField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Address")
                    Layout.columnSpan: 2
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Street")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: addressStreetField
                    KeyNavigation.down: addressLocalityField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(addressStreetField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Locality")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: addressLocalityField
                    KeyNavigation.down: addressRegionField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(addressLocalityField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Region")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: addressRegionField
                    KeyNavigation.down: addressPostcodeField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(addressRegionField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Postcode")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: addressPostcodeField
                    KeyNavigation.down: addressCountryField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(addressPostcodeField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Country")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: addressCountryField
                    KeyNavigation.down: addressPostOfficeBoxField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(addressCountryField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Post Office Box")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: addressPostOfficeBoxField
                    KeyNavigation.down: addressOStreetField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(addressPostOfficeBoxField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Address (Other)")
                    Layout.columnSpan: 2
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Street")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: addressOStreetField
                    KeyNavigation.down: addressOLocalityField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(addressOStreetField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Locality")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: addressOLocalityField
                    KeyNavigation.down: addressORegionField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(addressOLocalityField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Region")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: addressORegionField
                    KeyNavigation.down: addressOPostcodeField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(addressORegionField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Postcode")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: addressOPostcodeField
                    KeyNavigation.down: addressOCountryField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(addressOPostcodeField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Country")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: addressOCountryField
                    KeyNavigation.down: addressOPostOfficeBoxField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(addressOCountryField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Post Office Box")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: addressOPostOfficeBoxField
                    KeyNavigation.down: birthdayField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(addressOPostOfficeBoxField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Birthday")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: birthdayField
                    inputMask: localeDateInputMask
                    font.pixelSize: app.appFontSize
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(birthdayField)
                        } else {
                            var birthday = Date.fromLocaleDateString(Qt.locale(), text, Locale.ShortFormat);
                            text = birthday.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            datePicker.selectedDate = Date.fromLocaleDateString(Qt.locale(), birthdayField.text, Locale.ShortFormat);
                            datePicker.visible = true;
                        }
                    }
                    Keys.onPressed: {
                        if (event.key === Qt.Key_Tab || event.key === Qt.Key_Space) {
                            console.log("key Tab");
                            datePicker.selectedDate = Date.fromLocaleDateString(Qt.locale(), text, Locale.ShortFormat);
                            datePicker.visible = true;
                            event.accepted = true;
                        }
                    }
                    KeyNavigation.down: organisationNameField
                }
                ZoomLabel {
                    id: organisationLabel
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Organisation")
                    Layout.columnSpan: 2
                }
                ZoomLabel {
                    id: organisationNameLabel
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Name")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: organisationNameField
                    KeyNavigation.down: organisationRoleField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(organisationNameField)
                        }
                    }
                }
                ZoomLabel {
                    id: organisationRoleLabel
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Role")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: organisationRoleField
                    KeyNavigation.down: organisationTitleField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(organisationRoleField)
                        }
                    }
                }
                ZoomLabel {
                    id: organisationTitleLabel
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Title")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: organisationTitleField
                    KeyNavigation.down: urlField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(organisationTitleField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Url")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: urlField
                    KeyNavigation.down: hobbyField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(urlField)
                        }
                    }
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Hobby")
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: hobbyField
                    KeyNavigation.down: noteField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(hobbyField)
                        }
                    }
                }
                //Maybe disabled note section as not working
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Note")
                    Layout.alignment: Qt.AlignRight
                }
                TextArea {
                    id: noteField
                    Layout.fillWidth: true
                    onFocusChanged: {
                        if (activeFocus) {
                            makeItemVisible(noteField)
                        }
                    }
                }
                Item {
                    height: app.appFontSize/2
                    Layout.columnSpan: 2
                }
            }
        }

        Keys.onPressed: {
            console.log("key:"+event.key + ", aFIp:"+activeFocusItem.parent + ", aFI: "+activeFocusItem)
            if (event.key === Qt.Key_Escape) {
                editContactDialog.close();
            }
        }

        Column {
            id: okCancelButtonsColumn
            spacing: app.appFontSize
            anchors.margins: app.appFontSize/2
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            ZoomButton {
                id: cancelButton
                text: i18n.tr("Cancel (esc)")
                activeFocusOnTab: true
                activeFocusOnPress: true
                onClicked: {
                    editContactDialog.close()
                }
                Keys.onEnterPressed: {
                    editContactDialog.close()
                }
                Keys.onReturnPressed: {
                    editContactDialog.close()
                }
                KeyNavigation.down: okButton
            }
            ZoomButton {
                id: okButton
                text: i18n.tr("OK (ctrl-s)")
                activeFocusOnTab: true
                activeFocusOnPress: true
                onClicked: {
                    saveContact();
                    editContactDialog.close()
                }
                Keys.onEnterPressed: {
                    saveContact();
                    editContactDialog.close()
                }
                Keys.onReturnPressed: {
                    saveContact();
                    editContactDialog.close()
                }
            }
        }
    }

    Rectangle {
        id: focusShade
        anchors.fill: parent
        opacity: datePicker.visible ? 0.5 : 0
        color: "black"

        Behavior on opacity {
            NumberAnimation {
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: parent.opacity > 0
            onClicked: datePicker.visible = false
        }
    }

    Calendar {
        id: datePicker
        visible: false
        z: focusShade.z + 1
        width: height
        height: parent.height * 0.9
        anchors.centerIn: parent
        focus: visible
        onClicked: visible = false
        Keys.onBackPressed: {
            event.accepted = true;
            visible = false;
        }
        Keys.onPressed: {
            if ((event.key === Qt.Key_Space) || (event.key === Qt.Key_Return) || (event.key === Qt.Key_Enter)) {
                event.accepted = true;
                visible = false;
            } else if (event.key === Qt.Key_Escape) {
                selectedDate =  Date.fromLocaleDateString(Qt.locale(), birthdayField.text, Locale.ShortFormat);
                event.accepted = true;
                visible = false;
            }
        }
        onVisibleChanged: {
            if (!visible) {
                birthdayField.text = selectedDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
                birthdayField.forceActiveFocus();
            }
        }
    }

    Shortcut {
        sequence: "Ctrl+s"
        onActivated: {
            saveContact();
            editContactDialog.close()
        }
    }

    Component.onCompleted: {
        if (contactObject === undefined) {
            console.log("Attempted to edit an undefined contact");
            return;
        } else if (contactObject) {
            edit(contactObject);
        }

        firstNameField.forceActiveFocus();
    }
}
