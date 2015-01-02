import QtQuick 2.0
import Sailfish.Silica 1.0
import 'data.js' as DB

Page {
    id: page
    property string code: ''

    function updatemessage(msg){
        msgtext.text = msg;
        message.visible = true;
    }

    function load(code) {
        var url = 'https://cdown.pf-control.de/pixl/getanimal.php?code='+code; // alias domain for rec0de.net with valid SSL cert

        var xhr = new XMLHttpRequest();
        xhr.timeout = 1000;

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log('status', xhr.status, xhr.statusText)
                console.log('response', xhr.responseText)
                if(xhr.status >= 200 && xhr.status < 300) {

                    var text = xhr.responseText;

                    //Escaping content fetched from web to prevent script injections
                    var patt1 = /(<|>|\{|\}|\[|\]|\\)/g;
                    text = text.replace(patt1, '');

                    var array = text.split('|')
                    if(array[0] === '' && array[1] === '' && array[2] === ''){
                        updatemessage('Error: Moose doesn\'t exist.');
                    }
                    else{
                        var id = DB.getsett(7);
                        if(id === '-1'){
                            id = 0;
                        }

                        // Count animals
                        if(DB.getall !== false && DB.getnonlocal() !== false){
                            var count = DB.getall().length + DB.getnonlocal().length;
                        }
                        else if(DB.getall !== false){
                            count = DB.getall().length;
                        }
                        else if(DB.getnonlocal() !== false){
                            count = DB.getnonlocal().length;
                        }
                        else{
                            count = 0;
                        }

                        // Upper limit for population
                        if(count < 51){
                            DB.addnonlocal(array[2], array[0], array[1], id);
                            DB.setsett(7, id+1);
                            updatemessage('Imported '+array[0]);
                        }
                        else{
                            updatemessage('Error: Too many moose. ('+count+')')
                        }
                    }
                }
                else {
                    updatemessage('Error: Connection failed.');
                }
            }
        }

        xhr.ontimeout = function() {
            updatemessage('Error: Request timed out.');
        }

        xhr.open('GET', url, true);
        xhr.setRequestHeader("User-Agent", "Mozilla/5.0 (compatible; Pixl app for SailfishOS)");
        xhr.send();
    }


    Column {
        id: col
        width: parent.width
        anchors.margins: Theme.paddingLarge
        spacing: Theme.paddingMedium

        PageHeader {
            title: "Invite Animal"
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
            text: 'Please enter the guest animals unique code'
        }

        Label{
            id: codelabel
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.highlightColor
            wrapMode: Text.WordWrap
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            text: '00000'
        }

        Keypad{
            id: codeField
            symbolsVisible: false
            vanityDialNumbersVisible: false
            onClicked: {
                if(page.code.length < 5){
                  page.code = page.code + number;
                  codelabel.text = page.code;
                }
            }
        }

        Row{
            anchors.horizontalCenter: parent.horizontalCenter

            Button {
               text: "Clear"
               onClicked:{
                   page.code = '';
                   codelabel.text = '00000';
               }
            }
            Button {
               text: "Invite"
               onClicked: load(page.code)
            }
        }
     }

    Rectangle {
        id: message
        visible: false
        anchors.centerIn: parent
        width: page.width
        height: Theme.itemSizeLarge
        color: Theme.highlightColor
        z: 1000
        Label{
            id: msgtext
            visible: parent.visible
            anchors.centerIn: parent
            text: 'Message'
            font.pixelSize: Theme.fontSizeLarge
        }
        MouseArea {
            anchors.fill : parent
            onClicked: parent.visible = false
        }
    }
}
