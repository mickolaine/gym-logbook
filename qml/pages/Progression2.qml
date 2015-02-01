import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Database.js" as DB


Dialog {
    id: page
    property string table
    property string name
    property string info
    property string type
    property string onerm
    property string progression
    property string date
    property string days
    property variant linear
    property variant wendler
    property string sets
    property string reps

    onAccepted: {

        for (var i = 0; i < sets.count; i++) {
            var line = sets.get(i);
            DB.newSet(page.table, line.year, line.month, line.day, line.sets, line.reps, line.weight.toString(), "0", "Not done");
        }
        pageStack.find( function(p) {
            try { p.refresh(); } catch (e) {};
            return false;
        } );
    }

    ListModel {
        id: sets
    }

    DatePicker {
        id: datepicker
        visible: false
    }

    SilicaFlickable {

        anchors.fill: parent


        PageHeader {
            id: header
            title: qsTr("Plan progression")
        }

        SilicaListView {
            id: listView
            model: sets



            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            contentHeight: Theme.itemSizeMedium

            delegate: ListItem {

                id: delegate

                function parseContent() {
                    datepicker.date = new Date(model.year, model.month-1, model.day, 0, 0, 0);
                    line.text = datepicker.dateText + " - " + model.sets + " x " + model.reps + " x " +
                                model.weight + " kg";

                }
                function parseLocalNum(num) {
                    return +(num.replace(",", "."));
                }

                Label {
                    id: line
                    x: Theme.paddingLarge
                    anchors.verticalCenter: parent.verticalCenter
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    Component.onCompleted: parseContent()
                    truncationMode: TruncationMode.Fade

                }
            }
        }
        VerticalScrollDecorator {}
    }

    Component.onCompleted: {
        datepicker.date = page.date;

        calculateWendler(onerm);
    }


    function calculateWendler(one) {
        var table = [];
        var reps;
        table.push([.65*one, .75*one, .85*one]);
        table.push([.70*one, .80*one, .90*one]);
        table.push([.75*one, .85*one, .95*one]);
        table.push([ .4*one,  .5*one,  .6*one]);

        for (var i = 0; i < table.length; i++) {
            for (var j = 0; j < table[i].length; j++) {
                table[i][j] = Math.round(table[i][j]/2.5)*2.5;

                if (page.wendler[0]) {
                    if (j != 2) {
                        continue;
                    }
                }

                if ((i==0)||((i==3)&&(j<2))||((i==2)&&(j==0))) {
                    reps = 5;
                }
                else if (i==1||((i==3)&&(j=2))||((i==2)&&(j==1))) {
                    reps = 3;
                }
                else {
                    reps = 1;
                }

                sets.append({"year": datepicker.year, "month": datepicker.month, "day": datepicker.day,
                                  "sets": 1, "reps": reps, "weight": table[i][j]});
            }
            var myDate = new Date(datepicker.year, datepicker.month-1, datepicker.day);
            console.log(page.days);
            console.log(myDate.getDate());
            myDate.setDate(myDate.getDate() + parseInt(page.days));
            datepicker.date = myDate;

            console.log(datepicker.year + " - " + datepicker.month + " - " + datepicker.day);
        }
    }
}





