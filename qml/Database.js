.pragma library
.import QtQuick.LocalStorage 2.0 as LS


function open() {
  try {
    var db = LS.LocalStorage.openDatabaseSync("gym-logbook", "", "Gym Logbook database", 1000000);

    if (db.version === "") {
      db.changeVersion("", "4",
        function(tx) {
          tx.executeSql("CREATE TABLE IF NOT EXISTS exercises(id INTEGER UNIQUE, name TEXT, additional TEXT, type TEXT, dbname TEXT);");
          tx.executeSql("CREATE TABLE IF NOT EXISTS workouts(id INTEGER UNIQUE, name TEXT, additional TEXT, dbname TEXT);");
        }
      );
    }
  } catch (e) {
    console.log("Could not open DB: " + e);
  }
  return db;
}

// TODO: Remove this function and the need for it before release
function updateDB() {
    try {
        var db = LS.LocalStorage.openDatabaseSync("gym-logbook", "", "Gym Logbook database", 1000000);

        if (db.version === "1") {
            db.changeVersion("1", "2",
                function(tx) {
                    tx.executeSql("ALTER TABLE excercises RENAME TO exercises;");
                    tx.executeSql("ALTER TABLE exercises ADD COLUMN dbname TEXT;");

                    var res = tx.executeSql("SELECT * from exercises WHERE dbname IS NULL;");
                    for ( var i = 0; i < res.rows.length; i++ ) {
                        var r = res.rows.item(i);
                        var dbname = "e_" + r.name.toLowerCase().replace(/[^a-z-]/g,"") + "_" + r.id;
                        tx.executeSql("UPDATE exercises SET dbname = '" + dbname + "' WHERE id = " + r.id + ";");
                        tx.executeSql("ALTER TABLE " + r.name + r.id + " RENAME TO " + dbname + ";");
                    }
                }
            );
        }
        if (db.version === "2") {
            db.changeVersion("2", "3",
                function(tx){
                    tx.executeSql("CREATE TABLE IF NOT EXISTS workouts(id INTEGER UNIQUE, name TEXT, additional TEXT, dbname TEXT);");
                }
            );
        }
        if (db.version === "3") {
            db.changeVersion("3", "4",
                function(tx) {
                    var res = tx.executeSql("SELECT * from exercises;");
                    for ( var i = 0; i < res.rows.length; i++ ) {
                        var r = res.rows.item(i);
                        tx.executeSql("UPDATE exercises SET dbname = 'e_" + r.dbname + "' WHERE dbname = '" + r.dbname + "';");
                        tx.executeSql("ALTER TABLE " + r.dbname + " RENAME TO e_" + r.dbname + ";");
                    }
                    res = tx.executeSql("SELECT * from workouts;");
                    for ( var i = 0; i < res.rows.length; i++ ) {
                        var r = res.rows.item(i);
                        tx.executeSql("UPDATE workouts SET dbname = 'w_" + r.dbname + "' WHERE dbname = '" + r.dbname + "';");
                        tx.executeSql("ALTER TABLE " + r.dbname + " RENAME TO w_" + r.dbname + ";");
                    }
                }
            );
        }
    }
    catch(e) {
        console.log("Failure in updating database: " + e);

    }
}

function newWorkout(name, info, days) {
    return withDB(
        function(tx) {
            try {
                var result = tx.executeSql("SELECT max(id) FROM workouts;");
                //print(result.rows.item(0)["max(id)"]);
                var maxId = result.rows.item(0)["max(id)"];

            }
            catch(e) {
                var maxId = 0;
            }
            var newId = maxId + 1;
            var dbname = "w_" + name.toLowerCase().replace(/[^a-z-]/g,"") + "_" + newId;
            tx.executeSql("CREATE TABLE IF NOT EXISTS " + dbname +
                          "(id INTEGER UNIQUE, day TEXT, exercise INTEGER);");
            tx.executeSql("INSERT INTO workouts VALUES(?, ?, ?, ?);", [newId, name, info, dbname]);

            for (var i = 0; i < parseInt(days); i++ ) {
                tx.executeSql("INSERT INTO " + dbname + " VALUES( " + i +", 'Day " + (i+1) + "', null);");
            }

            return dbname;
        }
    );
}

function getWorkoutDays(table, workouts) {
    withDB(
        function(tx) {
            var res = tx.executeSql("SELECT * FROM " + table + " WHERE exercise IS NULL ORDER BY id;");
            for ( var i = 0; i < res.rows.length; i++ ) {
                var r = res.rows.item(i);
                workouts.append({"day": r.day, "id": r.id});
            }
        }
    );
}

function getWorkoutContent(table, workouts) {
    withDB(
        function(tx) {
            var res = tx.executeSql("SELECT * FROM " + table + " WHERE exercise IS NOT NULL ORDER BY id;");
            for ( var i = 0; i < res.rows.length; i++ ) {
                var r = res.rows.item(i);
                workouts.append({"day": r.day, "id": r.id, "exercise":r.exercise});
            }
        }
    );
}

