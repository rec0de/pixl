import QtQuick 2.0
import '../pages/data.js' as DB

// Animal DNA specs
//
// Example DNA:
// 00|11|000|111|000|1111|000|111|0000|111|000|111|0000|111|000000
// so co viw mov stl dirc men ens enmv mis mas jpf sedu sov blank
//
// Socialtrait: 1 of 4 social character traits
// Color: 1 of 4 color variations
// Viewarea: 70 + DNA Value (0-7) * 15
// Movingchange: 1 + DNA Value (0-7)
// Stillchange: 1 + DNA Value (0-7)
// Directionchange: DNA Value (0-15)
// Maxenergy: 4 + DNA Value (0-7)
// Energystill: 0.001 + DNA Value (0-7) / 2000
// Minspeed: 0.5 + DNA Value (0-7) / 2
// Maxspeed: Minspeed + DNA Value (0-7)/1.5
// Energymoving: Energystill * (1 + maxspeed/10) * (1 + DNA Value (0-15)/15)
// Jumpforce: 7 + DNA Value (0-7)
// Searchduration: 300 + DNA Value (0-15)*100
// Socialvalue: DNA Value (0-7), exact usage depends on socialtrait
// Blank space: Not used for now



Image {
    source: "../img/moose.png"
    mirror: false
    id: animal
    opacity: 1
    width: 45
    height: 45
    x: 0
    y: 0
    z: 2
    // Animal Properties

    //In DNA
    property int viewarea: 100 // Radius of the area in wich the animal will find food, ect
    property int movingchange: 2 // Probability of state change from moving to still in %
    property int stillchange: 2 // Probability of state change from still to moving in %
    property int directionchange: 4 // Probability of direction change while moving in %
    property int maxenergy: 5 // Makimum energy the animal can store
    property int jumpforce: 10
    property real energystill: .001 // Energy consumed while still
    property real energymoving: .002 // Energy consumed while moving
    property real maxspeed: 4 // Max Walking speed
    property real minspeed: 1 // Min Walking Speed
    property int searchingduration: 500 // Max. duration of searching state
    property int socialtrait: 0 // Character trait for social interaction 0: helpful 1: egoist  2: todo 3: todo
    property int socialval: 0 // Additional value for social actions, usage depends on socialtrait

    //Not in DNA
    property int yshift: 0
    property int sshift: 0 // Shadow shifting
    property int absy: 0
    property int jumpindex: 0
    property int eatarea: 20 // Radius of the area in wich food can be eaten
    property real energy: maxenergy // Current energy of the animal
    property real speed: minspeed // Walking speed
    property real xspeed: 1 // Speed on x axis
    property real yspeed: 1 // Speed on y axis
    property bool alive: true
    property bool moving: true
    property bool searching: false // Animal is searching for something, higher attention.
    property bool mateable: true // Animal is ready to mate
    property bool still: false // Animal should not move now
    property bool startstill: false // Signal for animal to start stillreset timer
    property bool startmate: false // Signal for animal to start matereset timer
    property bool local: true // Is local animal (required for planned 'multiplayer')
    property bool starvelog: true // Used for logging cooldown
    property bool predkill: false // True if killed by predator
    property int slowdownage: 90 // Animal will be slowed down from this age on (age in user unit, internal units are 400 times larger)
    property int grownupage: 20 // Animal will be considered grown-up from this age on (age in user unit, internal units are 400 times larger)
    property int matecooldown: 60*5*1000 // 5 minutes 'cooldown'
    property int attention: 10 // How often animal looks for predators, lower is better

    // Database related
    property string name: 'Mr. Moose'
    property string dna: ''
    property int age: 0
    property int id

    Image {
        id: shadow
        source: "../img/moose_shadow.png"
        mirror: parent.mirror
        opacity: .5
        width: parent.width
        height: 10
        x: 0
        y: parent.height - 5 + parent.sshift
        z: 0
    }

    Text{
        id: nametext
        visible: false
        x: 50
        text: parent.name + ( parent.local ? '' : ' (g)') + '<br>' + Math.round((parent.energy / parent.maxenergy)*100) + '%' // Display name (add guest indicator if needed) and energy
        color: '#ffffff'
        font.pixelSize: 16
        font.family: pixels.name
    }

    MouseArea {
        anchors.fill: parent
        onClicked: showname()
    }

    function tick(){

        // Increment age
        age++;

        // Adjust size if age < 19 * 400
        if(age < 19*400){
            var factor = Math.sqrt(age/400 + 0.2)*0.08 + 0.65;
            animal.height = Math.round(factor * 45);
            animal.width = Math.round(factor * 45);
        }
        else{
            animal.width = 45;
            animal.height = 45;
        }

        // Check for stillreset signal
        if(startstill){
            startstill = false;
            stillreset.start();
        }

        y = absy - yshift;
        sshift = yshift;

        // Moving state change
        if(Math.random()*100 < stillchange && !moving && !still){ // Dont start moving while still
            moving = ! moving;
            randomdirection();
        }
        else if(Math.random()*100 < movingchange && moving ){
           moving = ! moving;
        }

        // Look for food
        var searchprob = 0.12 * Math.pow(1.068, Math.round((energy / maxenergy)*100)) + 10; // Searching probability, depends on energy
        if((chance(searchprob)|| searching) && Math.round((energy / maxenergy)*100) < 91){ // Look for food aprox. every 20 ticks (if energy is below 91%)
            var dist;

            // Check for food within viewarea
            for (var i = 0; i < page.food.length; i++){
                dist = -1;
                if(page.food[i].active){
                    var dx = x - page.food[i].x
                    var dy = y - page.food[i].y
                    dist = Math.sqrt(dx*dx + dy*dy)
                    if(dist < viewarea){
                        xytodirection(page.food[i].x, page.food[i].y);
                        break;
                    }
                }
            }
            if(dist >= 0 && dist < eatarea){ // Found food & in eating area
                // Stop moving, exit search state and eat food
                moving = false;
                searching = false;
                searcher.stop();
                page.food[i].despawn();

                // Add 1 to animal energy level
                if(energy + 1 <= maxenergy){
                    energy = energy + 1;
                }
                else{
                    energy = maxenergy;
                }
            }
            else if(dist >= 0 && dist < viewarea){ // Found food
                // Start moving in food direction and enter searching state (if not already active)
                moving = true;

                if(!searching){
                   searching = true;
                   searcher.restart();
                }
            }
        }

        // Look for other moose
        if(chance(20)){ // Look for moose aprox. every 20 ticks

            // Check for other moose within viewarea
            for (i = 0; i < page.animals.length; i++){
                dist = -1;
                if(page.animals[i].alive && (page.animals[i].x !== x || page.animals[i].y !== y)){ // Exclude 'own' animal
                    dx = x - (page.animals[i].x + 50)
                    dy = y - page.animals[i].y
                    dist = Math.sqrt(dx*dx + dy*dy)
                    if(dist < viewarea && dist > 0){
                        if(dist < 30){
                            // Stop movement
                            moving = false;
                            page.animals[i].moving = false;

                            // Mate with certain probability based on energy and age if both animals are local, age over 20 , matable and not already mating
                            var multa = 1/(energy / maxenergy);
                            if((age/400) > 81.5 && page.slowdown){
                                multa += Math.log((age/400)-80) * 1.5;
                            }
                            var multb = 1/(page.animals[i].energy / page.animals[i].maxenergy);
                            if((page.animals[i].age/400) > 81.5 && page.slowdown){
                                multb += Math.log((page.animals[i].age/400)-80) * 1.5;
                            }
                            var multiplicator = (multa * multb)*5; // 5 if both animals have 100% and youger than 80, higher if animals are hungry

                            if(!still && !page.animals[i].still && local && page.animals[i].local && age >= grownupage*400 && page.animals[i].age >= grownupage*400 && chance(multiplicator) && DB.getmatetime(id) < page.playtime && DB.getmatetime(page.animals[i].id) < page.playtime){

                                // Align faces
                                if(page.animals[i].x > x){
                                    page.animals[i].mirror = false;
                                    mirror = true;
                                }
                                else{
                                    page.animals[i].mirror = true;
                                    mirror = false;
                                }

                                // Spawn heart particle
                                var heart_comp = Qt.createComponent("../components/heart.qml");
                                var heartx = (x + page.animals[i].x)/2;
                                var hearty = ((y + page.animals[i].y)/2)-5;
                                var temp = heart_comp.createObject(page, {x: heartx, y: hearty});
                                page.hearts.push(temp);

                                // Don't move for 2 seconds
                                page.animals[i].still = true;
                                still = true;
                                stillreset.start();
                                page.animals[i].startstill = true; // Apparently I cannot start the timer from here, so I set a var which gets checked by the other animal in tick()

                                // Spawn new animal
                                createanimal(combinedna(dna, page.animals[i].dna), x + Math.floor(Math.random()*10), y + Math.floor(Math.random()*10), animal.id, page.animals[i].id);

                                // Set matetime for both animals
                                DB.setmatetime(id, page.playtime + 60*5);
                                DB.setmatetime(page.animals[i].id, page.playtime + 60*5);
                            }
                            else if(chance(5)){ // Otherwise interact with 1/5 probability

                                var ownenergy = energy / maxenergy
                                var partnerenergy = page.animals[i].energy / page.animals[i].maxenergy;

                                // Feed young (hungry) moose if not egoist and not hungry
                                if(socialtrait !== 1 && age > 20*400 && page.animals[i].age < 18*400 && partnerenergy < (ownenergy*1.3)){
                                    var giveenergy = 0.3 * ownenergy * ownenergy * energy
                                    page.animals[i].energy = page.animals[i].energy + giveenergy;

                                    if(page.animals[i].energy > page.animals[i].maxenergy){
                                        page.animals[i].energy = page.animals[i].maxenergy; // Avoid higher than 100% energy
                                    }

                                    energy = energy - giveenergy;
                                    console.log('Fed '+giveenergy+' to '+animals[i].name);
                                }
                                // Feed if partner is hungry and animal is helpful with 1/2 chance
                                else if(false && socialtrait === 0 && chance(2) && partnerenergy < ownenergy){ // Deactivated for now, WIP
                                    giveenergy = 0.23 * ownenergy * ownenergy * energy
                                    page.animals[i].energy = page.animals[i].energy + giveenergy;

                                    if(page.animals[i].energy > page.animals[i].maxenergy){
                                        page.animals[i].energy = page.animals[i].maxenergy; // Avoid higher than 100% energy
                                    }

                                    energy = energy - giveenergy;
                                    console.log('Fed '+giveenergy+' to moose.');
                                }
                                // Steal food if egoist with 1/5 chance
                                else if(false && socialtrait === 1 && chance(5) && partnerenergy > ownenergy){ // Deactivated for now, WIP
                                    var takeenergy = 0.1 * partnerenergy * partnerenergy * page.animals[i].energy;
                                    page.animals[i].energy = page.animals[i].energy - giveenergy;
                                    energy = energy + giveenergy;

                                    if(energy > maxenergy){
                                        energy = maxenergy; // Avoid higher than 100% energy
                                    }

                                    console.log('Stole '+giveenergy+' from moose.');
                                }
                            }
                        }
                        else{
                          if(chance(10) || (age < 400 * grownupage && chance(Math.pow(2, Math.round(age/2000)) + 1))){ // Young moose tend to stay near others, formula: chance = 2^(0.2 * (age/400)) + 1
                            xytodirection(page.animals[i].x + 50, page.animals[i].y);
                          }
                        }
                    }
                }
            }


        }

        // Look for predators
        if(page.predators.length > 0 && chance(animal.attention)){
            // Check for other moose within viewarea
            for (i = 0; i < page.predators.length; i++){
                dist = -1;
                if(page.predators[i].alive){
                    dx = x - (page.predators[i].x + 50)
                    dy = y - page.predators[i].y
                    dist = Math.sqrt(dx*dx + dy*dy)
                    if(dist < viewarea){
                        xytodirection(2*dx, 2*dy); // Run in opposite direction
                    }
                }
            }
        }


        // Log message if starving
        if(Math.round((animal.energy / animal.maxenergy)*100) < 25 && starvelog && animal.energy > 0){
            starvelog = false;
            starvelogger.start();
            page.log('starving', animal.name, animal.dna, animal.id, animal.local)
        }

        // Move animal
        if(moving){
            absy = absy + yspeed;
            x = x + xspeed;


            // Keep animal on screen (x axis)
            if(x < 0){
                x = 0;
                randomdirection();
            }
            else if(x > rect.width - 45){
                x = rect.width -45;
                randomdirection();
            }

            // Keep animal on screen (y axis)
            if(absy < 60){ // 60 = menu height
                absy = 60;
                randomdirection();
            }
            else if(absy > rect.height - 45){
                absy = rect.height -45;
                randomdirection();
            }

        }

        // Mirror image depending on direction
        if(xspeed > 0){
            mirror = true;
        }
        else{
            mirror = false;
        }

        // Jumping animation if animal is moving
        if(moving || yshift > 3){
            jumpindex = jumpindex % jumpforce;
            if(jumpindex < (jumpforce / 2)){
                yshift = jumpindex;
            }
            else{
                yshift = jumpforce - jumpindex;
            }
            jumpindex++;
        }
        else{
            yshift = 0;
        }

        // Subtract energy consumed from energy level
        if(moving){
            energy = energy - energymoving;
        }
        else{
            energy = energy - energystill;
        }

        // Die if energy <= 0
        if(energy <= 0){
            die();
        }
    }

    // End tick function

    function chance(probability){
        if(Math.floor(Math.random()*probability) === 0){
            return true;
        }
        else{
            return false;
        }
    }

    function die(){
        source = '../img/tombstone.png';
        shadow.visible = false;
        alive = false;

        // Log death
        if(predkill){
            page.log('pred_kill', animal.name, animal.dna, animal.id, animal.local)
        }
        else{
            page.log('death', animal.name, animal.dna, animal.id, animal.local)
        }
        destroy(8000);
    }

    function importfromdna(dna){
        if(dna.length === 40){
            for(var i = 0; i < 9; i++){
                if(Math.floor(Math.random()*2) === 1){
                    dna += '1';
                }
                else{
                    dna += '0';
                }
            }

            importfromdna(dna)
        }
        else if(dna.length === 49){
            animal.dna = dna;

            var basepath = '../img/moose';

            var color = parseInt(dna.substr(2, 2), 2) + 1;
            source = basepath + color + '.png';
            viewarea = 70 + parseInt(dna.substr(4, 3), 2) * 15;
            movingchange = 1 + parseInt(dna.substr(7, 3), 2);
            stillchange = 1 + parseInt(dna.substr(10, 3), 2);
            directionchange = parseInt(dna.substr(13, 4), 2);
            maxenergy = 4 + parseInt(dna.substr(17, 3), 2);
            energystill = 0.001 + parseInt(dna.substr(20, 3), 2)/2000;
            minspeed = 0.5 + parseInt(dna.substr(27, 3), 2)/2;
            maxspeed = minspeed + parseInt(dna.substr(30, 3), 2)/1.5
            energymoving = energystill * (1 + maxspeed / 10) * (1 + parseInt(dna.substr(24, 4), 2)/15)
            jumpforce = 7 + parseInt(dna.substr(33, 3), 2);
            searchingduration = 300 + parseInt(dna.substr(36, 4), 2)*100;
            socialtrait = parseInt(dna.substr(0, 2), 2);
            socialval = parseInt(dna.substr(40, 3), 2);
        }
        else{
            console.log('DNA import failed. '+dna+' '+dna.length);
        }
    }

    function showname(){
        // Toggle nametag
        nametext.visible = !nametext.visible;
        if(page.paused){
            // Display animal info
            animalstats.a_name = animal.name;
            animalstats.a_dna = animal.dna;
            animalstats.a_age = animal.age;
            animalstats.a_local = animal.local;
            animalstats.a_id = animal.id;
            animalstats.a_energy = Math.round((animal.energy / animal.maxenergy)*100) + '%';
            animalstats.visible = true;
        }
    }

    function xytodirection(ox, oy){
        var dx = x - ox;
        var dy = y - oy;
        var newmspeed;

        // Slow down old animals
        if(page.slowdown && age > 400*slowdownage){
            var agesquared = age*age;
            var constant = 0.94*400*slowdownage;
            var multiplier = (constant*constant)/agesquared;
            newmspeed = maxspeed * multiplier;
        }
        else{
            newmspeed = maxspeed;
        }


        // I am apparently too stupid to solve this with clean math, so...
        while(Math.abs(dx) + Math.abs(dy) > newmspeed){
            dx = dx * 0.7;
            dy = dy * 0.7;
        }
        xspeed = - dx;
        yspeed = - dy;

    }

    function randomdirection(){
        // Change speed
        speed = minspeed + (Math.random()*(maxspeed - minspeed));

        // Slow down old animals
        if(page.slowdown && age > 400*slowdownage){
            var agesquared = age*age;
            var constant = 0.94*400*slowdownage;
            var multiplier = (constant*constant)/agesquared;
            speed = speed * multiplier;
        }

        // Determine absolute value of xspeed and yspeed first
        var absx = (Math.random()*speed);
        var absy = speed - absx;

        // Determine if each value is negative / positive
        if(chance(2)){
            xspeed = - absx;
        }
        else{
            xspeed = absx;
        }
        if(Math.random()*2 < 0.8){ // Adjust probability to avoid animals grouping on top of screen
            yspeed = - absy;
        }
        else{
            yspeed = absy;
        }


        // Avoid running into screen border
        if(animal.x < 10){
            // xspeed has to be positive
            xspeed = Math.abs(xspeed);
        }
        else if(animal.x > page.width - animal.width - 5){
            // xspeed has to be negative
            xspeed = - Math.abs(xspeed);
        }

        if(animal.y < 70){
            // yspeed has to be positive
            yspeed = Math.abs(yspeed);

            // Avoid small yspeeds
            if(yspeed < Math.abs(xspeed)){
                yspeed = Math.abs(xspeed);
                xspeed = speed - yspeed;
                if(chance(2)){ // Choose xspeed direction
                    xspeed = - xspeed;
                }
           }
        }
        else if(animal.y > page.height - animal.height - 5){
            // yspeed has to be negative
            yspeed = - Math.abs(yspeed);
        }
    }

    function combinedna(dna1, dna2){
        var crossoverpoint = Math.floor(Math.random()*49);
        var part1;
        var part2;

        // Crossover
        if(chance(2)){
          part1 = dna1.substr(crossoverpoint);
          part2 = dna2.substr(0, crossoverpoint);
        }
        else{
          part1 = dna2.substr(crossoverpoint);
          part2 = dna1.substr(0, crossoverpoint);
        }

        var rawdna = part1 + part2;

        // Mutation
        var dna = mutate(rawdna);
        return dna;
    }

    function mutate(dna){
        for(var i = 0; i < dna.length; i++){
           if(chance(100)){
               if(dna[i] === '1'){
                   dna = dna.substr(0, i) + '0' + dna.substr(i+1);
               }
               else{
                   dna = dna.substr(0, i) + '1' + dna.substr(i+1);
               }
           }
        }
        return dna;
    }

    Timer {
        id: searcher
        interval: searchingduration
        running: false
        repeat: false
        onTriggered: parent.searching = false;
    }

    Timer {
        id: stillreset
        interval: 2000
        running: false
        repeat: false
        onTriggered: parent.still = false;
    }

    Timer {
        id: matereset
        interval: matecooldown
        running: false
        repeat: false
        onTriggered: parent.still = false;
    }

    Timer {
        id: starvelogger
        interval: 4*60*1000
        running: false
        repeat: false
        onTriggered: parent.starvelog = true;
    }

}
