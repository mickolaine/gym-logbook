import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Database.js" as DB


Dialog {
    id: page

    DatePicker {
        id: datepicker
        visible: false
    }

    ListModel {
        id: setsModel
    }

    function updateSetsModel() {
        setsModel.clear();
        var entries = 16;
        var percentages;
        var meta;
        if (order.currentIndex === 0) {
            percentages = [0, 0, 0, 0, 65, 70, 75, 40, 75, 80, 85, 50, 85, 90, 95, 60];
            meta = ["Week 1", "Week 2", "Week 3", "Warmup", "5 x ", "3 x ", "5 x ", "5 x ", "5 x ", "3 x ", "3 x ", "5 x ", "5+x ", "3+x ", "1+x ", "3 x "];
        }
        else if (order.currentIndex === 1) {
            percentages = [0, 0, 0, 0, 70, 65, 75, 40, 80, 75, 85, 50, 90, 85, 95, 60];
            meta = ["Week 1", "Week 2", "Week 3", "Warmup", "3 x ", "5 x ", "5 x ", "5 x ", "3 x ", "5 x ", "3 x ", "5 x ", "3+x ", "5+x ", "1+x ", "3 x "];
        }
        if (minustenpercent.checked === true) {
            for (var i = 0; i < entries; i++) {
                if (percentages[i] !== 0) {
                    percentages[i] = percentages[i]*0.9
                }
            }
        }

        for (var index = 0; index < entries; index++) {
            if (percentages[index] === 0) {
                setsModel.append({"text": meta[index]})
            }
            else {
                setsModel.append({"text": meta[index] + Math.round(percentages[index]*parseInt(onermvalue.text)/100.0/2.5)*2.5})
            }
        }

    }


    SilicaFlickable {
        contentHeight: column.height
        id: entry
        anchors.fill: parent

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Wendler 531")
            }

            TextField {
                id: onermvalue
                text: "100"
                label: qsTr("1RM weight to use in calculations")
                x: Theme.paddingLarge
                width: parent.width - 2*Theme.paddingLarge
                font.pixelSize: Theme.fontSizeExtraLarge
                horizontalAlignment: Text.AlignRight
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onTextChanged: updateSetsModel()
            }

            ComboBox {
                id: order
                width: 480
                label: qsTr("Order:")
                menu: ContextMenu {
                    MenuItem { text: qsTr("5/3/1") }
                    MenuItem { text: qsTr("3/5/1") }
                }
                onCurrentIndexChanged: updateSetsModel()
            }

            Grid {
                id: setsGrid
                rows: 4
                columns: 4
                spacing: -1
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.topMargin: -1

                Repeater {
                    model: setsModel

                    Rectangle {
                        width: (page.width - Theme.paddingLarge) / 4
                        height: (width / 2)
                        color: "transparent"
                        border.color: Theme.highlightColor
                        border.width: 1

                        Label {
                            text: model.text
                            font.pixelSize: 20
                            anchors.centerIn: parent
                        }
                    }
                }
            }

            TextSwitch {
                id: minustenpercent
                text: qsTr("Minus 10% from 1RM")
                checked: false
                onCheckedChanged: updateSetsModel()
            }

            TextSwitch {
                id: addswitch
                text: qsTr("Add sets to exercise")
                checked: false
            }

            TextSwitch {
                id: lastswitch
                text: qsTr("Only last sets for each day")
                checked: true
                visible: addswitch.checked
            }

            TextSwitch {
                id: warmupswich
                text: qsTr("Add warmups as week 4")
                checked: false
                visible: addswitch.checked
            }

            Component {
                id: pickerComponent
                DatePickerDialog {
                    id: datedialog
                }
            }

            TextField {
                id: datefield
                width: 300
                //x: Theme.paddingLarge
                text: datepicker.dateText
                label: qsTr("Starting from date")
                //placeholderText: qsTr("Date")
                EnterKey.onClicked: parent.focus = true
                visible: addswitch.checked

                onClicked: {
                    var dialog = pageStack.push(pickerComponent, datepicker.date)
                    dialog.accepted.connect(function() {
                        datefield.text = dialog.dateText;
                        datepicker.date = dialog.date;
                    })
                }
            }

            Row {
                x: Theme.paddingLarge
                Label {
                    id: label1

                    text: qsTr("Every")
                    //width: parent.width - 2*Theme.paddingLarge
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.secondaryColor
                }
                TextField {
                    id: days
                    text: "7"
                    width: 100
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    font.pixelSize: Theme.fontSizeMedium
                    horizontalAlignment: Text.AlignRight
                }
                Label {
                    id: label2
                    text: qsTr("days")
                    //width: parent.width - 2*Theme.paddingLarge
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.secondaryColor
                }

                visible: addswitch.checked
            }

            Button {
                id: addbutton
                text: qsTr("Add")
                visible: addswitch.checked
            }

        }
    }
    Component.onCompleted: updateSetsModel()
}

