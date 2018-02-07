import QtQuick 2.7
import QtContacts 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import org.gka.GKAToolkit 1.0
import "dateExt.js" as DateExt

FocusScope {
    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }
    anchors.fill: parent

    property var contactSelected
    property bool pickingContact: true
    property int gridItemSelected: 0

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

    function getPhoneNumberOfType(contact, type, context) {
        if (contact !== undefined && contact && contact.phoneNumbers) {
            for (var i=0; i < contact.phoneNumbers.length ; ++i) {
                var phoneNumber = contact.phoneNumbers[i];
                if (phoneNumber.subTypes.indexOf(type)> -1) {
                    if (phoneNumber.contexts.indexOf(context)> -1 || (phoneNumber.contexts.length === 0 && context===ContactDetail.ContextHome)) {
                        return phoneNumber.number;
                    }
                }
            }
        }
        return false;
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

    function getAddress(contact, context) {
        var ret = "";
        if (contact !== undefined && contact && contact.addresses) {
            var address = getAddressObject(contact, context)
            var parts = [address.postOfficeBox,address.street,address.locality,address.region,address.postcode,address.country];
            for (var i=0; i < parts.length ; ++i) {
                var part = parts[i];
                if (part) {
                    if (ret.length > 0) {
                        ret += ", ";
                    }
                    ret += part;
                }
            }
        }
        return ret;
    }

    function getOrganisation(contact) {
        var ret = "";
        if (contact !== undefined && contact && contact.organization && contact.organization) {
            var parts = [contact.organization.name,contact.organization.role,contact.organization.title];
            for (var i=0; i < parts.length ; ++i) {
                var part = parts[i];
                if (part) {
                    if (ret.length > 0) {
                        ret += ", ";
                    }
                    ret += part;
                }
            }
        }
        return ret;
    }

    Column {
        id: listingColumn
        spacing: app.appFontSize

        Rectangle {
            border.color: "black"
            border.width: Math.floor(app.appFontSize/10)
            width: (mainView.width/3)-app.appFontSize
            height: mainView.height - searchField.height - app.appFontSize*2
            x: app.appFontSize
            y: app.appFontSize

            ListView {
                id: contactsListView
                anchors.fill: parent
                model: contactsModel
                clip: true
                interactive: contactsListView.contentHeight > height

                delegate: ContactsItem {
                }

                onFocusChanged: {
                    if (activeFocus) {
                        searchField.forceActiveFocus();
                    }
                }
            }
        }

        TextField {
            id: searchField
            anchors {
                leftMargin: app.appFontSize
                left: parent.left
                right: parent.right
            }
            placeholderText: i18n.tr("Filter Contacts")
            font.pixelSize: app.appFontSize

            onTextChanged: {
                idleSearch.restart()
            }

            onFocusChanged: {
                pickingContact = activeFocus;
            }

            Keys.onEnterPressed: {
                contactsModel.filterTerm = searchField.text
            }
        }
    }

    Rectangle {
        id: contactsRectangle
        x: listingColumn.width + app.appFontSize*2
        width: mainView.width - listingColumn.width - app.appFontSize*3
        height: mainView.height - app.appFontSize
        border.color: contactGrid.activeFocus ? sysPalette.highlight : "#999"
        border.width: Math.floor(app.appFontSize/10)
        color: "#edeeef"

        ScrollView {
            id: personalScrollview
            anchors.fill: parent

            GridLayout {
                id: contactGrid
                width: personalScrollview.viewport.width - app.appFontSize
                columns: 2
                columnSpacing: 1//app.appFontSize

                ZoomLabel {
                    id: firstNameLabel
                    topPadding: app.appFontSize/2
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("First Name")
                    visible: firstNameValueLabel.visible
                    Layout.alignment: Qt.AlignRight
                }
                ZoomTextFieldReadOnly {
                    id: firstNameValueLabel
                    visible: contactSelected !== undefined && contactSelected && contactSelected.name && contactSelected.name.firstName
                    text: contactSelected !== undefined && contactSelected && contactSelected.name ? contactSelected.name.firstName : ""
                    KeyNavigation.down: middleNameValueLabel
                    KeyNavigation.right: searchField
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Middle Name")
                    visible: middleNameValueLabel.visible
                    Layout.alignment: Qt.AlignRight
                }
                ZoomTextFieldReadOnly {
                    id: middleNameValueLabel
                    visible: contactSelected !== undefined && contactSelected && contactSelected.name && contactSelected.name.middleName
                    text: contactSelected !== undefined && contactSelected && contactSelected.name ? contactSelected.name.middleName : ""
                    KeyNavigation.down: lastNameValueLabel
                    KeyNavigation.right: searchField
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Last Name")
                    visible: lastNameValueLabel.visible
                    Layout.alignment: Qt.AlignRight
                }
                ZoomTextFieldReadOnly {
                    id: lastNameValueLabel
                    visible: contactSelected !== undefined && contactSelected && contactSelected.name && contactSelected.name.lastName
                    text: contactSelected !== undefined && contactSelected && contactSelected.name ? contactSelected.name.lastName : ""
                    KeyNavigation.down: emailValueLabel
                    KeyNavigation.right: searchField
                }
                ZoomLabel {
                    text: i18n.tr("Email")
                    visible: emailValueLabel.visible
                    Layout.alignment: Qt.AlignRight
                }
                ZoomTextFieldReadOnly {
                    id: emailValueLabel
                    visible: contactSelected !== undefined && contactSelected && contactSelected.email && contactSelected.email.emailAddress
                    text: contactSelected !== undefined && contactSelected && contactSelected.email ? contactSelected.email.emailAddress : ""
                    KeyNavigation.down: homePhoneValueLabel
                    KeyNavigation.right: searchField
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Mobile")
                    visible: homePhoneValueLabel.visible
                    Layout.alignment: Qt.AlignRight
                }
                ZoomTextFieldReadOnly {
                    id: homePhoneValueLabel
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile, ContactDetail.ContextHome)
                    text: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile, ContactDetail.ContextHome)
                    KeyNavigation.down: homeVoiceValueLabel
                    KeyNavigation.right: searchField
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Voice")
                    visible: homeVoiceValueLabel.visible
                    Layout.alignment: Qt.AlignRight
                }
                ZoomTextFieldReadOnly {
                    id: homeVoiceValueLabel
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Voice, ContactDetail.ContextHome)
                    text: getPhoneNumberOfType(contactSelected, PhoneNumber.Voice, ContactDetail.ContextHome)
                    KeyNavigation.down: addressValueLabel
                    KeyNavigation.right: searchField
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Address")
                    visible:addressValueLabel.visible
                    Layout.alignment: Qt.AlignRight
                }
                ZoomTextFieldReadOnly {
                    id: addressValueLabel
                    implicitWidth: personalScrollview.viewport.width - addressValueLabel.x
                    visible: getAddress(contactSelected, ContactDetail.ContextHome)
                    text: getAddress(contactSelected, ContactDetail.ContextHome)
                    wrapMode: Label.Wrap
                    KeyNavigation.down: workMobileValueLabel
                    KeyNavigation.right: searchField
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    topPadding: app.appFontSize/3
                    text: i18n.tr("Work")
                    visible: workMobileValueLabel.visible || workVoiceValueLabel.visible || workAddressValueLabel.visible || organisationValueLabel.visible
                    Layout.columnSpan: 2
                    color: "#2980b9"
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Mobile")
                    visible: workMobileValueLabel.visible
                    Layout.alignment: Qt.AlignRight
                }
                ZoomTextFieldReadOnly {
                    id: workMobileValueLabel
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile, ContactDetail.ContextWork)
                    text: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile, ContactDetail.ContextWork)
                    KeyNavigation.down: workVoiceValueLabel
                    KeyNavigation.right: searchField
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Voice")
                    visible: workVoiceValueLabel.visible
                    Layout.alignment: Qt.AlignRight
                }
                ZoomTextFieldReadOnly {
                    id: workVoiceValueLabel
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Voice, ContactDetail.ContextWork)
                    text: getPhoneNumberOfType(contactSelected, PhoneNumber.Voice, ContactDetail.ContextWork)
                    KeyNavigation.down: workAddressValueLabel
                    KeyNavigation.right: searchField
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Address")
                    visible: workAddressValueLabel.visible
                    Layout.alignment: Qt.AlignRight
                }
                ZoomTextFieldReadOnly {
                    id: workAddressValueLabel
                    implicitWidth: personalScrollview.viewport.width - workAddressValueLabel.x
                    visible: getAddress(contactSelected, ContactDetail.ContextWork)
                    text: getAddress(contactSelected, ContactDetail.ContextWork)
                    wrapMode: Label.Wrap
                    KeyNavigation.down: organisationValueLabel
                    KeyNavigation.right: searchField
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Organisation")
                    visible: organisationValueLabel.visible
                    Layout.alignment: Qt.AlignRight
                }
                ZoomTextFieldReadOnly {
                    id: organisationValueLabel
                    visible: getOrganisation(contactSelected)
                    text: getOrganisation(contactSelected)
                    KeyNavigation.down: otherMobileValueLabel
                    KeyNavigation.right: searchField
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    topPadding: app.appFontSize/3
                    text: i18n.tr("Other")
                    visible: otherMobileValueLabel.visible || otherVoiceValueLabel.visible || otherAddressValueLabel.visible
                    Layout.columnSpan: 2
                    color: "#2980b9"
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Mobile")
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile, ContactDetail.ContextOther)
                    Layout.alignment: Qt.AlignRight
                }
                ZoomTextFieldReadOnly {
                    id: otherMobileValueLabel
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile, ContactDetail.ContextOther)
                    text: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile, ContactDetail.ContextOther)
                    KeyNavigation.down: otherVoiceValueLabel
                    KeyNavigation.right: searchField
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Voice")
                    visible: otherVoiceValueLabel.visible
                    Layout.alignment: Qt.AlignRight
                }
                ZoomTextFieldReadOnly {
                    id: otherVoiceValueLabel
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Voice, ContactDetail.ContextOther)
                    text: getPhoneNumberOfType(contactSelected, PhoneNumber.Voice, ContactDetail.ContextOther)
                    KeyNavigation.down: otherAddressValueLabel
                    KeyNavigation.right: searchField
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Address")
                    visible: otherAddressValueLabel.visible
                    Layout.alignment: Qt.AlignRight
                }
                ZoomTextFieldReadOnly {
                    id: otherAddressValueLabel
                    implicitWidth: personalScrollview.viewport.width - otherAddressValueLabel.x
                    visible: getAddress(contactSelected, ContactDetail.ContextOther)
                    text: getAddress(contactSelected, ContactDetail.ContextOther)
                    wrapMode: Text.Wrap
                    KeyNavigation.down: urlValueLabel
                    KeyNavigation.right: searchField
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    topPadding: app.appFontSize/3
                    text: i18n.tr("Personal")
                    visible: urlValueLabel.visible || birthdayValueLabel.visible || noteValueLabel.visible
                    Layout.columnSpan: 2
                    color: "#2980b9"
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Url")
                    visible: urlValueLabel.visible
                    Layout.alignment: Qt.AlignRight
                }
                ZoomTextFieldReadOnly {
                    id: urlValueLabel
                    visible: contactSelected !== undefined && contactSelected && contactSelected.url && contactSelected.url.url
                    text: contactSelected !== undefined && contactSelected && contactSelected.url ? contactSelected.url.url : ""
                    KeyNavigation.down: birthdayValueLabel
                    KeyNavigation.right: searchField
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Birthday")
                    visible: birthdayValueLabel.visible
                    Layout.alignment: Qt.AlignRight
                }
                ZoomTextFieldReadOnly {
                    id: birthdayValueLabel
                    visible: contactSelected !== undefined && contactSelected && contactSelected.birthday && contactSelected.birthday.birthday.isValid()
                    text: contactSelected !== undefined && contactSelected && contactSelected.birthday ? contactSelected.birthday.birthday.toLocaleDateString(Qt.locale(), Locale.ShortFormat) : ""
                    KeyNavigation.down: noteValueLabel
                    KeyNavigation.right: searchField
                }
                //Disabled note section as not working
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Note")
                    visible: noteValueLabel.visible
                    Layout.alignment: Qt.AlignRight
                }
                ZoomTextFieldReadOnly {
                    id: noteValueLabel
                    implicitWidth: personalScrollview.viewport.width - noteValueLabel.x
                    visible: contactSelected !== undefined && contactSelected && contactSelected.note !== undefined && contactSelected.note.note
                    text: contactSelected !== undefined && contactSelected && contactSelected.note ? contactSelected.note.note : ""
                    wrapMode: Text.Wrap
                    KeyNavigation.right: searchField
                }
            }
        }
    }

    Timer {
        id: idleSearch

        interval: 500
        repeat: false
        onTriggered: {

            contactsModel.filterTerm = searchField.text
            console.log("IdleSearch"+contactsModel.filterTerm)
        }
    }

    TextField {
        id: hiddenTextField
        visible: false
    }

    Keys.onPressed: {
        console.log("key:"+event.key + ", aFIp:"+activeFocusItem.parent + ", aFI: "+activeFocusItem)
        if (event.key === Qt.Key_Left) {
            searchField.forceActiveFocus();
            pickingContact = true;
        }
        if (event.key === Qt.Key_Right) {
            firstNameValueLabel.forceActiveFocus();
            pickingContact = false
        }
        if (event.key === Qt.Key_Up) {
            if (!pickingContact) {

            } else {
                if (contactsListView.currentIndex > 0) {
                    contactsListView.currentIndex--;
                }
            }
        }
        if (event.key === Qt.Key_Down) {
            if (!pickingContact) {

            } else {
                if (contactsListView.currentIndex < contactsListView.count-1) {
                    contactsListView.currentIndex++;
                }
            }
        }
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            dialogLoader.setSource("EditContactDialog.qml", {"model":contactsModel, "contactObject":contactSelected});
        }
    }

    Component.onCompleted: {
        searchField.forceActiveFocus();

        contactsModel.fetchCollections();

        console.log("collections: "+contactsModel.collections.length);
        console.log("contacts: "+contactsModel.contacts.length);
        for (var i=0; i<contactsModel.collections; i++) {
            console.log("collections: "+contactsModel.collections[i]);
        }
        console.log("error: "+contactsModel.error);
    }

}
