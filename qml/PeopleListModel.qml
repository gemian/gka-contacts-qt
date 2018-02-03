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

    Component.onCompleted: {
        if (active) {
            updateIfNecessary()
        }
        console.log("Available Managers: " + availableManagers)
    }
}
