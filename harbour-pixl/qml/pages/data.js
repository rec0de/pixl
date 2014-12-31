
.import QtQuick.LocalStorage 2.0 as LS

// Code derived from 'Noto' by leszek -- Thanks :)

// Structure of settings table
// 0   Night Mode (Default off)
// 1   Debug Mode (Default off)
// 2   Age Slowdown (Default on)
// 3   Food spawn rate (Deafult: 85)
// 4   First upload? (Default: true)
// 5   Version (Default: 0) Used to trigger one-time update code
// 6   Next Id (Default: 0)
// 7   Next Id for nonlocal (Default: 0)

// First, let's create a short helper function to get the database connection
function getDatabase() {
    return LS.LocalStorage.openDatabaseSync("Pixl", "1.0", "StorageDatabase", 10000);
}


// At the start of the application, we can initialize the tables we need if they haven't been created yet
function initialize() {
    var db = getDatabase();
    db.transaction(
                function(tx) {
                    tx.executeSql('CREATE TABLE IF NOT EXISTS animals (dna TEXT, name TEXT, age INTEGER, id INTEGER UNIQUE)');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS settings (uid INTEGER UNIQUE, value INTEGER)');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS nonlocal (dna TEXT, name TEXT, age INTEGER, id INTEGER UNIQUE)');
                });
}

// Update database to include id column
function updateid() {
    var db = getDatabase();
    db.transaction(
                function(tx) {
                    tx.executeSql('ALTER TABLE animals ADD id INTEGER UNIQUE');
                    tx.executeSql('ALTER TABLE nonlocal ADD id INTEGER UNIQUE');
                });
}

// Add ID  to old DB rows
function addid(dna, id) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql("UPDATE animals SET id = '"+id+"' WHERE dna = '"+dna+"'");
        if (rs.rowsAffected > 0) {
            res = "OK";
        } else {
            res = "Error";
            console.log ("Error saving to database");
        }
    }
    );
    return res;
}


// This function is used to add or update animals
function addset(dna, name, age, id) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO animals VALUES (?,?,?,?);', [dna,name,age,id]);
        if (rs.rowsAffected > 0) {
            res = "OK";
        } else {
            res = "Error";
            console.log ("Error saving to database");
        }
    }
    );
    return res;
}

function addnonlocal(dna, name, age, id) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO nonlocal VALUES (?,?,?,?);', [dna,name,age,id]);
        if (rs.rowsAffected > 0) {
            res = "OK";
        } else {
            res = "Error";
            console.log ("Error saving to database");
        }
    }
    );
    return res;
}


// This function is used to retrieve animal names from the database
function getname(id) {
    var db = getDatabase();
    var res = '';
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT name, age FROM animals WHERE id=?;', [id]);
        if (rs.rows.length > 0) {
            res = rs.rows.item(0).name;
        } else {
            res = '-1';
        }
    })
    return res
}

// This function is used to retrieve all animal datasets from the database
function getall() {
    var db = getDatabase();
    var res;
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT id, dna, name, age FROM animals');
        if (rs.rows.length > 0) {
            //console.log('Loading ' + rs.rows.length + 'animals from db');
            res = rs.rows;
        } else {
            res = false;
        }
    })
    return res
}

function getnonlocal() {
    var db = getDatabase();
    var res;
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT id, dna, name, age FROM nonlocal');
        if (rs.rows.length > 0) {
            //console.log('Loading ' + rs.rows.length + 'animals from db');
            res = rs.rows;
        } else {
            res = false;
        }
    })
    return res
}

// Checks if a guest moose is still in DB
function checknonlocal(id) {
    var db = getDatabase();
    var res;
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT name FROM nonlocal WHERE id=?', [id]);
        if (rs.rows.length > 0) {
            res = true; // Moose is still there
        } else {
            res = false; // Moose has been sent home
        }
    })
    return res
}


// This function is used to remove dead animals
function deleterow(id){
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM animals WHERE id=?;', [id]);
    })
}

function delnonlocal(id){
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM nonlocal WHERE id=?;', [id]);
    })
}

// This function is used to update settings
function setsett(uid, value) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [uid,value]);
        if (rs.rowsAffected > 0) {
            res = "OK";
        } else {
            res = "Error";
            console.log ("Error saving to database");
        }
    }
    );
    return res;
}


// This function is used to retrieve settings
function getsett(uid) {
    var db = getDatabase();
    var res="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT value FROM settings WHERE uid=?;', [uid]);
        if (rs.rows.length > 0) {
            res = rs.rows.item(0).value
        } else {
            res = "-1";
            //console.log ("Error reading settings from DB");
        }
    })
    return res;
}

// This function resets the game
function hardreset(){
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql('DROP TABLE animals;');
        rs = tx.executeSql('DROP TABLE settings;');
        rs = tx.executeSql('DROP TABLE nonlocal;');
    })
}


