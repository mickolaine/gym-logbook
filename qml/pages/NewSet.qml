import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Database.js" as DB


Dialog {
    id: page

    property string sid
    property string eid


    DatePicker {
        id: datepicker
        visible: false
    }

    function visibility() {
        var weight = DB.getExerciseType(eid);
        if (weight === "Weight") {
            return true;
        }
        else {
            return false;
        }
    }

    function loadValues() {

        if (page.sid === "") { }

        else {
            var values = DB.getSetData(page.sid);

            datepicker.date = new Date(values.date);
            sets.text = values.sets;
            reps.text = values.reps;

            if (values.time) {
                time.text = values.time;
            }
            if (values.weight) {
                weight.text = values.weight;
            }
            if (values.status === "Done") {
                status.currentIndex = 1;
            } else if (values.status === "Not done") {
                status.currentIndex = 0;
            } else if (values.status === "Fail") {
                status.currentIndex = 2;
            }
        }
    }

    onAccepted: {
        if (page.sid === "") {
            DB.newSet(page.eid, datepicker.date, sets.text, reps.text, weight.text, time.text, status.value);
        }
        else {
            DB.updateSet(page.sid, datepicker.date, sets.text, reps.text, weight.text, time.text, status.value);
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





