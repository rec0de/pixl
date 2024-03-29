import QtQuick 2.0
import QtQuick.Window 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import 'data.js' as DB


Page {
    id: page
    allowedOrientations: Orientation.All
    property var animals: new Array()
    property var predators: new Array()
    property var food: new Array()
    property var hearts: new Array()
    property var trees: new Array()
    property bool debug: false // Display debug tools and disable automatic animal spawning
    property bool slowdown: true // Enables/Disables age based animal slowdown
    property bool spawnpred: true // Enables/Disables predator spawning
    property bool showmsgs: true // Shows log messages on main screen
    property bool night: false // Indicates nighttime
    property bool firststart: false // True is game is started for first time after update
    property bool showstatus: true // Enables / disables status icons for moose
    property int foodspawn: 85 // Food spawn probability (per tick)
    property bool daynight: false // Activates day/night cycle
    property bool paused: true // Game is paused
    property int playtime: 0 // Time played in seconds
    property int endindex: 0 // Index for end story
    property bool pauseonmsg: false // Pause game on new log message

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

        // Update log table if necessary
        if(DB.getsett(5) < 5 || DB.getsett(5) === -1){

            var oldlogs = DB.log_get_old();

            DB.updatelog();

            // Save old logs to new table
            if(oldlogs !== false){
                for(i = 0; i < oldlogs.length; i++){
                    DB.log_add(oldlogs[i].val, 'Unknown', -1);
                }
            }

            DB.setsett(5, 5);
        }

        // Save first tree to DB
        if(DB.getsett(5) < 6){
            DB.setsett(5, 6);
            DB.tree_add(300, 700);
        }

        // Load local animals from DB
        var data = DB.getall();
        var animal_comp = Qt.createComponent("../components/animal.qml");

        if(data !== false){
            for(var i = 0; i < data.length; i++){
                var temp = animal_comp.createObject(page, {x: Math.floor(Math.random()*page.width), absy: Math.floor(Math.random()*page.height), name: data[i].name, age: data[i].age, id: data[i].id});
                temp.importfromdna(data[i].dna);
                temp.tick(); // Move animal to target coords
                page.animals.push(temp);
            }
        }

        // Load guest animals from DB
        data = DB.getnonlocal();

        if(data !== false){
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

        timecycle(); // Update daytime

        // Log starting message on first startup or after update
        if(DB.getsett(5) < 4 || DB.getsett(5) === -1){
            DB.setsett(5, 4);
            page.firststart = true;
        }
        // Otherwise log ambient message
        else if(page.night){
            log('ambient_night', false, false, false, false);
        }
        else{
            log('ambient_day', false, false, false, false);
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
            page.night = true;
        }
        else if(DB.getsett(0) == 0){
            rect.color = '#84b331';
            pond.source = "../img/pond_day.png";
            page.daynight = false;
            page.night = false;
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

        // Update predator spawning
        if(DB.getsett(11) != 0){
            page.spawnpred = true;
        }
        else{
            page.spawnpred = false;
        }

        // Update log messages
        if(DB.getsett(12) != 0){
            page.showmsgs = true;
        }
        else{
            page.showmsgs = false;
        }

        // Update status icons
        if(DB.getsett(16) != 0){
            page.showstatus = true;
        }
        else{
            page.showstatus = false;
        }

        // Update pause on message
        if(DB.getsett(17) == 1){
            page.pauseonmsg = true;
        }
        else{
            page.pauseonmsg = false;
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
                // Log goodbye message
                page.log('guest_leave', page.animals[i].name, page.animals[i].dna, page.animals[i].id, false);
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
                if(!page.animals[j].local && page.animals[j].id === guestmoose[i].id){
                    // Moose is already loaded
                    loaded = true;
                    break;
                }
            }
            if(!loaded){
                // If moose is not loaded, load moose
                var temp = animal_comp.createObject(page, {x: Math.floor(Math.random()*page.width), absy: Math.floor(Math.random()*page.height), name: guestmoose[i].name, age: guestmoose[i].age, id: guestmoose[i].id, local: false});
                temp.importfromdna(guestmoose[i].dna);
                temp.tick(); // Move animal to target coords
                page.animals.push(temp);
                // Log guest moose message
                page.log('guest_enter', guestmoose[i].name, guestmoose[i].dna, false, false)
            }
        }

        // Delete all trees
        for(i = 0; i < trees.length; i++){
            trees[i].destroy();
        }
        trees = new Array();

        // Load trees from DB
        var data = DB.tree_get();
        var tree_comp = Qt.createComponent("../components/tree.qml");

        if(data !== false){
            for(i = 0; i < data.length; i++){
                temp = tree_comp.createObject(page, {x: data[i].x, y: data[i].y});
                page.trees.push(temp);
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

                // Easter Egg / Inside joke
                var color;
                if(page.animals[i].name === 'Eli'){
                    color = parseInt(page.animals[i].dna.substr(2, 2), 2) + 1;
                    page.animals[i].source = '../img/eegg' + color + '.png';
                }
                else if(page.animals[i].name === 'Julian'){
                    color = parseInt(page.animals[i].dna.substr(2, 2), 2) + 1;
                    page.animals[i].source = '../img/ju' + color + '.png';
                }
                else{
                    color = parseInt(page.animals[i].dna.substr(2, 2), 2) + 1;
                    page.animals[i].source = '../img/moose' + color + '.png';
                }
            }

            // Hide startup message
            logmsg.visible = false;

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
          if(x < (page.width - 30) && y < (page.height - 30)){ // Avoid uneatable food
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
                log('spawnthree', false, false, false, false);
                spawnanimal(false);
                spawnanimal(false);
                spawnanimal(false);
            }
            else{
                if(spawndelayer.running === false){
                    spawndelayer.start(); // Avoid spawning new animal directly after death
                }
            }
        }
        else if(page.firststart){
            log('spawnthree', false, false, false, false); // Log spawntree msg for updated versions with existing moose
            firststart = false;
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

        // Trigger tick() for all predators
        var pred = page.predators;

        for (var i = 0; i < pred.length; i++){
            if(pred[i].alive){
                pred[i].tick();
            }
            else{ // Remove dead predators
                pred.splice(i, 1);
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

        if(page.playtime % 2 === 1){
            playtime = playtime - 1;
        }

        DB.setsett(9, playtime + 2);

        // Log story message randomly (1 in 5 chance every 80 seconds)
        // Average time for complete story: (5*100*22)/60 = ~ 83min = ~ 3h
        if((page.playtime % 80) === 0 && Math.floor(Math.random()*5)==1){
            var index = DB.getsett(10);
            if(index === -1){
                index = 0;
            }
            // Log message & update index
            story(index);
            DB.setsett(10, index+1);
        }

        // Spawn predator randomly (1 in 100 chance every 6 seconds)
        if(page.playtime % 6 === 0 && Math.floor(Math.random()*100)===1){
            spawnpredator();
        }
    }

    function spawnanimal(writelog){
        var dna = randna();
        var id = DB.getsett(6); // Get new unique id
        if(id === '-1'){
            id = 0;
        }
        var ranresult = ranname();
        var name = ranresult[0];
        var namegender = ranresult[1];
        var animal_comp = Qt.createComponent("../components/animal.qml");
        // Moose spawned by simulation spawn at age 18 to reduce time to mating
        var temp = animal_comp.createObject(page, {x: Math.floor(Math.random()*page.width), absy: Math.floor(Math.random()*(page.height-60)+60), age: 18*400, id: id, name: name});
        temp.importfromdna(dna);
        page.animals.push(temp);
        DB.setnamegender(id, namegender);
        DB.setsett(6, id+1); // Increment nextid
        DB.ancestors_add(dna, name, id, -1, -1) // Add ancestor entry with unknown parents
        if(writelog){
            log('spawn', name, dna, id, true); // Log spawning
        }
    }


    function createanimal(dna, x, y, parenta, parentb){
        var animal_comp = Qt.createComponent("../components/animal.qml");
        var id = DB.getsett(6); // Get new unique id
        if(id === '-1'){
            id = 0;
        }
        var ranresult = ranname();
        var name = ranresult[0];
        var namegender = ranresult[1];
        var temp = animal_comp.createObject(page, {x: x, absy: y, id: id, name: name});
        temp.importfromdna(dna);
        page.animals.push(temp);
        DB.setnamegender(id, namegender);
        DB.setsett(6, id+1); // Increment nextid
        DB.ancestors_add(dna, name, id, parenta, parentb) // Add ancestor entry given parents
         log('birth', name, dna, id, true); // Log birth
    }

    function spawnpredator(){
        if(page.spawnpred){
            var animal_comp = Qt.createComponent("../components/predator.qml");

            // Spawn predators at screen edge
            if(Math.floor(Math.random()*2)===0){
                var x = -45;
            }
            else{
                var x = page.width;
            }

            var temp = animal_comp.createObject(page, {x: x, absy: Math.floor(Math.random()*(page.height-60)+60)});
            temp.generate();
            page.predators.push(temp);
            log('pred_spawn', false, false, false, false);
        }
    }

    function randna(){
        var i;
        var dna = '';
        for(i = 0; i < 49; i++){
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
        // Moose in different languages
        var names = ['Elg', 'Eland', 'Poder', 'Hirvi', 'Elan', 'Elch', 'Elgur', 'Munsu', 'Eilc', 'Alce', 'Alces', 'Briedis', 'Atawhenua', 'Losi', 'Uncal', 'Älg', 'Elciaid'];
        var nameg = [    2,       1,       0,       1,      1,      0,       2,       0,      1,      1,       1,         2,           1,      1,       0,     0,         2]; // Name gender lookup
        var index = Math.floor(Math.random()*names.length);
        return [names[index], nameg[index]];
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
                    log('sundown', false, false, false, false);
                }
                pond.source = '../img/pond_night.png';
                page.night = true;
            }
            else{
                // If state has changed from day to night, log sunrise
                if(timecycler.prevtime !== -1 && (timecycler.prevtime < 18000 || timecycler.prevtime > 66000)){
                    log('sunrise', false, false, false, false);
                }
                pond.source = '../img/pond_day.png';
                page.night = false;
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
    function log(event, name, dna, id, local){
        var texts = [];
        var colorlist = ['brown', 'dark', 'red', 'beige'];

        var namegender = 2; // Default to they/them

        if(id && local){
            namegender = DB.getnamegender(id);
        }

        var hisher;
        var himher;
        var heshe;
        switch(namegender) {
            case 0:
                hisher = "his";
                himher = "him";
                heshe = "he";
                break;
            case 1:
                hisher = "her";
                himher = "her";
                heshe = "she";
                break;
            default:
                hisher = "their";
                himher = "them";
                heshe = "they";
        }

        // Capitalizes first letter
        String.prototype.capitalize = function() {
            return this.charAt(0).toUpperCase() + this.slice(1);
        }


        if(dna !== false){
            var color = colorlist[parseInt(dna.substr(2, 2), 2)];
        }

        if(event === 'spawn'){
            texts = ['A new moose enters the clearing. '+hisher.capitalize()+' '+color+' fur is ruffeled.', 'A young moose walks out of the deep forest surrounding the clearing. You\'ll call '+himher+' '+name+'.', 'A moose emerges from the bushes that surround the glade. '+heshe.capitalize()+'\'s new here.', name+' appears on the glade. Where did '+heshe+' come from?', 'A strange sound comes out of the bushes. It\'s a '+color+' moose. You haven\'t seen '+himher+' here before.'];
        }
        else if(event === 'starving'){
            texts = [name + ' is starving, barely able to keep walking.', name+' is hungering, desperately trying to find food. ', name+' is desperately looking for something edible.', 'You see '+name+' desperately searching for food in the tall grass.', name+' looks skinnier than usual. '+heshe.capitalize()+' looks at you, desperate, hungry.'];
        }
        else if(event === 'birth'){
            texts = ['A new moose is born. '+heshe.capitalize()+' looks cute with '+hisher+' huge dark eyes and '+color+' fur. You\'ll call '+himher+' '+name+'.', name+' is born. '+heshe.capitalize()+' clumsily walks around as '+heshe+' explores '+hisher+' new surroundings.', 'A moose is born. '+heshe.capitalize()+' looks at you with '+hisher+' huge eyes while '+hisher+' parents are watching '+himher+' from a distance.', name+' is born. You can see the reflection of your face in '+hisher+' deep, dark eyes as '+heshe+' looks up to you.'];
        }
        else if(event === 'death'){
            texts = [name + ' collapses on the ground, breathing for one last time.', 'A corpse lies on the ground, nothing but skin and bone. It\'s '+name+'.', name+' looks at you for the last time. '+hisher.capitalize()+' big eyes close, slowly. '+heshe.capitalize()+'\'s dead. You know it.', name+' staggers towards you, '+hisher+' '+color+' fur is tattered. '+heshe.capitalize()+' collapses in front of you. You know '+heshe+' won\'t stand up again.'];
        }
        else if(event === 'pred_spawn'){
            texts = ['A single predator creeps out of the bushes, looking for prey with its bloodshot eyes.', 'A predator bursts out of the deep woods surrounding the clearing.', 'You hear a deep roar as a single predator jumps out of a bush near the woods.'];
        }
        else if(event === 'pred_despawn'){
            texts = ['The predator vanishes in the dark woods surrounding the glade.', 'Slowly, the predator retreats to the edge of the forest and disappears in the dark bushes.', 'Slowly, the predator creeps back into the dark woods that he came from, leaving muddy footprints behind.'];
        }
        else if(event === 'pred_death'){
            texts = ['The predator collapses in the tall grass, gazing at the sky with wide eyes.', 'You see the predator lying on the ground, his lifeless black eyes still opened.'];
        }
        else if(event === 'pred_kill'){
            texts = ['The predator attacks '+name+'. '+heshe.capitalize()+' hasn\'t got a chance.', name+' is lying on the ground, lifeless. '+hisher.capitalize()+' '+color+' fur is stained with dark red blood.', 'The predator jumps on '+name+', digging its long sharp teeth deep into '+hisher+' fur. '+heshe.capitalize()+'\'s dead within a few seconds.'];
        }
        else if(event === 'ambient_day'){
            texts = ['The clearing lies calmly in the light breeze. The tall grass is waving slowly.', 'You can see small clouds slowly drifting away above you.', 'You can see the reflection of the big firs in the calm pond.', 'A single flower stands in the tall grass, nodding slowly in the wind.', 'Small waves ripple through the tall grass as the wind blows softly.', 'A faint swish emerges from the forest in the light breeze.', 'You see the treetops above you slowly dancing in the wind.'];
        }
        else if(event === 'ambient_night'){
            texts = ['The pale moon shines on the glade, wandering across the dark sky.', 'The deep black sky above you seems endless, infinite.', 'The glade looks different in the silver moonshine. Mystical.', 'Small waves form on the pond\'s surface, swirling through the reflected sky.', 'Pale white clouds wander across the sky like scraps of cloth in a dark, endless river.', 'Once the sun has disappeared behind the trees, the forest around you feels strangely alive.', 'The small pond seems to glow slightly in the pale moonlight.'];
        }
        else if(event === 'guest_enter'){
            texts = [name+' visits the glade.', name+' visits the clearing. It\'s nice to see a few new faces around here.', name+' visits the clearing.'];
        }
        else if(event === 'guest_leave'){
            texts = [name+' decides to go back home through the dense forest.', name+' leaves the clearing and heads home.'];
        }
        else if(event === 'sunrise'){
            texts = ['The sun rises slowly above the treetops. A new day begins.', 'A fresh morning breeze blows through the grass as the sun begins to rise.', 'Small dewdrops form in the tall grass as the sun rises above the trees.'];
        }
        else if(event === 'sundown'){
            texts = ['The descending sun paints the sky deep orange. The night is about to begin.', 'The sun is setting. It\'s getting darker around.', 'Slowly, the sun disappears behind a high fir. The night is coming.'];
        }
        else if(event === 'spawnthree'){
            texts = ['Three moose are standing in front of you. They look friendly.', 'You look around. There, near the edge of the glade, you see three moose.', 'In the high grass you can see three moose eating flowers. They look calm.', 'You can see three moose walking around on the clearing, probably searching for food.'];
        }
        else if(event === 'firststart'){
            texts = ['Your story begins on a small clearing in a dark forest.', 'This is where it all starts. A small clearing in the woods.', 'This is the beginning of your story. A small glade in the endless forest.'];
        }

        // Generate info text
        var infotext = '';

        if(event === 'spawn'){
            infotext = name+' appears.';
        }
        else if(event === 'starving'){
            infotext = name+' has < 25% energy.';
        }
        else if(event === 'birth'){
            var parents = DB.ancestors_get(id);
            infotext = name+' is born. Parents: '+parents[0]+' and '+parents[2];
        }
        else if(event === 'death'){
            infotext = name+' dies.';
        }
        else if(event === 'pred_kill'){
            infotext = name+' is killed.'
        }
        else if(event === 'guest_enter'){
            infotext = 'Guest moose '+name+' appears.';
        }
        else if(event === 'guest_leave'){
            infotext = 'Guest moose '+name+' leaves.';
        }

        var mooseid = -1;
        if(id !== false && local !== false){
            mooseid = id;
        }

        // Choose random text & save to log
        var index = Math.floor(Math.random()*texts.length);

        // Avoid logging 2 consecutive ambient messages
        if(!(DB.getsett(15) == 1 && (event === 'ambient_day' || event === 'ambient_night'))){
           DB.log_add(texts[index], infotext, mooseid);
           if(event === 'ambient_day' || event === 'ambient_night'){
               DB.setsett(15, 1);
           }
           else{
               DB.setsett(15, 0);
           }
        }
        updatelogmsg(texts[index]);
    }

    function story(index){
        var storylines = new Array();
        storylines = ['Your head is aching. How long did you lie here before you woke up?', 'Sometimes, when you look at your reflection in the unruffled pond, you try to remember what was before the day you woke up here. You can\'t.', 'You feel alone. Alone in the endless woods. Maybe someone else is out there?', 'You barely sleep. Most nights, you just lie in the tall grass, gazing upon the starry sky above you.', 'How did you get here? Where did you come from? You look at the trees, silently waiting for answers.',
                      'When you lie awake at night, questions start filling your head. Where are you? Why are you here?', 'You realize that the moose are your family now. You see them growing up, getting old and die. It\'s sad.', 'Every time you see a new corpse lying on the ground, you fall apart a little more. You miss them.', 'A single black raven is flying above you, heading north. It\'s the first bird you see here.', 'Sometimes when you dream, you see small, blurred fragments of old memories. You see buildings. A city.',
                      'The days start to blend into each other. How long has it been since you woke up on the glade?', 'Sometimes, mostly at night, you see shadows moving through the dense forest around you.', 'You see more ravens, all heading north, flying across the sky like dark harbingers.', 'You didn\'t dream for a long time now. It feels like the last connection to your old life is fading.', 'Every morning you remember your first day on the clearing. Remember the three moose, their soft fur, their smell.',
                      'The memory of your first day here is the only thing that you have. It makes everything feel real.', 'In some nights, you can feel something in the forest around the glade. The woods feel alive.', 'It happened. You forgot their names. The only memory you had. Destroyed, erased.', 'After the dreams stopped, the nightmares began. You see yourself, running, fleeing, yet not getting anywhere.', 'Every once in a while, you can feel a nameless evil standing right behind you. You spin around. Nothing.',
                      'The huge trees around you look more sinister than before. The entire forest appears to get darker and deeper every day.', 'You can\'t stand this feeling anymore. Always looking around you, just waiting for something to jump on you.', '<endgame>'];

        if(storylines[index] == '<endgame>'){
            // Activate end UI
            enddialogue(); // Load message
            endscreen.visible = true; // Show endscreen
            pause(); // Pause game for duration of end story
            showtimer.start(); // Delay opacity animation (Doesn't work otherwise)
        }
        else if(index < storylines.length){
            // If there is story to tell, log story message
            DB.log_add(storylines[index], '');
            updatelogmsg(storylines[index]);
            if(index === 21){
                storytimer.start();
            }
        }
    }

    // Shows & updates text of log message
    function updatelogmsg(text){
        if(page.showmsgs){
            msgtext.text = text;
            logmsg.visible = true;
            if(page.pauseonmsg){
                pause();
            }
        }
    }

    // Triggers easteregg after specific swipe pattern
    function swipe_eegg(swipe){
        var directions = Array(4, 4, 1, 2, 3);
        if(swipe === directions[swiper.swipeindex]){
            swiper.swipeindex++;
            swiper.start();
        }
        else{
            swiper.swipeindex = 0;
            swiper.stop();
        }

        if(swiper.swipeindex === 5){
            pause();
            pageStack.push(Qt.resolvedUrl('eegg.qml'));
        }
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

    Timer{
        id: spawndelayer
        interval: 2500
        repeat: false
        onTriggered: spawnanimal(true)
    }

    Timer{
        id: swiper
        interval: 10000
        repeat: false
        running: false
        onTriggered: swipeindex = 0
        property int swipeindex: 0
    }

    Rectangle {
        id: rect
        width: parent.width
        height: parent.height
        color: '#84b331'

        MouseArea {
            // based on Swipe recognition by Gianluca from https://forum.qt.io/topic/39641/swipe-gesture-with-qt-quick-2-0-and-qt-5-2/4  - Thanks!
            anchors.fill: parent
            preventStealing: true
            property real xvelocity: 0.0
            property real yvelocity: 0.0
            property int xStart: 0
            property int xPrev: 0
            property int yStart: 0
            property int yPrev: 0
            property bool tracing: false
            onPressed: {
                xStart = mouse.x
                xPrev = mouse.x
                yStart = mouse.y
                yPrev = mouse.y
                xvelocity = 0
                yvelocity = 0
                tracing = true
            }

            onPositionChanged: {
                if (tracing){
                    var xcurrVel = (mouse.x-xPrev);
                    var ycurrVel = (mouse.y-yPrev);

                    xvelocity = (xvelocity + xcurrVel)/2.0;
                    yvelocity = (yvelocity + ycurrVel)/2.0;

                    xPrev = mouse.x;
                    yPrev = mouse.y;

                    if ( xvelocity > 15 && Math.abs(xStart - mouse.x) > parent.width * 0.2) {
                        tracing = false
                        swipe_eegg(1);
                    }
                    else if(xvelocity < -15 && Math.abs(xStart - mouse.x) > parent.width * 0.2){
                        tracing = false
                        swipe_eegg(2);
                    }
                    else if(yvelocity < -15 && Math.abs(yStart - mouse.y) > parent.width * 0.2){
                        tracing = false
                        swipe_eegg(3);
                    }
                    else if(yvelocity > 15 && Math.abs(yStart - mouse.y) > parent.width * 0.2){
                        tracing = false
                        swipe_eegg(4);
                    }
                }
            }

            onReleased: {
                tracing = false
            }
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
           width: parent.width/3
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
           anchors.horizontalCenter: parent.horizontalCenter
           width: parent.width/3
           MouseArea {
              anchors.fill: parent
              onClicked: {
                  // Upper limit to avoid critical lag
                  if(page.animals.length < 31){
                    spawnanimal(true);
                  }
              }
           }
        }

        Label {
           id: debug_bpred
           text: 'Pred'
           horizontalAlignment: Text.AlignHCenter
           font.pixelSize: 42
           font.family: pixels.name
           anchors.verticalCenter: parent.verticalCenter
           anchors.right: parent.right
           width: parent.width/3
           MouseArea {
              anchors.fill: parent
              onClicked: {
                  // Upper limit to avoid critical lag
                  if(page.predators.length < 6){
                    spawnpredator();
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
        z: 90000
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
            lineHeight: 1.1
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
        z: 90000
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
            characterb.text = pers2(a_dna);
            characterc.text = pers3(a_dna);
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
            Label {
                visible: true // Work in progress
                id: characterc
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

        var lazy = movingchange*4 - stillchange*1.2;
        var clever = viewarea*1.8 + searchingduration*1.8;
        var hyperactive = (stillchange*2)+(directionchange*2) - movingchange;

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

    function pers3(dna){ // Social character trait
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

    // Endgame UI & Logic

    function enddialogue(){
        var storylines = new Array();
        storylines = ['Despite any common sense, you run into the deep dark forest surrounding you. You have to get away. Just away.', 'You run through the thick stems in a bizarre zigzag, trying to stay on your feet. Dead branches and leaves cover the forest floor.', 'You feel something behind you, quickly catching up as you stagger deeper and deeper into the woods.', 'You have to see it, just once, just for a second. You need certainty.', 'For a fraction of a second, you turn your head to see behind you. Nothing. A log on the ground. You stumble. You fall.', 'For a moment, you realize that your head is about to hit the ground, then the trees around you form a huge blur as everything fades away.', 'Everything is gone. You hear voices around you, whispering, eternal darkness surrounding you.', 'Slowly, you open your eyes. You look around. You\'re lying on a small glade in a deep forest.', 'You can see a few moose standing in the tall grass in front of you. They look friendly.']
        if(page.endindex < storylines.length){

            // Fade in new text
            endtext.opacity = 1;
            endtext.text = storylines[page.endindex];
            if(page.endindex == 5){
                blackouttimer.start();
            }
            else if(page.endindex == 7){
                appeartimer.start();
            }
            DB.log_add(storylines[page.endindex]);
            page.endindex++;
        }
        else{
            endscreen.color = 'transparent';
            endtext.color = 'transparent';
            hidetimer.start();
        }
    }

    function nextmessage(){
        // Fade out old text
        endtext.opacity = 0;
        textfader.start();
    }

    Rectangle {
        id: endscreen
        width: parent.width
        height: parent.height
        color: rect.color
        opacity: 0
        visible: false
        z: 2000
        Behavior on color {
            ColorAnimation {duration: 1500 }
        }
        Behavior on opacity {
            PropertyAnimation {duration: 1000}
        }

        MouseArea {
            anchors.fill: parent
            onClicked: nextmessage()
        }

        Label {
            id: endtext
            visible: parent.visible
            text: 'Sorry, this shouldn\'t happen.'
            font.pixelSize: 30
            font.family: pixels.name
            z: 2001
            wrapMode: Text.WordWrap
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: Theme.paddingMedium
                rightMargin: Theme.paddingMedium
            }

            Behavior on opacity {
                PropertyAnimation {duration: 750}
            }

        }
    }

    Timer {
        id: blackouttimer
        interval: 3000
        running: false
        repeat: false
        onTriggered: endscreen.color = '#000000'
    }

    Timer {
        id: appeartimer
        interval: 1000
        running: false
        repeat: false
        onTriggered:{
            endscreen.color = rect.color;
        }
    }

    Timer {
        id: hidetimer
        interval: 1500
        running: false
        repeat: false
        onTriggered:{
            endscreen.visible = false;
        }
    }

    Timer {
        id: showtimer
        interval: 100
        running: false
        repeat: false
        onTriggered:{
            endscreen.opacity = 1;
        }
    }

    Timer {
        id: textfader
        interval: 750
        running: false
        repeat: false
        onTriggered:{
            enddialogue();
        }
    }

    Timer {
        id: storytimer
        interval: 4000
        running: false
        repeat: false
        onTriggered:{
            var index = DB.getsett(10);
            story(index);
            DB.setsett(10, index+1);
        }
    }
}
