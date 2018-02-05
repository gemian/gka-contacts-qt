import QtQuick 2.0
import QtContacts 5.0

ContactModel {
    id: contactModel
    manager: "galera"
    property var externalFilter: null
    property string filterTerm: ""
    property var view: null

    property bool _clearModel: false
    property list<QtObject> _extraFilters
    property QtObject _timeout

    function changeFilter(newFilter)
    {
        if (contactModel.contacts.length > 0) {
            contactModel._clearModel = true
        }
        contactModel.externalFilter = newFilter
    }

    filter: {
        if (contactModel._clearModel) {
            return invalidFilter
        } else if (contactsFilter.active) {
            return contactsFilter
        } else {
            return null
        }
    }

    _extraFilters: [
        InvalidFilter {
            id: invalidFilter
        },
        UnionFilter {
            id: contactTermFilter

            property string value: ""
            property var phoneNumberFilter: DetailFilter {
                detail: ContactDetail.PhoneNumber
                field: PhoneNumber.Number
                value: contactTermFilter.value
                matchFlags: (DetailFilter.MatchPhoneNumber | DetailFilter.MatchContains)
            }

            filters: [
                DetailFilter {
                    id: firstNameFilter
                    detail: ContactDetail.Name
                    field: Name.FirstName
                    matchFlags: Filter.MatchContains
                    value: contactTermFilter.value
                },
                DetailFilter {
                    id: middleNameFilter
                    detail: ContactDetail.Name
                    field: Name.MiddleName
                    matchFlags: Filter.MatchContains
                    value: contactTermFilter.value
                },
                DetailFilter {
                    id: lastNameFilter
                    detail: ContactDetail.Name
                    field: Name.LastName
                    matchFlags: Filter.MatchContains
                    value: contactTermFilter.value
                }
            ]

            onValueChanged: {
                var containsOnlyNumbers = value.match(/^[0-9\+\s]+$/) !== null;
                if (!containsOnlyNumbers && (filters.length > 3)) {
                    filters = [firstNameFilter, middleNameFilter, lastNameFilter]
                } else if (containsOnlyNumbers) {
                    filters = [firstNameFilter, middleNameFilter, lastNameFilter, phoneNumberFilter]
                }
            }
        },
        IntersectionFilter {
            id: contactsFilter

            // avoid runtime warning "depends on non-NOTIFYable properties"
            readonly property alias filtersProxy: contactsFilter.filters

            property bool active: {
                var filters_ = []
                if (contactTermFilter.value.length > 0) {
                    filters_.push(contactTermFilter)
                }

                if (contactModel.externalFilter) {
                    filters_.push(contactModel.externalFilter)
                }

                // check if the filter has changed
                var oldFilters = filtersProxy
                if (oldFilters.length !== filters_.length) {
                    contactsFilter.filters = filters_
                } else {
                    for(var i=0; i < oldFilters.length; i++) {
                        if (filters_.indexOf(oldFilters[i]) === -1) {
                            contactsFilter.filters = filters_
                        }
                    }
                }

                return (filters_.length > 0)
            }
        }
    ]

    _timeout: Timer {
        id: contactSearchTimeout

        running: false
        repeat: false
        interval: 300
        onTriggered: {
            if (contactModel.view) {
                view.positionViewAtBeginning()
            }

            contactModel.changeFilter(contactModel.externalFilter)
            contactTermFilter.value = contactModel.filterTerm.trim()

            // manually update if autoUpdate is disabled
            if (!contactModel.autoUpdate) {
                contactModel.update()
            }
        }
    }

    onFilterTermChanged: {
        var newFilterTerm = contactModel.filterTerm.trim()
        if (contactTermFilter.value !== newFilterTerm)
            contactSearchTimeout.restart()
    }

    onContactsFetched: {
        console.log("Contacts Fetched"+contacts);
    }

    onContactsChanged: {
        console.log("Contacts Changed"+contacts);
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

    onErrorChanged: {
        if (error) {
            console.error("Contact List error:" + error)
        }
    }

    Component.onCompleted: {
        if (active) {
            updateIfNecessary()
        }
        console.log("Available Managers: " + availableManagers)
    }
}
