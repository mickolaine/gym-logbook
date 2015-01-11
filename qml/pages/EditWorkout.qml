import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Database.js" as DB


Dialog {
    id: page
    property string dbname

    onOpened: {
        pageStack.find( function(p) {
            try { page.dbname = p.getTable(); } catch (e) {};
            return false;
        } );
        DB.getWorkouts(page.dbname, workouts)
    }

    ListModel {
        id: workouts
    }




    SilicaFlickable {

        PageHeader {
            id: header
            title: qsTr("Accept workout")
        }

        anchors.fill: parent


        PullDownMenu {
            MenuItem {
                text: "Delete All"
                onClicked: remorse.execute( "Deleting All Entries",
                                               function() {
                                                   DB.clear();
                                                   page.refresh()
                                               }
                                           )
            }
            MenuItem {
                text: "New exercise"
                onClicked: pageStack.push(Qt.resolvedUrl("NewExercise.qml"))
            }
        }

        SilicaListView {
            id: listView
            model: workouts

            anchors.top: header.bottom
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            contentHeight: childrenRect.height
            delegate: ListItem {
                id: delegate

                TextArea {
                    id: daylabel
                    x: Theme.paddingLarge
                    label: model.day
                    labelVisible: true
                    placeholderText: model.day
                    width: parent.width
                    focus: true
                }

                Button {
                    id: buttonNew
                    anchors.top: daylabel.bottom
                    text: qsTr("New exercise")
                }

                ListModel {
                    id: day
                }

                Component.onCompleted: DB.getWorkoutContent(page.dbname, workouts)

                SilicaListView {
                    id: dayview
                    model: day

                    anchors.top: daylabel.bottom
                    anchors.bottom: parent.bottom
                    width: parent.width

                    delegate: ListItem {
                        id: daydelegate

                        Label {
                            id: excercise

                            text: model.name
                        }
                    }

                }

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
    }
}
