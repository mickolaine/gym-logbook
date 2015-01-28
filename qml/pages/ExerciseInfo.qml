import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Database.js" as DB


Page {
    id: page
    property string table

    SilicaFlickable {
        anchors.fill: parent

        Column {
            id: col

            width: parent.width

            PageHeader {
                title: qsTr("Information about exercise...")
            }

            Label {
                x: Theme.paddingMedium
                text: qsTr("Calculated 1RM")
                font.pixelSize: Theme.fontSizeLarge
            }

            Label {
                x: Theme.paddingLarge
                text: qsTr("This one repeat maximum is based on your latest \"Done\" sets. It ignores the number of sets and only takes one set into account.")
                wrapMode: Text.WordWrap
                maximumLineCount: 5
                width: parent.width - 2*Theme.paddingLarge
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
            }

            Label {
                x: Theme.paddingLarge
                text: qsTr("1RM calculation is done with formula by Matt Brzycki.")
                wrapMode: Text.WordWrap
                maximumLineCount: 5
                width: parent.width - 2*Theme.paddingLarge
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
            }

            Label {
                x: Theme.paddingLarge
                text: DB.get1RMSet(page.table, false) + " kg"
                width: parent.width - 2*Theme.paddingLarge
                font.pixelSize: Theme.fontSizeExtraLarge
                horizontalAlignment: Text.AlignRight
            }

            Label {
                x: Theme.paddingLarge
                text: qsTr("All time maximum. This ignores time and calculates the best value ever.")
                wrapMode: Text.WordWrap
                maximumLineCount: 5
                width: parent.width - 2*Theme.paddingLarge
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
            }
            Label {
                x: Theme.paddingLarge
                text: DB.get1RMSet(page.table, true) + " kg"
                width: parent.width - 2*Theme.paddingLarge
                font.pixelSize: Theme.fontSizeExtraSmall
                horizontalAlignment: Text.AlignRight
            }

        }

    }

}


