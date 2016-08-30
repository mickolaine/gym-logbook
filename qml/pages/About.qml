import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Database.js" as DB


Page {
    id: page



    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height + Theme.paddingLarge

        Column {
            id: col
            spacing: Theme.paddingLarge
            width: parent.width

            PageHeader {
                id: header
                title: qsTr("About Gym Logbook")
            }
            Label {
                id: headline
                x: Theme.paddingLarge
                width: parent.width - 2*Theme.paddingLarge
                text: "Gym Logbook"
                font.pixelSize: Theme.fontSizeExtraLarge
                color: Theme.secondaryColor
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                id: headline2
                x: Theme.paddingLarge
                width: parent.width - 2*Theme.paddingLarge
                text: "for Sailfish OS"
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.secondaryColor
                horizontalAlignment: Text.AlignHCenter

            }

            Label {
                id: version
                x: Theme.paddingLarge
                width: parent.width - 2*Theme.paddingLarge
                text: "version 0.39"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.secondaryColor
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                id: content
                x: Theme.paddingLarge
                width: parent.width - 2*Theme.paddingLarge
                wrapMode: Text.WordWrap
                maximumLineCount: 10
                font.pixelSize: Theme.fontSizeSmall

                text: "Gym Logbook is a simple and small app that you can use to keep track " +
                      "of your workout routines and exercise progression. I wrote it for myself " +
                      "to replace the old paper notebook."
            }

            Label {
                id: license
                x: Theme.paddingLarge
                width: parent.width - 2*Theme.paddingLarge
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall

                text: "Program is released under GPL v3 license."
            }

            Label {
                font.pixelSize: Theme.fontSizeExtraSmall
                horizontalAlignment: Text.AlignRight
                width: parent.width - Theme.paddingLarge

                text: "Mikko Laine <mikko.laine@gmail.com>"
            }
        }
    }
}


