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
        DB.getWorkoutDays(page.dbname, workouts);
    }

    onAccepted: {
        pageStack.find( function(p) {
            try { p.refresh(); } catch (e) {};
            return false;
        } );
    }

    onRejected: {
        workouts.clear();
    }

    ListModel {
        id: workouts
    }



    SilicaFlickable {

        PageHeader {
            id: header
            title: qsTr("Accept routine")
        }

        anchors.fill: parent

        /*PullDownMenu {
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
        }*/

        Label {
            id: label
            text: qsTr("Select workout to edit:")
            anchors.top: header.bottom
            x: Theme.paddingLarge
            width: parent.width
            height: Theme.itemSizeSmall

        }

        SilicaListView {
            id: listView
            model: workouts

            anchors.top: label.bottom
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            delegate: ListItem {
                id: delegate

                Label {
                    id: daylabel
                    x: Theme.paddingLarge
                    text: model.day
                    width: parent.width
                    focus: true
                }

                onClicked: pageStack.push(Qt.resolvedUrl("EditDay.qml"),{dbname:page.dbname, day:model.day})
            }
        }
        VerticalScrollDecorator {}
    }
}
