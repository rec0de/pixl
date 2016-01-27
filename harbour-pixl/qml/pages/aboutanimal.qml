import QtQuick 2.0
import Sailfish.Silica 1.0
import 'data.js' as DB

Page {
    id: page
    property string dna
    property string name
    property string newname
    property bool local
    property int age
    property int id
    property int namegender
    property var specieslist: new Array('Common Moose', 'Dark Moose', 'Red Moose', 'Beige Moose')
    property int species
    property bool debug
    property bool ancestor: false;

    Component.onCompleted: {
        DB.initialize();

        // Check for debug mode
        if(DB.getsett(1) == 1){
            page.debug = true;
        }
        else{
            page.debug = false;
        }

        // Attempt to get data from ancestors DB
        if(local){
            var data = DB.ancestors_getdata(page.id);
            if(data !== false){
                page.name = data.name;
                page.dna = data.dna;
            }
        }

        var dna = page.dna;
        var basepath = '../img/moose';
        var color = parseInt(dna.substr(2, 2), 2) + 1;
        page.species = color - 1;
        image.source = basepath + color + '.png';
        speclabel.text = page.specieslist[species];

        // Get animal parents
        var parents = DB.ancestors_get(id);
        parentnamea.text = parents[0];
        parentnameb.text = parents[2];
        parentnamea.dna = parents[1];
        parentnameb.dna = parents[3];
        parentnamea.id = parents[4];
        parentnameb.id = parents[5];

        if(parents[1] === '0'){
            // Display missing moose graphic
            parentimagea.source = '../img/moose_sw.png';
        }
        else{
            parentimagea.source = '../img/moose' + (parseInt(parents[1].substr(2, 2), 2) + 1) + '.png';
        }

        if(parents[3] === '0'){
            // Display missing moose graphic
            parentimagea.source = '../img/moose_sw.png';
        }
        else{
            parentimageb.source = '../img/moose' + (parseInt(parents[3].substr(2, 2), 2) + 1) + '.png';
        }

        // Get age from DB
        if(local){
            if(DB.getage(page.id) !== false){
                page.age = Math.round(DB.getage(id)/400);
                agetext.text = page.age;
            }
            else{
                agetext.text = 'Deceased';
                page.ancestor = true;
            }
        }
    }

    function pers1(){
        var dna = page.dna;
        var energystill = parseInt(dna.substr(20, 3), 2)/8;
        var minspeed = parseInt(dna.substr(27, 3), 2)/8;
        var maxspeed = parseInt(dna.substr(30, 3), 2)/8;
        var energymoving = parseInt(dna.substr(24, 4), 2)/16;
        var maxenergy = parseInt(dna.substr(17, 3), 2)/8;

        var hungry = (1 + energystill)*(1 + energymoving) - maxspeed*1.2; // Between 0 and 4
        var fast = (1 + minspeed)*(1 + maxspeed) - energymoving/2.4; // Between 0 and 4
        var untiring = (2 - hungry/2)*(1+maxenergy); // Between 0 and 4

        if(hungry > fast && hungry > untiring){
            return 'Hungry ('+Math.round((hungry/4)*100)+'%)';
        }
        else if(fast >= hungry && fast >= untiring){
            return 'Fast ('+Math.round((fast/4)*100)+'%)';
        }
        else{
            return 'Untiring ('+Math.round((untiring/4)*100)+'%)';
        }
    }
    function pers2(){
        var dna = page.dna;
        var viewarea = parseInt(dna.substr(4, 3), 2)/8;
        var movingchange = parseInt(dna.substr(7, 3), 2)/8;
        var stillchange = parseInt(dna.substr(10, 3), 2)/8;
        var directionchange = parseInt(dna.substr(13, 4), 2)/16;
        var searchingduration = parseInt(dna.substr(36, 4), 2)/16;

        var lazy = movingchange*4 - stillchange*1.2;
        var clever = viewarea*1.8 + searchingduration*1.8;
        var hyperactive = (stillchange*2)+(directionchange*2) - movingchange;

        if(lazy > clever && lazy > hyperactive){
            return 'Lazy ('+Math.round((lazy/4)*100)+'%)';
        }
        else if(clever >= lazy && clever >= hyperactive){
            return 'Clever ('+Math.round((clever/4)*100)+'%)';
        }
        else{
            return 'Hyperactive ('+Math.round((hyperactive/4)*100)+'%)';
        }

    }

    function pers3(){ // Social character trait
        var dna = page.dna;
        var socialtrait = parseInt(dna.substr(0, 2), 2);
        if(socialtrait === 0){
            return 'Caring';
        }
        else if(socialtrait === 1){
            return 'Egoist';
        }
        else if(socialtrait === 2){
            return 'Communicative';
        }
        else if(socialtrait === 3){
            return 'Solitary';
        }
    }

    function updatemessage(msg){
        msgtext.text = msg;
        message.visible = true;
    }

    function upload() {
        var url = 'https://rec0de.net/pixl/upload.php?dna='+page.dna+'&name='+page.name+'&age='+(page.age*400);

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
            visible: !page.ancestor

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
                        page.namegender = dialog.genindex;
                        page.newname = dialog.name;
                        DB.setnamegender(page.id, page.namegender); // Set name gender
                        if(page.newname !== ''){
                            page.name = page.newname;
                            DB.addset(page.dna, page.name, page.age, page.id); // Rename in animals table
                            DB.ancestors_rename(page.id, page.name); // Rename in ancestors table
                        }
                    })
                }
            }

            MenuItem {
                id: homeMenuAction
                visible: !page.local
                text: "Send home"
                onClicked: {
                    DB.delnonlocal(page.id); // Remove non-local animal
                    closer.start();
                }

                Timer{
                    id: closer
                    interval: 300
                    running: false
                    repeat: false
                    onTriggered:{
                        pageStack.pop();
                    }
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
                smooth: false
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
                id: agetext
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

            Label {
                visible: true // Work in progress
                text: pers3()
                anchors.horizontalCenter: parent.horizontalCenter
            }

            SectionHeader {
                text: "Parents"
            }

            Row {
                width: parent.width

                Column{
                    width: parent.width / 2

                    Image {
                        id: parentimagea
                        source: '../img/moose_sw.png'
                        width: sourceSize.width
                        height: sourceSize.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                if(parentnamea.dna !== '0'){
                                    pageStack.push(Qt.resolvedUrl("aboutanimal.qml"), {name: parentnamea.text, dna: parentnamea.dna, age: 0, local: true, ancestor: true, id: parentnamea.id});
                                }
                            }
                        }
                    }
                    Label{
                        id: parentnamea
                        font.pixelSize: Theme.fontSizeExtraSmall
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: 'ParentA'
                        property string dna
                        property int id
                    }
                }

                Column{
                    width: parent.width / 2

                    Image {
                        id: parentimageb
                        source: '../img/moose_sw.png'
                        width: sourceSize.width
                        height: sourceSize.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                if(parentnameb.dna !== '0'){
                                    pageStack.push(Qt.resolvedUrl("aboutanimal.qml"), {name: parentnameb.text, dna: parentnameb.dna, age: 0, local: true, ancestor: true, id: parentnameb.id});
                                }
                            }
                        }
                    }
                    Label{
                        id: parentnameb
                        font.pixelSize: Theme.fontSizeExtraSmall
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: 'ParentB'
                        property string dna
                        property int id
                    }
                }
            }

            SectionHeader {
                text: "Debug"
                visible: page.debug
            }

            Label {
                text: 'ID: '+page.id
                visible: page.debug
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
            }

            Label {
                text: 'DNA: '+ parseInt(dna, 2).toString(16); // Base16 representation of DNA
                visible: page.debug
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
