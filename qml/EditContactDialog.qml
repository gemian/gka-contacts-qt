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
    property var model:null

    property int activeSectionIndex: 0
    property var localeDateInputMask: makeLocaleDateInputMask()

    function setCheckedButton(index) {
        activeSectionIndex = index;
        personalButton.checked = false
        workButton.checked = false
        otherButton.checked = false
        switch (index) {
        case 0:
            personalButton.checked = true
            break;
        case 1:
            workButton.checked = true
            break;
        case 2:
            otherButton.checked = true
            break;
        }
    }

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

    function makeItemVisible(item, scrollView) {
        if (!item) {
            return;
        }

        // check if visible
        var bottomY = scrollView.flickableItem.contentY + scrollView.flickableItem.height
        var itemBottom = item.y + (item.height * 3)
        if (item.y >= scrollView.flickableItem.contentY && itemBottom <= bottomY) {
            return;
        }

        // if it is not, try to scroll and make it visible
        var targetY = itemBottom - scrollView.flickableItem.height
        if (targetY >= 0 && item.y) {
            if (targetY > scrollView.contentItem.height-scrollView.flickableItem.height) {
                targetY = scrollView.contentItem.height-scrollView.flickableItem.height;
            }
            scrollView.flickableItem.contentY = targetY;
        } else if (item.y < scrollView.flickableItem.contentY) {
            // if it is hidden at the top, also show it
            scrollView.flickableItem.contentY = item.y-app.appFontSize/2;
        }

        scrollView.flickableItem.returnToBounds();
    }

    function getAddressObject(contact, context) {
        if (contact.addresses) {
            for (var i=0; i < contact.addresses.length ; ++i) {
                var address = contact.addresses[i];
                if (address.contexts.indexOf(context)> -1) {
                    return address;
                }
            }
        }
        return false;
    }

    function setAddress(c, context, streetField, localityField, regionField, postcodeField, countryField, poBoxField) {
        if ((c.addresses && getAddressObject(c, context))
                || streetField.text.length > 0
                || localityField.text.length > 0
                || regionField.text.length > 0
                || postcodeField.text.length > 0
                || countryField.text.length > 0
                || poBoxField.text.length > 0) {
            var address = getAddressObject(c, context);
            if (address === false) {
                address = Qt.createQmlObject("import QtContacts 5.0; Address {}", c, "EditContactDialog.qml");
                address.street = streetField.text;
                address.locality = localityField.text;
                address.region = regionField.text;
                address.postcode = postcodeField.text;
                address.country = countryField.text;
                address.postOfficeBox = poBoxField.text;
                address.contexts = [context];
                c.addDetail(address);
            } else {
                address.street = streetField.text;
                address.locality = localityField.text;
                address.region = regionField.text;
                address.postcode = postcodeField.text;
                address.country = countryField.text;
                address.postOfficeBox = poBoxField.text;
            }
        }
    }

    function getPhoneNumberObjectOfType(contact, type, context) {
        if (contact.phoneNumbers) {
            for (var i=0; i < contact.phoneNumbers.length ; ++i) {
                var phoneNumber = contact.phoneNumbers[i];
//                console.log(phoneNumber.number+" "+phoneNumber.contexts.indexOf(context)+ " " + context+" "+phoneNumber.subTypes.indexOf(type)+ " " + type);
                if (phoneNumber.subTypes.indexOf(type)> -1) {
                    if (phoneNumber.contexts.indexOf(context)> -1 || (phoneNumber.contexts.length === 0 && context===ContactDetail.ContextHome)) {
                        return phoneNumber;
                    }
                }
            }
        }
        return false;
    }

    function getPhoneNumberOfType(contact, type, context) {
        var phoneNumberObject = getPhoneNumberObjectOfType(contact, type, context);
        if (phoneNumberObject) {
            return phoneNumberObject.number;
        }
        return false;
    }

    function setPhoneNumberOfTypeWithField(contact, type, context, field) {
        var phone = getPhoneNumberObjectOfType(contact, type, context);
//        console.log("setPhone" + phone);
        if (phone || field.text.length > 0) {
            if (phone) {
//                console.log("setPhone - update"+field.text);
                phone.number = field.text;
            } else {
//                console.log("setPhone - new"+field.text);
                phone = Qt.createQmlObject("import QtContacts 5.0; PhoneNumber {}", contact, "EditContactDialog.qml");
                phone.number = field.text;
                phone.subTypes = [type];
                phone.contexts = [context];
                contact.addDetail(phone);
            }
        }
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
        if (getPhoneNumberOfType(c, PhoneNumber.Mobile, ContactDetail.ContextHome)) {
            mobilePhoneNumberField.text = getPhoneNumberOfType(c, PhoneNumber.Mobile, ContactDetail.ContextHome);
        }
        if (getPhoneNumberOfType(c, PhoneNumber.Voice, ContactDetail.ContextHome)) {
            voicePhoneNumberField.text = getPhoneNumberOfType(c, PhoneNumber.Voice, ContactDetail.ContextHome);
        }

        if (c.addresses && getAddressObject(c, ContactDetail.ContextHome)) {
            var address = getAddressObject(c, ContactDetail.ContextHome);
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
        if (getPhoneNumberOfType(c, PhoneNumber.Mobile, ContactDetail.ContextWork)) {
            mobileWPhoneNumberField.text = getPhoneNumberOfType(c, PhoneNumber.Mobile, ContactDetail.ContextWork);
        }
        if (getPhoneNumberOfType(c, PhoneNumber.Voice, ContactDetail.ContextWork)) {
            voiceWPhoneNumberField.text = getPhoneNumberOfType(c, PhoneNumber.Voice, ContactDetail.ContextWork);
        }
        if (c.addresses && getAddressObject(c, ContactDetail.ContextWork)) {
            var addressW = getAddressObject(c, ContactDetail.ContextWork);
            if (addressW.street) {
                addressWStreetField.text = addressW.street;
            }
            if (addressW.locality) {
                addressWLocalityField.text = addressW.locality;
            }
            if (addressW.region) {
                addressWRegionField.text = addressW.region;
            }
            if (addressW.postcode) {
                addressWPostcodeField.text = addressW.postcode;
            }
            if (addressW.country) {
                addressWCountryField.text = addressW.country;
            }
            if (addressW.postOfficeBox) {
                addressWPostOfficeBoxField.text = addressW.postOfficeBox;
            }
        }
        if (getPhoneNumberOfType(c, PhoneNumber.Mobile, ContactDetail.ContextOther)) {
            mobileOPhoneNumberField.text = getPhoneNumberOfType(c, PhoneNumber.Mobile, ContactDetail.ContextOther);
        }
        if (getPhoneNumberOfType(c, PhoneNumber.Voice, ContactDetail.ContextOther)) {
            voiceOPhoneNumberField.text = getPhoneNumberOfType(c, PhoneNumber.Voice, ContactDetail.ContextOther);
        }
        if (c.addresses && getAddressObject(c, ContactDetail.ContextOther)) {
            var addressO = getAddressObject(c, ContactDetail.ContextOther);
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
        if (c.organization) {
            if (c.organization.name) {
                organisationNameField.text = c.organization.name;
            }
            if (c.organization.role) {
                organisationRoleField.text = c.organization.role;
            }
            if (c.organization.title) {
                organisationTitleField.text = c.organization.title;
            }
        }
        if (c.url && c.url.url) {
            urlField.text = c.url.url;
        }
        if (c.note && c.note.note) {
            noteField.text = c.note.note;
        }
    }

    function saveContact() {
        if (!contactObject) {
            contactObject = Qt.createQmlObject("import QtContacts 5.0; Contact {}", Qt.application, "EditContactDialog.qml");
        }

        contactObject.name.firstName = firstNameField.text;
        contactObject.name.middleName = middleNameField.text;
        contactObject.name.lastName = lastNameField.text;
        contactObject.email.emailAddress = emailAddressField.text;

        setPhoneNumberOfTypeWithField(contactObject, PhoneNumber.Mobile, ContactDetail.ContextHome, mobilePhoneNumberField);
        setPhoneNumberOfTypeWithField(contactObject, PhoneNumber.Voice, ContactDetail.ContextHome, voicePhoneNumberField);

        setAddress(contactObject, ContactDetail.ContextHome, addressStreetField, addressLocalityField, addressRegionField, addressPostcodeField, addressCountryField, addressPostOfficeBoxField);

        setPhoneNumberOfTypeWithField(contactObject, PhoneNumber.Mobile, ContactDetail.ContextWork, mobileWPhoneNumberField);
        setPhoneNumberOfTypeWithField(contactObject, PhoneNumber.Voice, ContactDetail.ContextWork, voiceWPhoneNumberField);

        setAddress(contactObject, ContactDetail.ContextWork, addressWStreetField, addressWLocalityField, addressWRegionField, addressWPostcodeField, addressWCountryField, addressWPostOfficeBoxField);

        setPhoneNumberOfTypeWithField(contactObject, PhoneNumber.Mobile, ContactDetail.ContextOther, mobileOPhoneNumberField);
        setPhoneNumberOfTypeWithField(contactObject, PhoneNumber.Voice, ContactDetail.ContextOther, voiceOPhoneNumberField);

        setAddress(contactObject, ContactDetail.ContextOther, addressOStreetField, addressOLocalityField, addressORegionField, addressOPostcodeField, addressOCountryField, addressOPostOfficeBoxField);

        var birthday = Date.fromLocaleDateString(Qt.locale(), birthdayField.text, Locale.ShortFormat);
        if (birthday.isValid()) {
            contactObject.birthday.birthday = birthday;
        } else {
            contactObject.birthday.birthday = "";
        }
        contactObject.organization.name = organisationNameField.text;
        contactObject.organization.role = organisationRoleField.text;
        contactObject.organization.title = organisationTitleField.text;
        contactObject.url.url = urlField.text;

        contactObject.note.note = noteField.text;

        model.saveContact(contactObject)
    }

    Rectangle {
        id: dialogRectangle
        width: editContactDialog.width
        height: editContactDialog.height
        border.color: "black"
        border.width: Math.floor(app.appFontSize/10)
        color: "#edeeef"

        Column {
            id: extrasColumn
            spacing: app.appFontSize
            width: dialogRectangle.width - okCancelButtonsColumn.width - app.appFontSize

            Row {
                id: sectionButtonsRow
                spacing: app.appFontSize
                topPadding: app.appFontSize
                leftPadding: app.appFontSize

                ZoomButton {
                    id: personalButton
                    activeFocusOnTab: true
                    activeFocusOnPress: true
                    checkable: true
                    text: i18n.tr("Personal (ctrl-p)")
                    onClicked: {
                        setCheckedButton(0);
                    }
                    onFocusChanged: {
                        if (activeFocus) {
                            setCheckedButton(0);
                        }
                    }
                    KeyNavigation.right: workButton
                    KeyNavigation.down: firstNameField
                }
                ZoomButton {
                    id: workButton
                    activeFocusOnTab: true
                    activeFocusOnPress: true
                    checkable: true
                    text: i18n.tr("Work (ctrl-w)")
                    onClicked: {
                        setCheckedButton(1);
                    }
                    onFocusChanged: {
                        if (activeFocus) {
                            setCheckedButton(1);
                        }
                    }
                    KeyNavigation.right: otherButton
                    KeyNavigation.down: mobileWPhoneNumberField
                }
                ZoomButton {
                    id: otherButton
                    checkable: true
                    activeFocusOnTab: true
                    activeFocusOnPress: true
                    text: i18n.tr("Other (ctrl-o)")
                    onClicked: {
                        setCheckedButton(2);
                    }
                    onFocusChanged: {
                        if (activeFocus) {
                            setCheckedButton(2);
                        }
                    }
                    KeyNavigation.down: mobileOPhoneNumberField
                }
            }

            ScrollView {
                id: personalScrollview
                width: extrasColumn.width
                height: dialogRectangle.height - sectionButtonsRow.height
                visible: activeSectionIndex===0

                GridLayout {
                    id: personalGrid
                    width: personalScrollview.viewport.width
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
                        KeyNavigation.down: middleNameField
                        Layout.fillWidth: true
                        focus: true
                        onFocusChanged: {
                            if (activeFocus) {
                                makeItemVisible(firstNameField, personalScrollview)
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
                                makeItemVisible(middleNameField, personalScrollview)
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
                                makeItemVisible(lastNameField, personalScrollview)
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
                                makeItemVisible(emailAddressField, personalScrollview)
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
                                makeItemVisible(mobilePhoneNumberField, personalScrollview)
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
                                makeItemVisible(voicePhoneNumberField, personalScrollview)
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
                                makeItemVisible(addressStreetField, personalScrollview)
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
                                makeItemVisible(addressLocalityField, personalScrollview)
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
                                makeItemVisible(addressRegionField, personalScrollview)
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
                                makeItemVisible(addressPostcodeField, personalScrollview)
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
                                makeItemVisible(addressCountryField, personalScrollview)
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
                        KeyNavigation.down: birthdayField
                        Layout.fillWidth: true
                        onFocusChanged: {
                            if (activeFocus) {
                                makeItemVisible(addressPostOfficeBoxField, personalScrollview)
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
                                makeItemVisible(birthdayField, personalScrollview)
                            } else {
                                var birthday = Date.fromLocaleDateString(Qt.locale(), text, Locale.ShortFormat);
                                if (birthday.isValid()) {
                                    text = birthday.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var date = Date.fromLocaleDateString(Qt.locale(), birthdayField.text, Locale.ShortFormat);
                                if (date.isValid()) {
                                    datePicker.selectedDate = Date.fromLocaleDateString(Qt.locale(), birthdayField.text, Locale.ShortFormat);
                                } else {
                                    datePicker.selectedDate = new Date()
                                }
                                datePicker.visible = true;
                            }
                        }
                        Keys.onPressed: {
                            if (event.key === Qt.Key_Tab || event.key === Qt.Key_Space) {
                                console.log("key Tab");
                                var date = Date.fromLocaleDateString(Qt.locale(), birthdayField.text, Locale.ShortFormat);
                                if (date.isValid()) {
                                    datePicker.selectedDate = Date.fromLocaleDateString(Qt.locale(), birthdayField.text, Locale.ShortFormat);
                                } else {
                                    datePicker.selectedDate = new Date()
                                }
                                datePicker.visible = true;
                                event.accepted = true;
                            }
                        }
                        KeyNavigation.down: urlField
                    }
                    ZoomLabel {
                        leftPadding: app.appFontSize/2
                        text: i18n.tr("Url")
                        Layout.alignment: Qt.AlignRight
                    }
                    TextField {
                        id: urlField
                        KeyNavigation.down: noteField
                        Layout.fillWidth: true
                        onFocusChanged: {
                            if (activeFocus) {
                                makeItemVisible(urlField, personalScrollview)
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
                                makeItemVisible(noteField, personalScrollview)
                            }
                        }
                    }
                    Item {
                        height: app.appFontSize/2
                        Layout.columnSpan: 2
                    }
                    Keys.onReturnPressed: {
                        for (var i = 0; i < children.length; ++i) {
                            if (children[i].focus) {
                                children[i].nextItemInFocusChain().forceActiveFocus();
                                break;
                            }
                        }
                    }
                }
            }

            ScrollView {
                id: workScrollview
                width: extrasColumn.width
                height: dialogRectangle.height - sectionButtonsRow.height
                visible: activeSectionIndex===1

                GridLayout {
                    id: workGrid
                    width: workScrollview.viewport.width
                    columns: 2
                    columnSpacing: app.appFontSize
                    Layout.topMargin: app.appFontSize

                    ZoomLabel {
                        leftPadding: app.appFontSize/2
                        text: i18n.tr("Mobile")
                        Layout.alignment: Qt.AlignRight
                    }
                    TextField {
                        id: mobileWPhoneNumberField
                        KeyNavigation.down: voiceWPhoneNumberField
                        Layout.fillWidth: true
                        onFocusChanged: {
                            if (activeFocus) {
                                makeItemVisible(mobileWPhoneNumberField, workScrollview)
                            }
                        }
                    }
                    ZoomLabel {
                        leftPadding: app.appFontSize/2
                        text: i18n.tr("Voice")
                        Layout.alignment: Qt.AlignRight
                    }
                    TextField {
                        id: voiceWPhoneNumberField
                        KeyNavigation.down: addressWStreetField
                        Layout.fillWidth: true
                        onFocusChanged: {
                            if (activeFocus) {
                                makeItemVisible(voiceWPhoneNumberField, workScrollview)
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
                        id: addressWStreetField
                        KeyNavigation.down: addressWLocalityField
                        Layout.fillWidth: true
                        onFocusChanged: {
                            if (activeFocus) {
                                makeItemVisible(addressWStreetField, workScrollview)
                            }
                        }
                    }
                    ZoomLabel {
                        leftPadding: app.appFontSize/2
                        text: i18n.tr("Locality")
                        Layout.alignment: Qt.AlignRight
                    }
                    TextField {
                        id: addressWLocalityField
                        KeyNavigation.down: addressWRegionField
                        Layout.fillWidth: true
                        onFocusChanged: {
                            if (activeFocus) {
                                makeItemVisible(addressWLocalityField, workScrollview)
                            }
                        }
                    }
                    ZoomLabel {
                        leftPadding: app.appFontSize/2
                        text: i18n.tr("Region")
                        Layout.alignment: Qt.AlignRight
                    }
                    TextField {
                        id: addressWRegionField
                        KeyNavigation.down: addressWPostcodeField
                        Layout.fillWidth: true
                        onFocusChanged: {
                            if (activeFocus) {
                                makeItemVisible(addressWRegionField, workScrollview)
                            }
                        }
                    }
                    ZoomLabel {
                        leftPadding: app.appFontSize/2
                        text: i18n.tr("Postcode")
                        Layout.alignment: Qt.AlignRight
                    }
                    TextField {
                        id: addressWPostcodeField
                        KeyNavigation.down: addressWCountryField
                        Layout.fillWidth: true
                        onFocusChanged: {
                            if (activeFocus) {
                                makeItemVisible(addressWPostcodeField, workScrollview)
                            }
                        }
                    }
                    ZoomLabel {
                        leftPadding: app.appFontSize/2
                        text: i18n.tr("Country")
                        Layout.alignment: Qt.AlignRight
                    }
                    TextField {
                        id: addressWCountryField
                        KeyNavigation.down: addressWPostOfficeBoxField
                        Layout.fillWidth: true
                        onFocusChanged: {
                            if (activeFocus) {
                                makeItemVisible(addressWCountryField, workScrollview)
                            }
                        }
                    }
                    ZoomLabel {
                        leftPadding: app.appFontSize/2
                        text: i18n.tr("Post Office Box")
                        Layout.alignment: Qt.AlignRight
                    }
                    TextField {
                        id: addressWPostOfficeBoxField
                        KeyNavigation.down: organisationNameField
                        Layout.fillWidth: true
                        onFocusChanged: {
                            if (activeFocus) {
                                makeItemVisible(addressWPostOfficeBoxField, workScrollview)
                            }
                        }
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
                                makeItemVisible(organisationNameField, workScrollview)
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
                                makeItemVisible(organisationRoleField, workScrollview)
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
                        Layout.fillWidth: true
                        onFocusChanged: {
                            if (activeFocus) {
                                makeItemVisible(organisationTitleField, workScrollview)
                            }
                        }
                    }
                    Item {
                        height: app.appFontSize/2
                        Layout.columnSpan: 2
                    }
                }
            }

            ScrollView {
                id: otherScrollview
                width: extrasColumn.width
                height: dialogRectangle.height - sectionButtonsRow.height
                visible: activeSectionIndex===2

                GridLayout {
                    id: otherGrid
                    width: otherScrollview.viewport.width
                    columns: 2
                    columnSpacing: app.appFontSize
                    Layout.topMargin: app.appFontSize

                    ZoomLabel {
                        leftPadding: app.appFontSize/2
                        text: i18n.tr("Mobile")
                        Layout.alignment: Qt.AlignRight
                    }
                    TextField {
                        id: mobileOPhoneNumberField
                        KeyNavigation.down: voiceOPhoneNumberField
                        Layout.fillWidth: true
                        onFocusChanged: {
                            if (activeFocus) {
                                makeItemVisible(mobileOPhoneNumberField, otherScrollview)
                            }
                        }
                    }
                    ZoomLabel {
                        leftPadding: app.appFontSize/2
                        text: i18n.tr("Voice")
                        Layout.alignment: Qt.AlignRight
                    }
                    TextField {
                        id: voiceOPhoneNumberField
                        KeyNavigation.down: addressOStreetField
                        Layout.fillWidth: true
                        onFocusChanged: {
                            if (activeFocus) {
                                makeItemVisible(voiceOPhoneNumberField, otherScrollview)
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
                        id: addressOStreetField
                        KeyNavigation.down: addressOLocalityField
                        Layout.fillWidth: true
                        onFocusChanged: {
                            if (activeFocus) {
                                makeItemVisible(addressOStreetField, otherScrollview)
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
                                makeItemVisible(addressOLocalityField, otherScrollview)
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
                                makeItemVisible(addressORegionField, otherScrollview)
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
                                makeItemVisible(addressOPostcodeField, otherScrollview)
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
                                makeItemVisible(addressOCountryField, otherScrollview)
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
                        Layout.fillWidth: true
                        onFocusChanged: {
                            if (activeFocus) {
                                makeItemVisible(addressOPostOfficeBoxField, otherScrollview)
                            }
                        }
                    }
                    Item {
                        height: app.appFontSize/2
                        Layout.columnSpan: 2
                    }
                }
            }
        }

        Shortcut {
            sequence: "Ctrl+p"
            onActivated: {
                setCheckedButton(0);
                personalButton.forceActiveFocus();
            }
        }

        Shortcut {
            sequence: "Ctrl+w"
            onActivated: {
                setCheckedButton(1);
                workButton.forceActiveFocus();
            }
        }

        Shortcut {
            sequence: "Ctrl+o"
            onActivated: {
                setCheckedButton(2);
                otherButton.forceActiveFocus();
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
        onClicked: {
            if (date.isValid()) {
                birthdayField.text = date.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
            }
            visible = false
        }
        Keys.onBackPressed: {
            event.accepted = true;
            visible = false;
        }
        Keys.onPressed: {
            if ((event.key === Qt.Key_Space) || (event.key === Qt.Key_Return) || (event.key === Qt.Key_Enter)) {
                if (selectedDate.isValid()) {
                    birthdayField.text = selectedDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
                }
                event.accepted = true;
                visible = false;
            } else if (event.key === Qt.Key_Escape) {
                event.accepted = true;
                visible = false;
            }
        }
        onVisibleChanged: {
            if (!visible) {
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
