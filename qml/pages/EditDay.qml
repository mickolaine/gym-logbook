import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Database.js" as DB


Dialog {
    id: page
    property string dbname
    property string day

    onOpened: {
        refresh();
    }

    ListModel {
        id: exercises
    }


    function addExercise(id) {
        DB.addExercise(page.dbname, page.day, id);
    }

    function refresh() {
        exercises.clear();
        console.log(page.dbname);
        DB.getWorkoutContent(page.dbname, page.day, exercises);
    }

    SilicaFlickable {

        PageHeader {
            id: header
            title: qsTr("Accept day")
        }

        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: "Add exercise"
                onClicked: {pageStack.push(Qt.resolvedUrl("SelectExercise.qml"))}
            }
        }

        SilicaListView {
            id: listView
            model: exercises

            anchors.top: header.bottom
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            delegate: ListItem {
                id: delegate
                menu: contextMenu

                Label {
                    id: line1
                    x: Theme.paddingLarge
                    text: model.exercise
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                Label {
                    id: line2
                    text: model.info
                    width: page.width - 2*Theme.paddingLarge
                    x: Theme.paddingLarge
                    horizontalAlignment: Text.AlignLeft
                    truncationMode: TruncationMode.Fade

                    anchors.top: line1.bottom
                    font.pixelSize: Theme.fontSizeSmall
                    color: delegate.highlighted ? Theme.highlightColor : Theme.secondaryColor


                }

                //onClicked: pageStack.push(Qt.resolvedUrl("Exercise.qml"),{name:model.name,id:model.id,info:model.info,tablename:model.dbname})

                Component {
                    id: contextMenu
                    ContextMenu {
                        MenuItem {
                            text: qsTr("Move up")
                            onClicked: {}
                        }
                        MenuItem {
                            text: qsTr("Move down")
                            onClicked: {}
                        }
                        MenuItem {
                            text: "Remove"
                            onClicked: {
                                DB.removeExercise(page.dbname, model.wid);
                                refresh();
                            }
                        }
                    }
                }
            }
        }
        VerticalScrollDecorator {}
    }
}
