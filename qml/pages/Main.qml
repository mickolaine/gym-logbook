import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Database.js" as DB


Page {
    id: page

    ListModel {
        id: exercises
    }

    function refresh() {
        exercises.clear();
        DB.getExercises(exercises, "popularity");
    }
    SilicaFlickable {
        anchors.fill: parent

        PageHeader {
            title: qsTr("Gym Logbook")
            id: header
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("About...")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
            MenuItem {
                text: "New exercise"
                onClicked: pageStack.push(Qt.resolvedUrl("ExerciseEdit.qml"))
            }
        }

        SilicaListView {
            id: listView
            model: exercises

            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: header.bottom
            anchors.bottom: space.top

            delegate: ListItem {
                id: delegate
                menu: contextMenu
                contentHeight: line1.height + line2.height + 20

                function remove() {
                    remorseAction("Deleting", function() {
                        DB.deleteExercise(model.id);
                        exercises.remove(index);
                    })
                }

                Label {
                    id: line1
                    x: Theme.paddingLarge
                    text: model.name
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                Label {
                    id: line2
                    text: model.info
                    width: page.width - 2*Theme.paddingLarge
                    horizontalAlignment: Text.AlignLeft
                    x: Theme.paddingLarge
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    truncationMode: TruncationMode.Fade
                    anchors {
                        top: line1.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.paddingLarge
                    }

                }

                onClicked: pageStack.push(Qt.resolvedUrl("Exercise.qml"),{eid:model.id})

                Component {
                    id: contextMenu
                    ContextMenu {
                        MenuItem {
                            text: "Remove"
                            onClicked: remove()
                        }
                        MenuItem {
                            text: qsTr("Move up")

                        }
                        MenuItem {
                            text: qsTr("Move down")
                        }
                    }
                }
            }

            VerticalScrollDecorator {}
        }
        BackgroundItem {
            id: space
            anchors.bottom: parent.bottom
            height: page.isPortrait ? Theme.fontSizeLarge + Theme.paddingLarge : 0
        }

    }

    DockedPanel {
        id: controlPanel

        width: page.isPortrait ? parent.width : Theme.itemSizeExtraLarge + Theme.paddingLarge
        height: page.isPortrait ? Theme.fontSizeLarge + Theme.paddingLarge : parent.height

        dock: page.isPortrait ? Dock.Bottom : Dock.Right
        open: true

        Flow {
            id: flow
            width: isPortrait ? undefined : Theme.itemSizeExtraLarge
            height: parent.height
            spacing: Theme.paddingLarge
            anchors.centerIn: parent
            anchors.fill: parent
            visible: page.isPortrait

            BackgroundItem {
                id: flowcalc
                width: parent.width/2 - Theme.paddingLarge
                Label {
                    text:qsTr("Calculators")
                    font.pixelSize: Theme.fontSizeMedium
                    anchors.centerIn: parent
                }
                onClicked: pageStack.push(Qt.resolvedUrl("Calculators.qml"))
            }

            BackgroundItem {
                id: flowroutines
                width: parent.width/2 - Theme.paddingLarge
                Label {
                    text:qsTr("Routines")
                    font.pixelSize: Theme.fontSizeMedium
                    anchors.centerIn: parent
                }
                onClicked: pageStack.push(Qt.resolvedUrl("Routines.qml"))
            }
        }

        Column {
            id: column
            width: isPortrait ? undefined : Theme.itemSizeExtraLarge
            height: parent.height
            spacing: Theme.paddingLarge
            anchors.centerIn: parent
            anchors.fill: parent
            visible: !page.isPortrait


            BackgroundItem {
                id: colcalc
                height: parent.height/2 - Theme.paddingLarge
                width: parent.width
                Label {
                    text:qsTr("Calculators")
                    font.pixelSize: Theme.fontSizeMedium
                    anchors.centerIn: parent
                }
                onClicked: pageStack.push(Qt.resolvedUrl("Calculators.qml"))
            }

            BackgroundItem {
                id: colroutines
                height: parent.height/2 - Theme.paddingLarge
                width: parent.width
                Label {
                    text:qsTr("Routines")
                    font.pixelSize: Theme.fontSizeMedium
                    anchors.centerIn: parent
                }
                onClicked: pageStack.push(Qt.resolvedUrl("Routines.qml"))
            }
        }

    }
    Component.onCompleted: { DB.open(); DB.updateDB(); page.refresh(); }
}


