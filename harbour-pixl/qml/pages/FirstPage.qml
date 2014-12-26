import QtQuick 2.0
import QtQuick.Window 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import 'data.js' as DB


Page {
    id: page
    property var animals: new Array()
    property var food: new Array()
    property var hearts: new Array()
    property bool debug: false //Display debug tools and disable automatic animal spawning
    property bool slowdown: true // Enables/Disables age based animal slowdown
    property int foodspawn: 85 // Food spawn probability (per tick)

    Component.onCompleted: {
        DB.initialize();

        // Load local animals from DB
        var data = DB.getall();
        var animal_comp = Qt.createComponent("../components/animal.qml");

        if(data != false){
            for(var i = 0; i < data.length; i++){
                var temp = animal_comp.createObject(page, {x: Math.floor(Math.random()*page.width), absy: Math.floor(Math.random()*page.height), name: data[i].name, age: data[i].age});
                temp.importfromdna(data[i].dna);
                temp.tick(); // Move animal to target coords
                page.animals.push(temp);
            }
        }

        // Load guest animals from DB
        data = DB.getnonlocal();

        if(data != false){
            for(i = 0; i < data.length; i++){
                temp = animal_comp.createObject(page, {x: Math.floor(Math.random()*page.width), absy: Math.floor(Math.random()*page.height), name: data[i].name, age: data[i].age, local: false});
                temp.importfromdna(data[i].dna);
                temp.tick(); // Move animal to target coords
                page.animals.push(temp);
            }
        }

        // Christmas mode (Only in december)
        var today = new Date();
        if(today.getMonth() == 11){ // Uses zero based indexing for months
          tree.source = '../img/tree_xmas.png'; // Display christmas tree

            // Display moose hats for dark and common moose
            for(i = 0; i < page.animals.length; i++){
              if(page.animals[i].dna.substr(2, 2) == '00'){
                page.animals[i].source = '../img/moose1_xmas.png';
              }
              else if(page.animals[i].dna.substr(2, 2) == '01'){
                page.animals[i].source = '../img/moose2_xmas.png';
              }
            }
        }

        // Update other settings
        updatesettings();
    }

    FontLoader { id: pixels; source: "../img/pixelmix.ttf" }

    // Loads and applys settings from DB
    function updatesettings(){

        // Update night mode
        if(DB.getsett(0) == 1){
            rect.color = '#334613';
            pond.source = "../img/pond_night.png";
        }
        else{
            rect.color = '#84b331';
            pond.source = "../img/pond_day.png";
        }

        // Update debug mode
        if(DB.getsett(1) == 1){
            page.debug = true;
        }
        else{
            page.debug = false;
        }

        // Update age slowdown
        if(DB.getsett(2) != 0){
            page.slowdown = true;
        }
        else{
            page.slowdown = false;
        }

        // Update food rate
        if(DB.getsett(3) != -1){
            page.foodspawn = DB.getsett(3);
        }
        else{
            page.foodspawn = 85; // Use default if DB value is not set
        }

        // Remove removed guest moose
        for(var i = 0; i < page.animals.length; i++){
          if(!page.animals[i].local){
            if(!DB.checknonlocal(page.animals[i].dna)){
                // If moose has been sent home, remove moose
                page.animals[i].destroy();
                page.animals.splice(i, 1);
                i--;
            }
          }
        }

        // Add new guest animals
        var guestmoose = DB.getnonlocal();
        var animal_comp = Qt.createComponent("../components/animal.qml");
        var loaded = false;

        for(i = 0; i < guestmoose.length; i++){
            loaded = false;

            for(var j = 0; j < page.animals.length; j++){
                if(page.animals[j].dna == guestmoose[i].dna){
                    // Moose is already loaded
                    loaded = true;
                    break;
                }
            }
            if(!loaded){
                // If moose is not loaded, load moose
                var temp = animal_comp.createObject(page, {x: Math.floor(Math.random()*page.width), absy: Math.floor(Math.random()*page.height), name: guestmoose[i].name, age: guestmoose[i].age, local: false});
                temp.importfromdna(guestmoose[i].dna);
                temp.tick(); // Move animal to target coords
                page.animals.push(temp);
            }
        }


    }

    // Makes the start text blink
    function blink() {
        start.visible = !start.visible;
    }

    // Pause game and go to about page
    function about() {
        pageStack.push(Qt.resolvedUrl("about.qml"))
        pause();
    }

    // Pause game and go to help page
    function help() {
        pageStack.push(Qt.resolvedUrl("help.qml"))
        pause();
    }

    function pause() {
        // Save all animals to DB
        backup();

        ticker.running = false;
        blinker.running = false;
        cleaner.running = false;
        saver.running = false;
        start.visible = true;
        start.text = 'tap to resume'
    }

    function backup() {
        // Save all animals to DB
        for(var i = 0; i < page.animals.length; i++){
            if(page.animals[i].local){
                DB.addset(page.animals[i].dna, page.animals[i].name, page.animals[i].age);
            }
            else{
                DB.addnonlocal(page.animals[i].dna, page.animals[i].name, page.animals[i].age);
            }
        }
    }

    function touch(x, y){

        // If game was paused
        if(ticker.running == false){

            // Update all settings
            updatesettings();

            // Update animal names
            for(var i = 0; i < page.animals.length; i++){
                if(page.animals[i].local){
                    page.animals[i].name = DB.getname(page.animals[i].dna);
                }
            }

            // Start Timers & reset labels
            blinker.running = false;
            ticker.running = true;
            cleaner.running = true;
            saver.running = true;
            start.visible = false;
            menu2.visible = false;
            logo.visible = true;
        }
        else{
          // Spawn food at touch location
          if(x < (page.width - 30)){ // Avoid uneatable food
              var food_comp = Qt.createComponent("../components/food.qml");
              var temp = food_comp.createObject(page, {x: x, y: y, manual: true});
              page.food.push(temp);
          }
        }
    }

    function options(){
        pause();
        menu2.visible = true;
        logo.visible = false;
    }

    function tickall(){
        // Pause if minimized
        if(!Qt.application.active){
            //console.log ("Application minimized, pausing.");
            pause();
        }

        // Spawn food
        if(Math.floor(Math.random()*page.foodspawn) == 1){
            var x = Math.floor(Math.random()*(page.width-30));
            var y = Math.floor(Math.random()*(page.height-70))+60;
            var food_comp = Qt.createComponent("../components/food.qml");
            var temp = food_comp.createObject(page, {x: x, y: y});
            page.food.push(temp);
        }

        // Spawn 3 animals on startup
        if(page.animals.length < 3 && !page.debug){
            spawnanimal();
        }


        // Trigger tick() for all animals
        var animals = page.animals;

        for (var i = 0; i < animals.length; i++){
            if(animals[i].alive){
                animals[i].tick();
            }
            else{ // Remove dead animals
                if(animals[i].local){
                    DB.deleterow(animals[i].dna);
                }
                else{
                    DB.delnonlocal(animals[i].dna);
                }

                animals.splice(i, 1);
                i--;
            }
        }

    }

    function cleanup(){
        // Delete despawned food
        var food = page.food;

        for (var i = 0; i < food.length; i++){
            if(!food[i].active){
                food.splice(i, 1);
                i--;
            }
        }

        // Delete despawned hearts
        var hearts = page.hearts;

        for (var i = 0; i < hearts.length; i++){
            if(!hearts[i].active){
                hearts.splice(i, 1);
                i--;
            }
        }
    }

    function spawnanimal(){
        var dna = randna();
        var animal_comp = Qt.createComponent("../components/animal.qml");
        // Moose spawned by simulation spawn at age 18 to reduce time to mating
        var temp = animal_comp.createObject(page, {x: Math.floor(Math.random()*page.width), absy: Math.floor(Math.random()*(page.height-60)+60), age: 18*400});
        temp.importfromdna(dna);
        page.animals.push(temp);
    }

    function createanimal(dna, x, y){
        var animal_comp = Qt.createComponent("../components/animal.qml");
        var temp = animal_comp.createObject(page, {x: x, absy: y});
        temp.importfromdna(dna);
        page.animals.push(temp);
    }

    function randna(){
        var i;
        var dna = '';
        for(i = 0; i < 40; i++){
            if(Math.floor(Math.random()*2) == 1){
                dna += '1';
            }
            else{
                dna += '0';
            }
        }
        return dna;
    }


    Timer {
        id: blinker
        interval: 750
        running: true
        repeat: true
        onTriggered: blink()
    }

    Timer {
        id: ticker
        interval: 35
        running: false
        repeat: true
        onTriggered: tickall()
    }

    Timer {
        id: cleaner
        interval: 2000
        running: true
        repeat: true
        onTriggered: cleanup()
    }

    Timer {
        id: saver
        interval: 5000
        running: true
        repeat: true
        onTriggered: backup()
    }

    Rectangle {
        id: rect
        width: parent.width
        height: parent.height
        color: '#84b331'
        MouseArea {
        anchors.fill: parent
        onClicked: touch(mouseX, mouseY)
        }
        Behavior on color {
            ColorAnimation {duration: 700 }
        }
    }

    Image {
        id: background
        source: "../img/back_trans.png"
        opacity: 1
        width: rect.width
        height: rect.height
        fillMode: Image.Tile
    }

    Image {
        source: "../img/tree.png"
        id: tree
        opacity: 1
        width: 80
        height: 110
        x: 300
        y: 700
        z: 10000
    }
    Image {
        source: "../img/tree_shadow.png"
        id: treeshadow
        opacity: 1
        width: 80
        height: 20
        x: 300
        y: 790
        z: 0
    }


    Image {
        source: "../img/pond_day.png"
        id: pond
        opacity: 1
        width: 100
        height: 100
        x: 200
        y: 200
    }


    Label {
        id: start
        visible: true
        text: "tap to start"
        font.pixelSize: 24
        font.family: pixels.name
        anchors.centerIn: parent
    }

    Rectangle{
        id: menu
        y: -5
        x: -5
        color: 'transparent'
        height: 65
        width: rect.width + 10
        border.color: '#ffffff'
        border.width: 5
        MouseArea {
            anchors.fill: parent
            onClicked: options()
        }

        Rectangle{
            id: menu2
            visible: false
            color: 'transparent'
            anchors.fill: parent;



            Label {
                id: info
                text: 'Info'
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 42
                font.family: pixels.name
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                width: parent.width/2
                MouseArea {
                    anchors.fill: parent
                    onClicked: about()
                }
            }


            Label {
                id: helpbutton
                text: 'Help'
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 42
                font.family: pixels.name
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                width: parent.width/2
                MouseArea {
                    anchors.fill: parent
                    onClicked: help()
                }
            }
        }
    }


    Rectangle{
        id: debug
        visible: page.debug
        y: 55
        x: -5
        color: 'transparent'
        height: 65
        width: rect.width + 10
        border.color: '#ffffff'
        border.width: 5

        Label {
           id: debug_bkill
           text: 'Kill'
           horizontalAlignment: Text.AlignHCenter
           font.pixelSize: 42
           font.family: pixels.name
           anchors.verticalCenter: parent.verticalCenter
           anchors.left: parent.left
           width: parent.width/2
           MouseArea {
              anchors.fill: parent
              onClicked: page.animals[0].energy = 0
           }
        }


        Label {
           id: debug_bspawn
           text: 'Spawn'
           horizontalAlignment: Text.AlignHCenter
           font.pixelSize: 42
           font.family: pixels.name
           anchors.verticalCenter: parent.verticalCenter
           anchors.right: parent.right
           width: parent.width/2
           MouseArea {
              anchors.fill: parent
              onClicked: spawnanimal()
           }
        }
    }


    Label {
        y: 5
        id: logo
        text: 'Menu'
        font.pixelSize: 42
        font.family: pixels.name
        anchors.horizontalCenter: menu.horizontalCenter
    }
}
