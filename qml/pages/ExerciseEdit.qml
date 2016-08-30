import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Database.js" as DB


Dialog {
    id: page
    property string table
    property string name
    property string info
    property string type
    property int eid

    onOpened: {
        print(page.eid);
        print(isNaN(page.eid));

        if (page.eid !== ""){
            var data = DB.getExerciseByEID(eid);
            name.text = data.name;
            info.text = data.additional;
            if (data.type === "Weight") {
                type.currentIndex = 0;
            } else if (data.type === "Time") {
                type.currentIndex = 1;
            }
        }
    }

    onAccepted: {
        DB.updateExercise(name.text, info.text, type.value, eid);
        pageStack.find( function(p) {
            try { p.refresh(); } catch (e) {};
            return false;
        } );
    }

    onRejected: model.clear()

    SilicaFlickable {
        contentHeight: column.height
        id: entry
        anchors.fill: parent

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Edit exercise")
            }

            TextField {
                id: name
                x: Theme.paddingLarge
                label: "Name"
                labelVisible: true
                placeholderText: "Name, eg. Bench press"
                width: parent.width
                focus: true
            }

            TextArea {
                id: info
                x: Theme.paddingLarge
                label: "Additional information"
                labelVisible: true
                placeholderText: "Additional information"
                width: parent.width
                focus: true
            }

            ComboBox {
                id: type
                x: Theme.paddingLarge
                width: 480
                label: "Measure:"
                description: qsTr("Type of the exercise.")
                menu: ContextMenu {
                    MenuItem { text: "Weight" }
                    MenuItem { text: "Time" }
                }
            }
        }
    }
}





