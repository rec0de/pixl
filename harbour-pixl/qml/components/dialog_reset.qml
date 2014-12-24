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
            acceptText: "Reset"
        }

        PageHeader {
            title: "Reset Game"
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
            text: 'Do you really want to reset the game? This will delete all your progress & animals permanently. You will get 5 seconds after accepting this dialog to change your mind. Please restart the app after resetting the game.'
        }
     }
}
