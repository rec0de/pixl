import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent
        height: parent.height
        contentHeight: col.height + 10
        id: flick

        VerticalScrollDecorator{}

        Column {
            id: col
            width: parent.width
            anchors.margins: Theme.paddingLarge
            spacing: Theme.paddingMedium

            PageHeader {
                title: "Help"
            }

            SectionHeader {
                text: "The Basics"
            }

            Label {
                text:   'Pixl is a game about evolution. You start with three moose that will move around, search for food and create new moose. You can feed them, look at them or give them weird names. The possibilities are endless. You could also name them after your enemies and let them die if your\'re into that. So do whatever you want and have fun.'
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
                text: "Controls"
            }

            Label {
                text:   'You can spawn food by tapping on the screen. By tapping on a specific animal, you show/hide its name and energy status. Animal stats can be accessed from the "Info" menu. You can also access the "Settings" page from there where you can activate the "Night mode", adjust the food spawn rate and enable various debug options. It is also possible to change an animals name from its stats page.'
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
                text: "DNA"
            }

            Label {
                text:   'Every moose has a unique DNA that defines how that moose behaves, how fast, clever or hungry he is. When two animals mate, their DNA is combined and a new animal with that DNA is spawned. An animals DNA massively influences its lifespan and character.'
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
                text: "Food & Energy"
            }

            Label {
                text:   'Your animals need food. A certain amount of food is spawned automatically at random locations, but you can also place food manually by tapping on the screen. Animals will notice food after a certain time in a certain area around them (if their energy level is below 91%) and eat it. By eating one food-item, the animal gains one energy unit. Animals generally consume more energy while they are moving, but the absolute energy consumption is unique to each animal.'
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
                text: "Mating"
            }

            Label {
                text:   'When two grown up (age > 20) animals stand next to each other, there is a chance that they will mate and create a new animal. The new animals DNA is a combination of the parents DNA. After an animal has mated, it can\'t mate again for ~5 minutes.'
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
                text: "Ageing"
            }

            Label {
                text:   'Once an animals age, which can be seen on its stats page, reaches 20, the animal is considered a grown up and is able to mate with other animals. When an animal reaches the age of 90, its movement speed will slowly decline making it harder for this animal to survive. This slowdown can be disabled in the settings menu.'
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
                text: "Death"
            }

            Label {
                text:   'Once an animal runs out of energy, it dies. A tombstone will appear at the animals location for a few seconds to indicate the animals death. During that time, you can still see the name of the animal by tapping on the tombstone. If the number of animals drops below three because of a death, the simulation will spawn a new animal.'
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
                text: "Evolution"
            }

            Label {
                text:   'After a few animals die and new ones are born, you\'ll notice that the new animals are stronger/faster/more attentive or less hungry. This is because the animals that find more food or need less energy are more likely to survive and find another animal to mate.'
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
                text: "Multiplayer"
            }

            Label {
                text:   'You can invite moose from your friends phone/tablet over to yours and let them play together by selecting the \'Upload\' option on an animals stats page. Enter the code you receive after uploading the animal on the host device to invite it. Guest animals can\'t mate with local moose and changes (age, death) of guest animals are not synced back to their home device. A \'(g)\' behind the animals name indicates that it is a guest animal. Guest animals can be \'sent home\' from their stats page.'
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
                text: "Debug Mode"
            }

            Label {
                text:   'You can activate debug mode from the \'Info\' page. When activated, you can manually spawn/kill animals and the simulation won\'t spawn new animals automatically. Additionaly, further information on specific animals will be displayed on their stats page (including a base16 representation of their DNA).'
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
                text: "Feature requests & Contribution"
            }

            Label {
                text:   'A list of all requested features can be found in the github repo. If you would like to add something, just open an issue on github, write me an email or comment in the harbour. If you would like to contribute to pixl, feel free to fork the code on github and add the features you\'d like to have. If you don\'t have any ideas, take a look at the list mentioned above and pick something you like. Thanks!'
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
            }

        }
    }

}