function getWorkoutlist(workouts) {
    withDB(
        function(tx) {
            var res = tx.executeSql("SELECT * FROM workouts ORDER BY id;");
            for ( var i = 0; i < res.rows.length; i++ ) {
                var r = res.rows.item(i);
                workouts.append({"id":r.id, "name":r.name, "info":r.additional, "dbname":r.dbname});
            }
        }
    );
}

function deleteWorkout(id) {
    withDB(
        function(tx) {
            tx.executeSql("DELETE FROM workouts WHERE id = ?;", [id]);
        }
    )
}

function newExercise(name, additional, type, tablename) {
    // Function assumes it's already checked there's no exercise under the same name
    withDB(
        function(tx) {

            try {
                var result = tx.executeSql("SELECT max(id) FROM exercises;");
                //print(result.rows.item(0)["max(id)"]);
                var newId = result.rows.item(0)["max(id)"];

            }
            catch(e) {
                var newId = 0;
            }
            var newId = newId + 1;
            var dbname = "e_" + name.toLowerCase().replace(/[^a-z-]/g,"") + "_" + newId;
            tx.executeSql("CREATE TABLE IF NOT EXISTS " + dbname +
                          "(id INTEGER UNIQUE, year INTEGER, month INTEGER, day INTEGER, " +
                          "sets INTEGER, reps INTEGER, seconds REAL, weight REAL, status INTEGER);");
            tx.executeSql("INSERT INTO exercises VALUES(?, ?, ?, ?, ?);", [newId, name, additional, type, dbname]);
        }
    );
}

function newSet(table, year, month, day, sets, reps, weight, seconds, status) {
    withDB(
        function(tx) {
            try {
                var result = tx.executeSql("SELECT max(id) FROM " + table + ";");
                var maxId = result.rows.item(0)["max(id)"];

            }
            catch(e) {
                var maxId = 0;
            }
            var newId = maxId + 1;
            tx.executeSql("INSERT INTO "+ table + " VALUES(" + newId + ", " + year + ", " + month + ", " + day +
                          ", " + sets + ", " + reps + ", " + seconds + ", '" + weight.replace(",", ".") + "', '" + status + "');");
        }
    )

}

function updateSet(id, table, year, month, day, sets, reps, weight, seconds, status) {
    withDB(
        function(tx) {
            tx.executeSql("UPDATE "+ table + " SET year=" + year + ", month=" + month + ", day=" + day +
                          ", sets=" + sets + ", reps=" + reps + ", seconds=" + seconds + ", weight='" + weight.replace(",", ".") +
                          "', status='" + status + "' WHERE id=" + id +";");
        }
    )
}

function hasExercise(name) {
     withDB(
         function(tx) {
             return tx.executeSql("SELECT * from exercises where name = ?;", [name]);
         }
     )
}

function getExercises(list) {
    withDB(
        function(tx) {
            var res = tx.executeSql("select * from exercises order by id;");
            for ( var i = 0; i < res.rows.length; i++ ) {
                var r = res.rows.item(i);
                list.append({"id": r.id, "name": r.name, "info": r.additional, "dbname": r.dbname});
            }
        }
    )
}

function getExerciseInfo(name, id, info){
    withDB(
        function(tx) {
            var res = tx.executeSql("SELECT additional FROM exercises where id = ?;",[id]);
            info = res.rows.item(0).additional;
        }
    )
}

function getExercise(list, tablename) {
    withDB(
        function(tx) {
            var res = tx.executeSql("SELECT * FROM " + tablename + " ORDER BY year DESC, month DESC, day DESC;");
            for ( var i = 0; i < res.rows.length; i++ ) {
                var r = res.rows.item(i);
                //print(r.weight)
                list.append({"id": r.id, "year": r.year, "month": r.month, "day": r.day, "sets": r.sets, "reps":r.reps,
                             "seconds":r.seconds, "weight":parseFloat(r.weight), "status":r.status});
            }

        }
    )
}

function getSet(table, id) {
    return withDB(
        function(tx) {
            var res = tx.executeSql("SELECT * FROM " + table + " WHERE id = " + id + ";");
            return [res.rows.item(0).year, res.rows.item(0).month, res.rows.item(0).day, res.rows.item(0).sets,
                    res.rows.item(0).reps, res.rows.item(0).seconds, res.rows.item(0).weight, res.rows.item(0).status];
        }
    )
}

function changeStatus(table, id, status) {
    withDB(
        function(tx) {
            try {
                tx.executeSql("UPDATE " + table + " SET status = '" + status + "' WHERE id = " + id + ";");
            }
            catch(e) {
                console.log(e);
            }
        }

    )
}

function addworkout(days) {

    var id = days.count + 1;
    if (isNaN(id)) {
        id = 1;
    }
    console.log(id);
    days.append({"id": id, "day": "Day " + id, "exercise": null});

}


function clear() {
    print("Doesn't do nuthin'.")
}

function withDB(cb) {
    var db = open();
    var res;
    try {
        db.transaction(function(tx) {
            res = cb(tx);
        } );
    } catch (e) {
        console.log("database transaction failed: " + e);
    }

    return res;
}
