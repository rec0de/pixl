
.import QtQuick.LocalStorage 2.0 as LS

// Code derived from 'Noto' by leszek -- Thanks :)

// Structure of settings table
// 0   Night Mode (Default 2) {0: day 1: night 2: cycle}
// 1   Debug Mode (Default off)
// 2   Age Slowdown (Default on)
// 3   Food spawn rate (Deafult: 85)
// 4   First upload? (Default: true)
// 5   Version (Default: 0) Used to trigger one-time update code
// 6   Next Id (Default: 0)
// 7   Next Id for nonlocal (Default: 0)
// 8   Next ID for log
// 9   Playtime in seconds

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
                    tx.executeSql('CREATE TABLE IF NOT EXISTS ancestors (dna TEXT, name TEXT, parenta INTEGER, parentb INTEGER, id INTEGER UNIQUE)');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS log (id INTEGER UNIQUE, val TEXT)');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS namegender (id INTEGER UNIQUE, val INTEGER)');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS matetime (id INTEGER UNIQUE, val INTEGER)');
                });
}

// Regenerate database to include id column
function updateid() {
    var db = getDatabase();
    db.transaction(
                function(tx) {
                    tx.executeSql('DROP TABLE animals');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS animals (dna TEXT, name TEXT, age INTEGER, id INTEGER UNIQUE)');
                    tx.executeSql('DROP TABLE nonlocal');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS nonlocal (dna TEXT, name TEXT, age INTEGER, id INTEGER UNIQUE)');
                });
    console.log('Updated DB');
}

// Get animals from old DB
function oldall() {
    var db = getDatabase();
    var res;
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT dna, name, age FROM animals');
        if (rs.rows.length > 0) {
            res = rs.rows;
        } else {
            res = false;
        }
    })
    return res
}

function oldnonlocal() {
    var db = getDatabase();
    var res;
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT dna, name, age FROM nonlocal');
        if (rs.rows.length > 0) {
            res = rs.rows;
        } else {
            res = false;
        }
    })
    return res
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
            console.log ("Error saving to animal database");
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
            console.log ("Error saving to nonlocal database");
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
        var rs = tx.executeSql('SELECT name FROM animals WHERE id=?;', [id]);
        if (rs.rows.length > 0) {
            res = rs.rows.item(0).name;
        } else {
            res = '-1';
        }
    })
    return res
}

// This function is used to retrieve animal ages from the database
function getage(id) {
    var db = getDatabase();
    var res = '';
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT age FROM animals WHERE id=?;', [id]);
        if (rs.rows.length > 0) {
            res = rs.rows.item(0).age;
        } else {
            res = false;
        }
    })
    return res
}

// This function is used to retrieve name gender from the database
// 0 = male; 1 = female
function getnamegender(id) {
    var db = getDatabase();
    var res = '';
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT val FROM namegender WHERE id=?;', [id]);
        if (rs.rows.length > 0) {
            res = rs.rows.item(0).val;
            if(res != 1){
                res = 0;
            }
        } else {
            res = 0;
        }
    })
    return res
}

function setnamegender(uid, value) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO namegender VALUES (?,?);', [uid,value]);
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

// This function is used to retrieve mate time from the database
function getmatetime(id) {
    var db = getDatabase();
    var res = '';
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT val FROM matetime WHERE id=?;', [id]);
        if (rs.rows.length > 0) {
            res = rs.rows.item(0).val;
        } else {
            res = 0;
        }
    })
    return res
}

function setmatetime(uid, value) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO matetime VALUES (?,?);', [uid,value]);
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
            res = -1;
            //console.log ("Error reading settings from DB");
        }
    })
    return res;
}

// This adds animal data to the permanent ancestors log
function ancestors_add(dna, name, id, parenta, parentb) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO ancestors VALUES (?,?,?,?,?);', [dna,name,parenta,parentb,id]);
        if (rs.rowsAffected > 0) {
            res = "OK";
        } else {
            res = "Error";
            console.log ("Error saving to ancestors database");
        }
    }
    );
    return res;
}

// This changes the name of an animal in the DB
function ancestors_rename(id, newname) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('UPDATE ancestors SET name = ? WHERE id = ?', [newname, id]);
        if (rs.rowsAffected > 0) {
            res = "OK";
        } else {
            res = "Error";
            console.log ("Error updating ancestors database");
        }
    }
    );
    return res;
}

// Returns animals name and dna
function ancestors_getdata(id) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT name, dna, id FROM ancestors WHERE id = ?', [id]);
        if (rs.rowsAffected > 0) {
            res = rs.rows.item(0);
        } else {
            res = false;
            console.log ("Error reading from ancestors database");
        }
    }
    );
    return res;
}

// Returns an animals parents dna & names (unfinished)
function ancestors_get(id) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT parenta, parentb FROM ancestors WHERE id = ?', [id]);
        if (rs.rowsAffected > 0) {
            res = rs.rows.item(0);
        } else {
            res = false;
            console.log ("Error reading from ancestors database");
        }
    }
    );
    if(res.parenta === -1 || res.parentb === -1){
        var parents = new Array('None', '0', 'None', '0', '0', '0');
    }
    else{
        var parenta = ancestors_getdata(res.parenta);
        var parentb = ancestors_getdata(res.parentb);
        var parents = new Array(parenta.name, parenta.dna, parentb.name, parentb.dna, parenta.id, parentb.id);
    }


    return parents;
}

// Adds data to event log
function log_add(text){
    var db = getDatabase();
    var res = "";
    var id = getsett(8) + 1;
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT INTO log VALUES (?,?);', [id, text]);
        if (rs.rowsAffected > 0) {
            res = "OK";
        } else {
            res = "Error";
            console.log ("Error saving to log");
        }
    }
    );
    setsett(8, id);
    return res;
}

// Returns complete event log
function log_get(){
    var db = getDatabase();
    var res;
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT val FROM log');
        if (rs.rows.length > 0) {
            res = rs.rows;
        } else {
            res = false;
        }
    })
    return res
}

// Clears log table
function log_clear(){
    var db = getDatabase();
    var res;
    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM log');
        if (rs.rows.length > 0) {
            res = rs.rows;
        } else {
            res = false;
        }
    })
    return res
}

// This function resets the game
function clearnonlocal(){
    var db = getDatabase();
    db.transaction(function(tx) {
        tx.executeSql('DROP TABLE nonlocal;');
        tx.executeSql('CREATE TABLE IF NOT EXISTS nonlocal (dna TEXT, name TEXT, age INTEGER, id INTEGER UNIQUE)');
    })
}

// This function resets the game
function hardreset(){
    var db = getDatabase();
    db.transaction(function(tx) {
        tx.executeSql('DROP TABLE animals;');
        tx.executeSql('DROP TABLE settings;');
        tx.executeSql('DROP TABLE nonlocal;');
        tx.executeSql('DROP TABLE namegender;');
        tx.executeSql('DROP TABLE log;');
    })
}


