import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Database.js" as DB


Dialog {
    id: page
    property string table
    property string type

    property string id


    DatePicker {
        id: datepicker
        visible: false
    }

    function visibility() {
        var weight = DB.getExerciseType(page.table);
        if (weight === "Weight") {
            return true;
        }
        else {
            return false;
        }
    }

    function loadValues() {

        if (isNaN(page.id)) {

        }
        else {

            var values = DB.getSet(page.table, page.id);

            datepicker.date = new Date(values[0], values[1]-1, values[2], 0, 0, 0);
            sets.text = values[3];
            reps.text = values[4];
            time.text = values[5];
            weight.text = values[6];
            if (values[7] === "Done") {
                status.currentIndex = 1;
            } else if (values[7] === "Not done") {
                status.currentIndex = 0;
            } else if (values[7] === "Fail") {
                status.currentIndex = 2;
            }
        }
    }

    onAccepted: {
        if (isNaN(page.id)) {
            DB.newSet(page.table, datepicker.year, datepicker.month, datepicker.day, sets.text, reps.text, weight.text, time.text, status.value);
        }
        else {
            DB.updateSet(page.id, page.table, datepicker.year, datepicker.month, datepicker.day, sets.text, reps.text, weight.text, time.text, status.value);
        }
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
                title: qsTr("Accept set")
            }

            Component {
                id: pickerComponent
                DatePickerDialog {
                    id: datedialog
                }
            }

            TextField {
                id: datefield
                width: 250
                x: Theme.paddingLarge
                text: datepicker.dateText
                label: qsTr("Date")
                placeholderText: qsTr("Date")
                EnterKey.onClicked: parent.focus = true

                onClicked: {
                    var dialog = pageStack.push(pickerComponent, datepicker.date)
                    dialog.accepted.connect(function() {
                        datefield.text = dialog.dateText;
                        datepicker.date = dialog.date;
                    })
                }
            }

            TextField {
                id: sets
                width: 120
                x: Theme.paddingLarge
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                label: qsTr("Sets")
                placeholderText: qsTr("Sets")
                EnterKey.onClicked: parent.focus = true
            }

            TextField {
                id: reps
                width: 120
                x: Theme.paddingLarge
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                label: qsTr("Reps")
                placeholderText: qsTr("Reps")
                EnterKey.onClicked: parent.focus = true
            }

            TextField {
                id: weight
                width: 250
                x: Theme.paddingLarge
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                label: qsTr("Weight")
                placeholderText: qsTr("Weight")
                EnterKey.onClicked: parent.focus = true
                visible: visibility()
            }

            TextField {
                id: time
                width: 250
                x: Theme.paddingLarge
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                label: qsTr("Time")
                placeholderText: qsTr("Time")
                EnterKey.onClicked: parent.focus = true
                visible: !visibility()
            }

            ComboBox {
                id: status
                x: Theme.paddingLarge
                width: 480
                label: "Status"
                description: qsTr("Status")
                menu: ContextMenu {
                    MenuItem { text: "Not done" }
                    MenuItem { text: "Done" }
                    MenuItem { text: "Fail" }
                }
            }
        }
        Component.onCompleted: page.loadValues()
    }
}





