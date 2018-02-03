configure_file(contacts.desktop.in contacts.desktop)

install(PROGRAMS ${CMAKE_BINARY_DIR}/files/desktop/contacts.desktop DESTINATION share/applications)

install(FILES gka-contacts-qt.svg DESTINATION share/icons/hicolor/scalable/apps)
