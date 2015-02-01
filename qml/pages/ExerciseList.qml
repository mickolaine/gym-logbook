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
        DB.getExercises(exercises);
    }

    SilicaFlickable {

        anchors.fill: parent

        PageHeader {
            title: qsTr("Exercises")
            id: header
        }

        PullDownMenu {
            /*MenuItem {
                text: "Delete All"
                onClicked: remorse.execute( "Deleting All Entries",
                                               function() {
                                                   DB.clear();
                                                   page.refresh()
                                               }
                                           )
            }*/
            MenuItem {
                text: "New exercise"
                onClicked: pageStack.push(Qt.resolvedUrl("ExerciseEdit.qml"))
            }
        }

        RemorsePopup { id: remorse }

        SilicaListView {
            id: listView
            model: exercises

            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: header.bottom
            anchors.bottom: parent.bottom

            delegate: ListItem {
                id: delegate
                menu: contextMenu
                contentHeight: line1.height + line2.height + 20
                function remove() {
                    remorseAction("Deleting", function() {
                        if (DB.deleteExercise(model.id)) {
                            page.refresh();
                           }
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

                onClicked: pageStack.push(Qt.resolvedUrl("Exercise.qml"),{name:model.name,id:model.id,info:model.info,tablename:model.dbname})

                Component {
                    id: contextMenu
                    ContextMenu {
                        MenuItem {
                            text: "Remove"
                            onClicked: remove()
                        }
                    }
                }
            }
            VerticalScrollDecorator {}
        }
        Component.onCompleted: page.refresh()
    }
}

