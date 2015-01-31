import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog
    property string name
    property int genindex

    Column {
        id: col
        width: parent.width
        anchors.margins: Theme.paddingLarge
        spacing: Theme.paddingMedium

        DialogHeader {
            acceptText: "Rename"
        }

        PageHeader {
            title: "Rename"
        }

        Label{
            font.pixelSize: Theme.fontSizeMedium
            wrapMode: Text.WordWrap
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Theme.paddingMedium
                rightMargin: Theme.paddingMedium
            }
            text: 'Please choose a new name'
        }

        TextField {
            id: nameField
            width: 480
            placeholderText: dialog.name
        }

        Label{
            font.pixelSize: Theme.fontSizeMedium
            wrapMode: Text.WordWrap
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Theme.paddingMedium
                rightMargin: Theme.paddingMedium
            }
            text: 'For best results, please choose a name with less than 13 chars.'
        }

        ComboBox {
            label: "This name is"
            id: namegender

            menu: ContextMenu {
                MenuItem { text: "Male" }
                MenuItem { text: "Female" }
            }
        }

        Label{
            font.pixelSize: Theme.fontSizeMedium
            wrapMode: Text.WordWrap
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Theme.paddingMedium
                rightMargin: Theme.paddingMedium
            }
            text: 'This selection will be used to choose fitting pronouns for event messages. It does not affect your moose in any way.'
        }
     }

    onDone: {
        if (result == DialogResult.Accepted) {
            name = nameField.text
            genindex = namegender.currentIndex
        }
    }
}
