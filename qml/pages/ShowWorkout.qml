import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Database.js" as DB


Page {
    property string dbname
    property string name
    property string info
    id: page

    function refresh() {
        routine.clear();
        DB.getWorkoutRoutine(page.dbname, routine);
        var data = DB.getWorkoutInfo(dbname);
        name = data[0];
        info = data[1];
    }

    SilicaListView {

        PullDownMenu {
            MenuItem {
                text: "Edit workout"
                onClicked: pageStack.push(Qt.resolvedUrl("EditWorkout.qml"), {dbname:page.dbname})
            }
        }

        anchors.fill: parent
        spacing: Theme.paddingMedium

        header: PageHeader {
            title: page.name
        }

        model: ListModel {
            id: routine
        }

        section {
            property: 'section'

            delegate: SectionHeader {
                text: day
                height: Theme.itemSizeExtraSmall
            }
        }

        VerticalScrollDecorator {}

        delegate: ListItem {
            //x: Theme.paddingLarge
            contentWidth: parent.width //- 2*Theme.paddingLarge
            //height: childrenRect.height + 20
            contentHeight: origin.height + body.height + 20

            Label {
                id: origin
                text: exercise
                x: Theme.paddingLarge
                font.pixelSize: Theme.fontSizeMedium
                truncationMode: TruncationMode.Fade
                anchors {
                    left: parent.left
                    rightMargin: Theme.paddingSmall
                    leftMargin: Theme.paddingLarge
                }
            }
            Label {
                id: date
                text: day
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryHighlightColor
                horizontalAlignment: Text.AlignRight
                anchors {
                    right: parent.right
                    baseline: origin.baseline
                    rightMargin: Theme.paddingSmall
                }
            }
            Label {
                id: body
                text: info
                x: Theme.paddingLarge
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                truncationMode: TruncationMode.Fade
                anchors {
                    top: origin.bottom
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                }
            }
            onClicked: {pageStack.push(Qt.resolvedUrl("Exercise.qml"), {name:exercise,id:eid,info:info,tablename:exercisetable})}

        }
        Component.onCompleted: {
        refresh();
       }
    }
}
