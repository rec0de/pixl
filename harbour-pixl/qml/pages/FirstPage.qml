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
    property bool debug: false // Display debug tools and disable automatic animal spawning
    property bool slowdown: true // Enables/Disables age based animal slowdown
    property int foodspawn: 85 // Food spawn probability (per tick)
    property bool daynight: false // Activates day/night cycle
    property bool paused: true // Game is paused
    property int playtime: 0 // Time played in seconds

    Component.onCompleted: {
        DB.initialize();

        // Update DB if necessary
        if(DB.getsett(5) < 2 || DB.getsett(5) === -1){

            var guestupdatedata = DB.oldnonlocal();
            var updatedata = DB.oldall();

            var i = -1; // Sets id to 0 if no animals are moved
            var j = -1;

            DB.updateid();


            // Save animals to new DB
            if(updatedata !== false){
                for(i = 0; i < updatedata.length; i++){
                    DB.addset(updatedata[i].dna, updatedata[i].name, updatedata[i].age, i);
                    DB.ancestors_add(updatedata[i].dna, updatedata[i].name, i, -1, -1) // Add ancestor entry with unknown parents
                }
            }

            // Add IDs to existing nonlocal animals
            if(guestupdatedata !== false){
                for(j = 0; j < guestupdatedata.length; j++){
                    DB.addnonlocal(guestupdatedata[j].dna, guestupdatedata[j].name, guestupdatedata[j].age, j);
                }
            }

            DB.setsett(6, i+1); // Set next id
            DB.setsett(7, j+1); // Set next id for nonlocal animals
            DB.setsett(5, 2);
        }


        // Reset guest DB to clear corrupted moose after update
        if(DB.getsett(5) < 3 || DB.getsett(5) === -1){
            DB.clearnonlocal();
            DB.setsett(5, 3);
        }

        // Log starting message on first startup or after update
        if(DB.getsett(5) < 4 || DB.getsett(5) === -1){
            log('firststart', false, false, false);
            DB.setsett(5, 4);
        }


        // Load local animals from DB
        var data = DB.getall();
        var animal_comp = Qt.createComponent("../components/animal.qml");

        if(data != false){
            for(var i = 0; i < data.length; i++){
                var temp = animal_comp.createObject(page, {x: Math.floor(Math.random()*page.width), absy: Math.floor(Math.random()*page.height), name: data[i].name, age: data[i].age, id: data[i].id});
                temp.importfromdna(data[i].dna);
                temp.tick(); // Move animal to target coords
                page.animals.push(temp);
            }
        }

        // Load guest animals from DB
        data = DB.getnonlocal();

        if(data != false){
            for(i = 0; i < data.length; i++){
                temp = animal_comp.createObject(page, {x: Math.floor(Math.random()*page.width), absy: Math.floor(Math.random()*page.height), name: data[i].name, age: data[i].age, id: data[i].id,local: false});
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

        // Log ambient message
        if(pond.source == '../img/pond_night.png'){
            log('ambient_night', false, false, false);
        }
        else{
            log('ambient_day', false, false, false);
        }
    }

    FontLoader { id: pixels; source: "../img/pixelmix.ttf" }

    // Loads and applys settings from DB
    function updatesettings(){

        // Update night mode
        if(DB.getsett(0) == 1){
            rect.color = '#334613';
            pond.source = "../img/pond_night.png";
            page.daynight = false;
        }
        else if(DB.getsett(0) == 0){
            rect.color = '#84b331';
            pond.source = "../img/pond_day.png";
            page.daynight = false;
        }
        else{
            timecycle();
            page.daynight = true;
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
            if(!DB.checknonlocal(page.animals[i].id)){
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
                if(page.animals[j].dna === guestmoose[i].dna && page.animals[j].name === guestmoose[i].name){
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
        page.paused = true;
    }

    function backup() {
        // Save all animals to DB
        for(var i = 0; i < page.animals.length; i++){
            if(page.animals[i].local){
                DB.addset(page.animals[i].dna, page.animals[i].name, page.animals[i].age, page.animals[i].id);
            }
            else{
                DB.addnonlocal(page.animals[i].dna, page.animals[i].name, page.animals[i].age, page.animals[i].id);
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
                    page.animals[i].name = DB.getname(page.animals[i].id);
                }
            }

            // Start Timers & reset labels
            page.paused = false;
            animalstats.visible = false;
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
            var y = Math.floor(Math.random()*(page.height-90))+60;
            var food_comp = Qt.createComponent("../components/food.qml");
            var temp = food_comp.createObject(page, {x: x, y: y});
            page.food.push(temp);
        }

        // Spawn 3 animals on startup
        if(page.animals.length < 3 && !page.debug){
            // Spawn and log only once if there are no moose
            if(page.animals.length === 0){
                log('spawnthree', false, false, false);
                spawnanimal(false);
                spawnanimal(false);
                spawnanimal(false);
            }
            else{
                spawnanimal(true);
            }
        }


        // Trigger tick() for all animals
        var animals = page.animals;

        for (var i = 0; i < animals.length; i++){
            if(animals[i].alive){
                animals[i].tick();
            }
            else{ // Remove dead animals
                if(animals[i].local){
                    DB.deleterow(animals[i].id);
                }
                else{
                    DB.delnonlocal(animals[i].id);
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

        // Increment playtime
        page.playtime = DB.getsett(9);
        DB.setsett(9, playtime + 2);
    }

    function spawnanimal(writelog){
        var dna = randna();
        var id = DB.getsett(6); // Get new unique id
        if(id === '-1'){
            id = 0;
        }
        var name = ranname();
        var animal_comp = Qt.createComponent("../components/animal.qml");
        // Moose spawned by simulation spawn at age 18 to reduce time to mating
        var temp = animal_comp.createObject(page, {x: Math.floor(Math.random()*page.width), absy: Math.floor(Math.random()*(page.height-60)+60), age: 18*400, id: id, name: name});
        temp.importfromdna(dna);
        page.animals.push(temp);
        DB.setsett(6, id+1); // Increment nextid
        DB.ancestors_add(dna, name, id, -1, -1) // Add ancestor entry with unknown parents
        if(writelog){
            log('spawn', name, dna, id); // Log spawning
        }
    }


    function createanimal(dna, x, y, parenta, parentb){
        var animal_comp = Qt.createComponent("../components/animal.qml");
        var id = DB.getsett(6); // Get new unique id
        if(id === '-1'){
            id = 0;
        }
        var name = ranname();
        var temp = animal_comp.createObject(page, {x: x, absy: y, id: id, name: name});
        temp.importfromdna(dna);
        page.animals.push(temp);
        DB.setsett(6, id+1); // Increment nextid
        DB.ancestors_add(dna, name, id, parenta, parentb) // Add ancestor entry given parents
         log('birth', name, dna, id); // Log birth
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

    // returns random name
    function ranname(){
        var names = new Array();
        // Moose in different languages
        names = ['Elg', 'Eland', 'Poder', 'Hirvi', 'Elan', 'Elch', 'Elgur', 'Munsu', 'Eilc', 'Alce', 'Alces', 'Briedis', 'Atawhenua', 'Losi', 'Uncal', 'Älg', 'Elciaid'];
        var index = Math.floor(Math.random()*names.length);
        return names[index];
    }


    // Adjusts background color relative to current time
    function timecycle(){
        if(page.daynight){
            var currentTime = new Date ( );

            var currentHours = currentTime.getHours();
            var currentMinutes = currentTime.getMinutes();
            var currentSeconds = currentTime.getSeconds();

            // Get seconds from midnight
            var midnight = (currentHours*60*60)+(currentMinutes*60)+currentSeconds; // Between 0 and 86640

            // Replace pond graphic if needed
            if(midnight < 18000 || midnight > 66000){
                // If state has changed from day to night, log sundown
                if(timecycler.prevtime !== -1 && (!(timecycler.prevtime < 18000 || timecycler.prevtime > 66000))){
                    log('sundown', false, false, false);
                }
                pond.source = '../img/pond_night.png';
            }
            else{
                // If state has changed from day to night, log sunrise
                if(timecycler.prevtime !== -1 && (timecycler.prevtime < 18000 || timecycler.prevtime > 66000)){
                    log('sunrise', false, false, false);
                }
                pond.source = '../img/pond_day.png';
            }

            // Set prevtime
            timecycler.prevtime = midnight;

            // Calculate multiplicator
            var mult = Math.abs(Math.sin(midnight * (Math.PI/86640)))*0.8 + 0.2;

            // Calculate color shade
            var r = 132; // Base color
            var g = 179;
            var b = 49;

            var r2 = Math.floor(r * mult);
            var g2 = Math.floor(g * mult);
            var b2 = Math.floor(b * mult);

            var color = (r2 < 16 ? "0" : "" ) + r2.toString(16) + (g2 < 16 ? "0" : "" ) + g2.toString(16) + (b2 < 16 ? "0" : "" ) + b2.toString(16);
            rect.color = '#' + color;
        }
    }


    // Contains log texts for various events
    function log(event, name, dna, id){
        var texts = new Array();
        var colorlist = new Array('brown', 'dark', 'red', 'beige');
        var namegender = DB.getnamegender(id);

        var hisher = (namegender == 1 ? "her" : "his");
        var himher = (namegender == 1 ? "her" : "him");
        var heshe = (namegender == 1 ? "she" : "he");

        // Capitalizes first letter
        String.prototype.capitalize = function() {
            return this.charAt(0).toUpperCase() + this.slice(1);
        }


        if(dna !== false){
            var color = colorlist[parseInt(dna.substr(2, 2), 2)];
        }

        if(event === 'spawn'){
            texts = ['A new moose enters the clearing. '+hisher.capitalize()+' '+color+' fur is ruffeled.', 'A young moose walks out of the deep forest surrounding the clearing.', 'A moose emerges from the bushes that surround the glade. '+heshe.capitalize()+'\'s new here.', 'A new moose appears on the glade. Where did '+heshe+' come from?', 'A strange sound comes out of the bushes. It\'s a '+color+' moose. You haven\'t seen '+himher+' here before.'];
        }
        else if(event === 'starving'){
            texts = [name + ' is starving, barely able to keep walking.', name+' is hungering, desperately trying to find food. ', name+' is desperately looking for something edible.'];
        }
        else if(event === 'birth'){
            texts = ['A new moose is born. '+heshe.capitalize()+' looks cute with '+hisher+' huge dark eyes and '+color+' fur.'];
        }
        else if(event === 'death'){
            texts = [name + ' collapses on the ground, breathing for one last time.', 'A corpse lies on the ground, nothing but skin and bone. It\'s '+name+'.', name+' looks at you for the last time. '+hisher.capitalize()+' big eyes close, slowly. '+heshe.capitalize()+'\'s dead. You know it.', name+' staggers towards you, '+hisher+' '+color+' fur is tattered. '+heshe.capitalize()+' collapses in front of you. You know '+heshe+' won\'t stand up again.'];
        }
        else if(event === 'ambient_day'){
            texts = ['The clearing lies calm in the light breeze. The tall grass is waving slowly.', 'You can see small clouds slowly drifting away above you.', 'You can see the reflection of the big firs in the calm pond.', 'A single flower stands in the tall grass, nodding slowly in the wind.'];
        }
        else if(event === 'ambient_night'){
            texts = ['The pale moon shines on the glade, wandering across the dark sky.', 'The deep black sky above you seems endless, infinite.', 'The glade looks different in the silver moonshine. Mystical.', 'Small waves form on the ponds surface, swirling trough the reflected sky.', 'Pale white clouds wander across the sky like scraps of cloth in a dark, endless river.', 'Once the sun has disappeared behind the trees, the forest around you feels strangely alive.'];
        }
        else if(event === 'sunrise'){
            texts = ['The sun rises slowly above the treetops. A new day begins.', 'A fresh morning breeze blows trough the grass as the sun begins to rise.', 'Small dewdrops form in the tall grass as the sun rises above the trees.'];
        }
        else if(event === 'sundown'){
            texts = ['The descending sun paints the sky deep orange. The night is about to begin.', 'The sun is setting. It\'s getting darker around.', 'Slowly, the sun disappears behind a high fir. The night is coming.'];
        }
        else if(event === 'spawnthree'){
            texts = ['Three moose are standing in front of you. They look friendly.', 'You look around. There, near the edge of the glade, you see three moose.', 'In the high grass you can see three moose eating flowers. They look calm.', 'You can see three moose walking around on the clearing, probably searching food.'];
        }
        else if(event === 'firststart'){
            texts = ['Your story begins on a small clearing in a dark forest.', 'This is where it all starts. A small clearing in the woods.', 'This is the beginning of your story. A small glade in the endless forest.'];
        }

        // Choose random text & save to log
        var index = Math.floor(Math.random()*texts.length);
        DB.log_add(texts[index]);
        updatelogmsg(texts[index]);
    }

    // Shows & updates text of log message
    function updatelogmsg(text){
        msgtext.text = text;
        logmsg.visible = true;
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
        running: false
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

    Timer {
        id: timecycler
        interval: 10000
        running: Qt.ApplicationActive && page.daynight
        repeat: true
        onTriggered: timecycle()
        property int prevtime: -1
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

        Label {
            y: 5
            id: logo
            text: 'Menu'
            font.pixelSize: 42
            font.family: pixels.name
            anchors.horizontalCenter: menu.horizontalCenter
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
              onClicked: {
                  // Upper limit to avoid critical lag
                  if(page.animals.length < 31){
                    spawnanimal(true)
                  }
              }
           }
        }
    }

    Rectangle{
        id: logmsg
        visible: false
        y: -5
        x: -5
        color: rect.color
        height: msgtext.height + 30;
        width: rect.width + 10
        border.color: '#ffffff'
        border.width: 5
        MouseArea {
            anchors.fill: parent
            onClicked: parent.visible = false
        }
        Label {
            id: msgtext
            visible: parent.visible
            text: 'unknown'
            font.pixelSize: 21
            font.family: pixels.name
            wrapMode: Text.WordWrap
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: Theme.paddingMedium
                rightMargin: Theme.paddingMedium
            }
        }
     }

    Rectangle{
        id: animalstats
        visible: false
        y: rect.height - 90
        x: 0
        color: rect.color
        height: 90
        width: rect.width
        property string a_name
        property string a_dna
        property string a_energy
        property int a_age
        property bool a_local
        property int a_id
        MouseArea {
            anchors.fill: parent
            onClicked: pageStack.push(Qt.resolvedUrl("aboutanimal.qml"), {name: parent.a_name, dna: parent.a_dna, age: parent.a_age, local: parent.a_local, id: parent.a_id});
        }

        onA_dnaChanged: {
            charactera.text = pers1(a_dna);
            characterb.text = pers2(a_dna)
        }

        Column{
            width: parent.width / 2
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.topMargin: 15

            Label {
                text: animalstats.a_name
                font.pixelSize: 24
                font.family: pixels.name
            }
            Label {
                text: 'Age: ' + Math.round(animalstats.a_age/400)
                font.pixelSize: 24
                font.family: pixels.name
            }
            Label {
                text: 'Energy: ' + animalstats.a_energy
                font.pixelSize: 24
                font.family: pixels.name
            }
        }
        Column{
            width: parent.width / 2
            anchors.right: parent.right
            anchors.topMargin: 15

            Label {
                id: charactera
                text: 'Unknown'
                font.pixelSize: 24
                font.family: pixels.name
            }
            Label {
                id: characterb
                text: 'Unknown'
                font.pixelSize: 24
                font.family: pixels.name
            }
        }
    }

    // 'Border' for animal info
    Rectangle{
        visible: animalstats.visible
        y: rect.height - 95
        height: 5
        width: parent.width
        color: '#ffffff'
    }

    // Character trait calculation for animal info
    function pers1(dna){
        var energystill = parseInt(dna.substr(20, 3), 2)/8;
        var minspeed = parseInt(dna.substr(27, 3), 2)/8;
        var maxspeed = parseInt(dna.substr(30, 3), 2)/8;
        var energymoving = parseInt(dna.substr(24, 4), 2)/16;
        var maxenergy = parseInt(dna.substr(17, 3), 2)/8;

        var hungry = (1 + energystill)*(1 + energymoving) - maxspeed*1.2; // Between 0 and 4
        var fast = (1 + minspeed)*(1 + maxspeed) - energymoving/2.4; // Between 0 and 4
        var untiring = (2 - hungry/2)*(1+maxenergy); // Between 0 and 4

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

    function pers2(dna){
        var viewarea = parseInt(dna.substr(4, 3), 2)/8;
        var movingchange = parseInt(dna.substr(7, 3), 2)/8;
        var stillchange = parseInt(dna.substr(10, 3), 2)/8;
        var directionchange = parseInt(dna.substr(13, 4), 2)/16;
        var searchingduration = parseInt(dna.substr(36, 4), 2)/16;

        var lazy = stillchange*4 - movingchange;
        var clever = viewarea*2 + searchingduration*2;
        var hyperactive = (1 + movingchange)*(1 + directionchange) - stillchange;

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
}
