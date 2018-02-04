import QtQuick 2.7
import QtContacts 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import org.gka.GKAToolkit 1.0
import "dateExt.js" as DateExt

FocusScope {
    anchors.fill: parent

    property var contactSelected

    function getPhoneNumberOfType(contact, type, context) {
        if (contact.phoneNumbers) {
            for (var i=0; i < contact.phoneNumbers.length ; ++i) {
                var phoneNumber = contact.phoneNumbers[i];
                console.log(phoneNumber.number+" "+phoneNumber.contexts.indexOf(context)+ " " + context+" "+phoneNumber.subTypes.indexOf(type)+ " " + type);
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
                console.log(address.contexts.indexOf(context)+ " " + context);
                if (address.contexts.indexOf(context)> -1) {
                    return address;
                }
            }
        }
        return false;
    }

    function getAddress(contact, context) {
        var ret = "";
        if (contact.addresses) {
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
        if (contact.organization && contact.organization) {
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

            Keys.onEnterPressed: {
                filter.searchString = searchField.text
            }
        }
    }

    Rectangle {
        id: contactsRectangle
        x: listingColumn.width + app.appFontSize*2
        width: mainView.width - listingColumn.width - app.appFontSize*3
        height: mainView.height - app.appFontSize
        border.color: contactGrid.activeFocus ? "black" : "grey"
        border.width: Math.floor(app.appFontSize/10)
        color: "#edeeef"

        ScrollView {
            id: personalScrollview
            anchors.fill: parent

            GridLayout {
                id: contactGrid
                columns: 2
                columnSpacing: app.appFontSize

                ZoomLabel {
                    id: firstNameLabel
                    topPadding: app.appFontSize/2
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("First Name")
                    visible: contactSelected && contactSelected.name && contactSelected.name.firstName
                    Layout.alignment: Qt.AlignRight
                }
                ZoomLabel {
                    id: firstNameValueLabel
                    topPadding: app.appFontSize/2
                    visible: contactSelected && contactSelected.name && contactSelected.name.firstName
                    text: contactSelected && contactSelected.name ? contactSelected.name.firstName : ""
                }
                ZoomLabel {
                    id: middleNameLabel
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Middle Name")
                    visible: contactSelected && contactSelected.name && contactSelected.name.middleName
                    Layout.alignment: Qt.AlignRight
                }
                ZoomLabel {
                    id: middleNameValueLabel
                    visible: contactSelected && contactSelected.name && contactSelected.name.middleName
                    text: contactSelected && contactSelected.name ? contactSelected.name.middleName : ""
                }
                ZoomLabel {
                    id: lastNameLabel
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Last Name")
                    visible: contactSelected && contactSelected.name && contactSelected.name.lastName
                    Layout.alignment: Qt.AlignRight
                }
                ZoomLabel {
                    id: lastNameValueLabel
                    visible: contactSelected && contactSelected.name && contactSelected.name.lastName
                    text: contactSelected && contactSelected.name ? contactSelected.name.lastName : ""
                }
                ZoomLabel {
                    text: i18n.tr("Email")
                    visible: contactSelected && contactSelected.email && contactSelected.email.emailAddress
                    Layout.alignment: Qt.AlignRight
                }
                ZoomLabel {
                    visible: contactSelected && contactSelected.email && contactSelected.email.emailAddress
                    text: contactSelected && contactSelected.email ? contactSelected.email.emailAddress : ""
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Mobile")
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile, ContactDetail.ContextHome)
                    Layout.alignment: Qt.AlignRight
                }
                ZoomLabel {
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile, ContactDetail.ContextHome)
                    text: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile, ContactDetail.ContextHome)
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Voice")
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Voice, ContactDetail.ContextHome)
                    Layout.alignment: Qt.AlignRight
                }
                ZoomLabel {
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Voice, ContactDetail.ContextHome)
                    text: getPhoneNumberOfType(contactSelected, PhoneNumber.Voice, ContactDetail.ContextHome)
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Address")
                    visible: getAddress(contactSelected, ContactDetail.ContextHome)
                    Layout.alignment: Qt.AlignRight
                }
                ZoomLabel {
                    visible: getAddress(contactSelected, ContactDetail.ContextHome)
                    text: getAddress(contactSelected, ContactDetail.ContextHome)
                    wrapMode: Text.Wrap
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    topPadding: app.appFontSize/3
                    text: i18n.tr("Work")
                    visible: workMobileLabel.visible || workVoiceLabel.visible || workAddressLabel.visible || organisationValueLabel.visible
                    Layout.columnSpan: 2
                    color: "#2980b9"
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Mobile")
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile, ContactDetail.ContextWork)
                    Layout.alignment: Qt.AlignRight
                }
                ZoomLabel {
                    id: workMobileLabel
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile, ContactDetail.ContextWork)
                    text: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile, ContactDetail.ContextWork)
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Voice")
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Voice, ContactDetail.ContextWork)
                    Layout.alignment: Qt.AlignRight
                }
                ZoomLabel {
                    id: workVoiceLabel
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Voice, ContactDetail.ContextWork)
                    text: getPhoneNumberOfType(contactSelected, PhoneNumber.Voice, ContactDetail.ContextWork)
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Address")
                    visible: getAddress(contactSelected, ContactDetail.ContextWork)
                    Layout.alignment: Qt.AlignRight
                }
                ZoomLabel {
                    id: workAddressLabel
                    visible: getAddress(contactSelected, ContactDetail.ContextWork)
                    text: getAddress(contactSelected, ContactDetail.ContextWork)
                    wrapMode: Text.Wrap
                }
                ZoomLabel {
                    id: organisationLabel
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Organisation")
                    visible: getOrganisation(contactSelected)
                    Layout.alignment: Qt.AlignRight
                }
                ZoomLabel {
                    id: organisationValueLabel
                    visible: getOrganisation(contactSelected)
                    text: getOrganisation(contactSelected)
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    topPadding: app.appFontSize/3
                    text: i18n.tr("Other")
                    visible: otherMobileLabel.visible || otherVoiceLabel.visible || otherAddressLabel.visible
                    Layout.columnSpan: 2
                    color: "#2980b9"
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Mobile")
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile, ContactDetail.ContextOther)
                    Layout.alignment: Qt.AlignRight
                }
                ZoomLabel {
                    id: otherMobileLabel
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile, ContactDetail.ContextOther)
                    text: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile, ContactDetail.ContextOther)
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Voice")
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Voice, ContactDetail.ContextOther)
                    Layout.alignment: Qt.AlignRight
                }
                ZoomLabel {
                    id: otherVoiceLabel
                    visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Voice, ContactDetail.ContextOther)
                    text: getPhoneNumberOfType(contactSelected, PhoneNumber.Voice, ContactDetail.ContextOther)
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Address")
                    visible: getAddress(contactSelected, ContactDetail.ContextOther)
                    Layout.alignment: Qt.AlignRight
                }
                ZoomLabel {
                    id: otherAddressLabel
                    visible: getAddress(contactSelected, ContactDetail.ContextOther)
                    text: getAddress(contactSelected, ContactDetail.ContextOther)
                    wrapMode: Text.Wrap
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    topPadding: app.appFontSize/3
                    text: i18n.tr("Personal")
                    visible: urlLabel.visible || hobbyLabel.visible || birthdayLabel.visible || noteLabel.visible
                    Layout.columnSpan: 2
                    color: "#2980b9"
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Url")
                    visible: contactSelected && contactSelected.url && contactSelected.url.url
                    Layout.alignment: Qt.AlignRight
                }
                ZoomLabel {
                    id: urlLabel
                    visible: contactSelected && contactSelected.url && contactSelected.url.url
                    text: contactSelected && contactSelected.url ? contactSelected.url.url : ""
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Hobby")
                    visible: contactSelected && contactSelected.hobby && contactSelected.hobby.hobby
                    Layout.alignment: Qt.AlignRight
                }
                ZoomLabel {
                    id: hobbyLabel
                    visible: contactSelected && contactSelected.hobby && contactSelected.hobby.hobby
                    text: contactSelected && contactSelected.hobby ? contactSelected.hobby.hobby : ""
                }
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Birthday")
                    visible: contactSelected && contactSelected.birthday && contactSelected.birthday.birthday.isValid()
                    Layout.alignment: Qt.AlignRight
                }
                ZoomLabel {
                    id: birthdayLabel
                    visible: contactSelected && contactSelected.birthday && contactSelected.birthday.birthday.isValid()
                    text: contactSelected && contactSelected.birthday ? contactSelected.birthday.birthday.toLocaleDateString(Qt.locale(), Locale.ShortFormat) : ""
                }
                //Disabled note section as not working
                ZoomLabel {
                    leftPadding: app.appFontSize/2
                    text: i18n.tr("Note")
                    visible: contactSelected && contactSelected.note && contactSelected.note.note
                    Layout.alignment: Qt.AlignRight
                }
                ZoomLabel {
                    id: noteLabel
                    visible: contactSelected && contactSelected.note && contactSelected.note.note
                    text: contactSelected && contactSelected.note ? contactSelected.note.note : ""
                    wrapMode: Text.Wrap
                }
            }
        }
    }

    Timer {
        id: idleSearch

        interval: 500
        repeat: false
        onTriggered: {
            filter.searchString = searchField.text
            console.log("ticker"+filter.searchString)
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
        }
        if (event.key === Qt.Key_Right) {
            contactGrid.forceActiveFocus();
        }
        if (event.key === Qt.Key_Up) {
            if (contactGrid.activeFocus) {

            } else {
                if (contactsListView.currentIndex > 0) {
                    contactsListView.currentIndex--;
                }
            }
        }
        if (event.key === Qt.Key_Down) {
            if (contactGrid.activeFocus) {

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
