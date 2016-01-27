import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    // Easter Egg
    Rectangle {
        id: eegg
        visible: thanks.clickcount > 7
        anchors.centerIn: parent
        width: page.width
        height: eeggcol.height + Theme.paddingMedium * 2
        color: Theme.highlightColor
        z: 1000

        Column{
            id: eeggcol
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            Image{
                source: '../img/eegg4.png'
                smooth: false
                height: sourceSize.height * 4
                width: sourceSize.width * 4
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label{
                id: msgtext
                visible: parent.visible
                anchors.horizontalCenter: parent.horizontalCenter
                text: 'Moo.'
                font.pointSize: Theme.fontSizeLarge
                color: Theme.primaryColor
            }
        }
        MouseArea {
            anchors.fill : parent
            onClicked: thanks.clickcount = 0
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        height: parent.height
        contentHeight: col.height + 20
        id: flick

        VerticalScrollDecorator{}

        Column {
            id: col
            width: parent.width
            anchors.margins: Theme.paddingLarge
            spacing: Theme.paddingMedium

            PageHeader {
                title: "About"
            }

            SectionHeader {
                text: "License"
            }

            Label {
                text: "GPL v3"
                anchors.horizontalCenter: parent.horizontalCenter
                MouseArea {
                    id : licenseMouseArea
                    anchors.fill : parent
                    onClicked: Qt.openUrlExternally("http://choosealicense.com/licenses/gpl-v3/")
                }
            }

            SectionHeader {
                text: "Made by"
            }

            Label {
                text: "@rec0denet"
                anchors.horizontalCenter: parent.horizontalCenter
                MouseArea {
                    id : madebyMouseArea
                    anchors.fill : parent
                    onClicked: Qt.openUrlExternally("http://rec0de.net")
                }
            }

            SectionHeader {
                text: "Source"
            }

            Label {
                text: "github.com/rec0de/pixl"
                font.underline: true;
                anchors.horizontalCenter: parent.horizontalCenter
                MouseArea {
                    id : sourceMouseArea
                    anchors.fill : parent
                    onClicked: Qt.openUrlExternally("https://github.com/rec0de/pixl")
                }
            }


            SectionHeader {
                text: "Contact"
            }

            Label {
                text: "mail@rec0de.net"
                anchors.horizontalCenter: parent.horizontalCenter
                MouseArea {
                    id : contactMouseArea
                    anchors.fill : parent
                    onClicked: Qt.openUrlExternally("mailto:mail@rec0de.net")
                }
            }

            SectionHeader {
                text: "Privacy"
            }

            Label {
                id: privacy
                text:   'By default, pixl does not collect or send any data. However, if you decide to use the Multiplayer/Invite-a-moose feature, the guest animals data will be uploaded to the pixl server and downloaded by the host. During this process, your IP might be logged by our service provider.'
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
            }

            SectionHeader {
                text: "About me"
            }

            Label {
                id: aboutme
                text:   'I develop these apps as a hobby. Therefore, please don\'t expect them to work perfectly. If you like what I\'m doing, consider liking / commenting the app or following me on twitter. For a developer, knowing that people out there use & like your app is one of the greatest feelings ever.'
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
            }

            SectionHeader {
                text: "Thanks"
            }

            Label {
                id: thanks
                text: 'Font by astramat.com<br>Database derived from \'noto\' by leszek.<br>Thanks to gukke, AL13N, KAOS and all the others who found bugs and shared their ideas.<br>Inspired by \'Disco Zoo\' and \'A dark room\'.<br> Thanks to all of you!'
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
                property int clickcount: 0

                MouseArea{
                    anchors.fill: parent
                    onClicked: parent.clickcount = parent.clickcount + 1
                }
            }

            Label {
               text: 'down down right left up'
               font.pixelSize: Theme.fontSizeExtraSmall
               anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

}
