import QtQuick 2.7
import QtContacts 5.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import org.gka.GKAToolkit 1.0
import "dateExt.js" as DateExt

FocusScope {
    anchors.fill: parent

    property int contactsSelectedIndex: 1
    property var contactSelected

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

    function getAddress(contact, index) {
        var ret = "";
        if (contact.addresses && contact.addresses[index]) {
            var address = contact.addresses[index];
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
        x: listingColumn.width + app.appFontSize*2
        width: mainView.width - listingColumn.width - app.appFontSize*3
        height: mainView.height - app.appFontSize
        border.color: "black"
        border.width: Math.floor(app.appFontSize/10)
        color: "#edeeef"

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
                leftPadding: app.appFontSize/2
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
                visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile)
                Layout.alignment: Qt.AlignRight
            }
            ZoomLabel {
                visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile)
                text: getPhoneNumberOfType(contactSelected, PhoneNumber.Mobile)
            }
            ZoomLabel {
                leftPadding: app.appFontSize/2
                text: i18n.tr("Voice")
                visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Voice)
                Layout.alignment: Qt.AlignRight
            }
            ZoomLabel {
                visible: getPhoneNumberOfType(contactSelected, PhoneNumber.Voice)
                text: getPhoneNumberOfType(contactSelected, PhoneNumber.Voice)
            }
            ZoomLabel {
                leftPadding: app.appFontSize/2
                text: i18n.tr("Address")
                visible: getAddress(contactSelected, 0)
                Layout.alignment: Qt.AlignRight
            }
            ZoomLabel {
                visible: getAddress(contactSelected, 0)
                text: getAddress(contactSelected, 0)
                wrapMode: Text.Wrap
            }
            ZoomLabel {
                leftPadding: app.appFontSize/2
                text: i18n.tr("Address (other)")
                visible: getAddress(contactSelected, 1)
                Layout.alignment: Qt.AlignRight
            }
            ZoomLabel {
                visible: getAddress(contactSelected, 1)
                text: getAddress(contactSelected, 1)
                wrapMode: Text.Wrap
            }
//            Repeater {
//                model: contactSelected.addresses
//                ZoomLabel {
//                    text: modelData.street+" "+modelData.locality+" "+modelData.region+" "+modelData.postcode+" "+modelData.country+" "+modelData.postOfficeBox+" "+modelData.subTypes.join(" ")
//                }
//            }

            ZoomLabel {
                leftPadding: app.appFontSize/2
                text: i18n.tr("Birthday")
                visible: contactSelected && contactSelected.birthday && contactSelected.birthday.birthday.isValid()
                Layout.alignment: Qt.AlignRight
            }
            ZoomLabel {
                visible: contactSelected && contactSelected.birthday && contactSelected.birthday.birthday.isValid()
                text: contactSelected && contactSelected.birthday ? contactSelected.birthday.birthday.toLocaleDateString(Qt.locale(), Locale.ShortFormat) : ""
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
                text: i18n.tr("Url")
                visible: contactSelected && contactSelected.url && contactSelected.url.url
                Layout.alignment: Qt.AlignRight
            }
            ZoomLabel {
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
                visible: contactSelected && contactSelected.hobby && contactSelected.hobby.hobby
                text: contactSelected && contactSelected.hobby ? contactSelected.hobby.hobby : ""
            }
            //Disabled note section as not working
            ZoomLabel {
                leftPadding: app.appFontSize/2
                text: i18n.tr("Note")
                visible: contactSelected && contactSelected.note && contactSelected.note.note
                Layout.alignment: Qt.AlignRight
            }
            ZoomLabel {
                visible: contactSelected && contactSelected.note && contactSelected.note.note
                text: contactSelected && contactSelected.note ? contactSelected.note.note : ""
                wrapMode: Text.Wrap
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
