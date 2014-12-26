import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog

    Column {
        id: col
        width: parent.width
        anchors.margins: Theme.paddingLarge
        spacing: Theme.paddingMedium

        DialogHeader {
            acceptText: "Accept"
        }

        PageHeader {
            title: "Upload animal"
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
            text: 'Note: This action is not implemented yet. <br><br>You are about to upload this animal to the pixl server. This enables you to invite it on a friends device. Uploaded data includes the animals dna, name and age. Apart from usage for the invite-a-moose feature, this data might be published online (most likley in form of an image of your animal and its name). The data uploaded to the server does not include any personal information and is fully anonymous.'
        }
     }
}
