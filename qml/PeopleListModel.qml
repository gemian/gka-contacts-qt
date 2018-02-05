import QtQuick 2.0
import QtContacts 5.0

ContactModel {
    id: contactModel
    manager: "galera"
//    UnionFilter {
//        id: filter

//        property string searchString: ""

//        filters: [
//            DetailFilter {
//                detail: ContactDetail.Name
//                field: Name.FirstName
//                matchFlags: Filter.MatchContains
//                value: filter.searchString
//            },
//            DetailFilter {
//                detail: ContactDetail.Name
//                field: Name.LastName
//                matchFlags: Filter.MatchContains
//                value: filter.searchString
//            },
//            DetailFilter {
//                detail: ContactDetail.DisplayLabel
//                field: DisplayLabel.Label
//                matchFlags: Filter.MatchContains
//                value: filter.searchString
//            }
//        ]
//    }
//    filter: filter
    autoUpdate: true

    onContactsFetched: {
        console.log("Contacts Fetched"+contacts);
    }

    onContactsChanged: {
        //WORKAROUND: clear the model before start populate it with the new contacts
        //otherwise the model will wait for all contacts before show any new contact

        //after all contacts get removed we can populate the model again, this will show
        //new contacts as soon as it arrives in the model
        if (contactModel._clearModel && contacts.length === 0) {
            contactModel._clearModel = false
            // do a new update if autoUpdate is false
            if (!contactModel.autoUpdate) {
                contactModel.update()
            }

        }
    }

    Component.onCompleted: {
        if (active) {
            updateIfNecessary()
        }
        console.log("Available Managers: " + availableManagers)
    }
}
