file(GLOB QML_JS_FILES *.qml *.js)

# make the files visible on qtcreator
add_custom_target(CONTACTS_QMLFiles ALL SOURCES ${QML_JS_FILES})

foreach(QML_JS_FILE ${QML_JS_FILES})
        install(FILES ${QML_JS_FILE} DESTINATION ${KDE_INSTALL_QMLDIR}/org/gka/contacts-qt)
endforeach(QML_JS_FILE)
