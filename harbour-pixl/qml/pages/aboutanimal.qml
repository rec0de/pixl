import QtQuick 2.0
import Sailfish.Silica 1.0
import 'data.js' as DB

Page {
    id: page
    property string dna
    property string name
    property bool local
    property int age
    property var specieslist: new Array('Common Moose', 'Dark Moose', 'Red Moose', 'Beige Moose')
    property int species

    Component.onCompleted: {
        DB.initialize();

        var dna = page.dna;
        var basepath = '../img/moose';
        var color = parseInt(dna.substr(2, 2), 2) + 1;
        page.species = color - 1;
        image.source = basepath + color + '.png';
        speclabel.text = page.specieslist[species];

    }

    function pers1(){
        var dna = page.dna;

        var energystill = 0.001 + parseInt(dna.substr(20, 3), 2)/2000;
        var minspeed = 0.5 + parseInt(dna.substr(27, 3), 2)/2;
        var maxspeed = minspeed + parseInt(dna.substr(30, 3), 2)/1.5
        var energymoving = energystill * (1 + maxspeed / 10) * (1 + parseInt(dna.substr(24, 4), 2)/15)
        var maxenergy = 4 + parseInt(dna.substr(17, 3), 2);

        var hungry = (1 + energystill*200)*(1 + energymoving*200) - (maxspeed/5);
        var fast = (maxspeed - minspeed);
        var untiring = (1 / hungry)*(maxenergy/2);

        if(hungry > fast && hungry > untiring){
            return 'Hungry';
        }
        else if(fast >= hungry && fast >= untiring){
            return 'Fast';
        }
        else{
            return 'Untiring';
        }
    }

    function pers2(){
        var dna = page.dna;

        var viewarea = 70 + parseInt(dna.substr(4, 3), 2) * 15;
        var movingchange = 1 + parseInt(dna.substr(7, 3), 2);
        var stillchange = 1 + parseInt(dna.substr(10, 3), 2);
        var directionchange = parseInt(dna.substr(13, 4), 2);
        var searchingduration = 300 + parseInt(dna.substr(36, 4), 2)*100;

        var lazy = (stillchange - movingchange)*3;
        var clever = (viewarea / 25) * (searchingduration / 250);
        var hyperactive = (1 + movingchange)*(1 + (directionchange / 3)) - stillchange;

        if(lazy > clever && lazy > hyperactive){
            return 'Lazy';
        }
        else if(clever >= lazy && clever >= hyperactive){
            return 'Clever';
        }
        else{
            return 'Hyperactive';
        }

    }

    function updatemessage(msg){
        msgtext.text = msg;
        message.visible = true;
    }

    function upload() {
        var url = 'https://cdown.pf-control.de/pixl/upload.php?dna='+page.dna+'&name='+page.name+'&age='+page.age; // alias domain for rec0de.net with valid SSL cert

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

                    if(text === 'E1'){
                        updatemessage('Error: Corrupted DNA');
                    }
                    else if(text === 'E2'){
                        updatemessage('Error: Name too long');
                    }
                    else if(text.length < 6){
                        updatemessage('Done! Code: '+text);
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

    SilicaFlickable {
        anchors.fill: parent
        height: parent.height
        contentHeight: col.height + 10
        id: flick

        PullDownMenu {
            id: pullDownMenu

            MenuItem {
                id: uploadMenuAction
                visible: page.local
                text: "Upload"
                onClicked: {
                    // If first upload
                    if(DB.getsett(4) != 1){
                        var dialog = pageStack.push("../components/dialog_firstupload.qml", {"name": page.name})
                        dialog.accepted.connect(function() {
                            // Set firstupload to true
                            DB.setsett(4, 1);
                            // Upload animal
                            upload();
                        })
                    }
                    else{
                        // Upload animal
                        upload();
                    }
                }
            }

            MenuItem {
                id: renameMenuAction
                visible: page.local
                text: "Rename"
                onClicked: {
                    var dialog = pageStack.push("../components/dialog.qml", {"name": page.name})
                    dialog.accepted.connect(function() {
                        page.name = dialog.name;
                        DB.addset(page.dna, page.name, page.age);
                    })
                }
            }

            MenuItem {
                id: homeMenuAction
                visible: !page.local
                text: "Send home"
                onClicked: {
                    DB.delnonlocal(page.dna) // Remove non-local animal
                }
            }
        }

        VerticalScrollDecorator{}

        Column {
            id: col
            width: parent.width
            anchors.margins: Theme.paddingLarge
            spacing: Theme.paddingMedium

            PageHeader {
                title: "About " + page.name
            }

            SectionHeader {
                text: "Image"
            }

            Image {
                id: image
                source: '../img/moose2.png'
                width: sourceSize.width * 2
                height: sourceSize.height * 2
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                text: page.name
                font.pixelSize: Theme.fontSizeExtraSmall
                anchors.horizontalCenter: parent.horizontalCenter
            }

            SectionHeader {
                text: "Species"
            }

            Label {
                id: speclabel
                text: ''
                anchors.horizontalCenter: parent.horizontalCenter
            }

            SectionHeader {
                text: "Age"
            }

            Label {
                text: Math.floor(page.age/400)
                anchors.horizontalCenter: parent.horizontalCenter
            }


            SectionHeader {
                text: "Personality"
            }

            Label {
                text: pers1()
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                text: pers2()
                anchors.horizontalCenter: parent.horizontalCenter
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
