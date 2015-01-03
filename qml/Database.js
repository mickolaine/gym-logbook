.pragma library
.import QtQuick.LocalStorage 2.0 as LS


function open() {
  try {
    var db = LS.LocalStorage.openDatabaseSync("gym-logbook", "", "Gym Logbook database", 1000000);

    if (db.version === "") {
      db.changeVersion("", "1",
        function(tx) {
          // date is measured in days since epoch
          tx.executeSql("CREATE TABLE IF NOT EXISTS excercises(id INTEGER UNIQUE, name TEXT, additional TEXT, type TEXT);");
        }
      );
    }
  } catch (e) {
    console.log("Could not open DB: " + e);
  }
  return db;
}

function newExcercise(name, additional, type) {
    // Function assumes it's already checked there's no excercise under the same name
    withDB(
        function(tx) {

            try {
                var result = tx.executeSql("SELECT max(id) FROM excercises;");
                //print(result.rows.item(0)["max(id)"]);
                var newId = result.rows.item(0)["max(id)"];

            }
            catch(e) {
                var newId = 0;
            }
            var newId = newId + 1;
            //print(newId);
            var tablename = name + newId;
            tx.executeSql("CREATE TABLE IF NOT EXISTS " + tablename +
                          "(id INTEGER UNIQUE, year INTEGER, month INTEGER, day INTEGER, " +
                          "sets INTEGER, reps INTEGER, seconds REAL, weight REAL, status INTEGER);");
            tx.executeSql("INSERT INTO excercises VALUES(?, ?, ?, ?);", [newId, name, additional, type]);
        }
    )
}

function newSet(table, year, month, day, sets, reps, weight, seconds, status) {
    withDB(
        function(tx) {
            try {
                var result = tx.executeSql("SELECT max(id) FROM " + table + ";");
                print(result.rows.item(0)["max(id)"]);
                var maxId = result.rows.item(0)["max(id)"];

            }
            catch(e) {
                var maxId = 0;
            }
            var newId = maxId + 1;

            tx.executeSql("INSERT INTO "+ table + " VALUES(" + newId + ", " + year + ", " + month + ", " + day +
                          ", " + sets + ", " + reps + ", " + seconds + ", " + weight + ", '" + status + "');");
        }

    )

}

function hasExcercise(name) {
     withDB(
         function(tx) {
             return tx.executeSql("SELECT * from excercises where name = ?;", [name]);
         }
     )
}

function getExcercises(list) {
    withDB(
        function(tx) {
            var res = tx.executeSql("select * from excercises reverse order by id;");
            for ( var i = 0; i < res.rows.length; i++ ) {
                var r = res.rows.item(i);
                list.append({"id": r.id, "name": r.name, "info": r.additional});
            }
        }
    )
}

function getExcerciseInfo(name, id, info){
    withDB(
        function(tx) {
            var res = tx.executeSql("SELECT additional FROM excercises where id = ?;",[id]);
            info = res.rows.item(0).additional;
        }
    )
}

function getExcercise(list, name, id) {
    withDB(
        function(tx) {
            var res = tx.executeSql("SELECT * FROM " + name + id + ";");
            for ( var i = 0; i < res.rows.length; i++ ) {
                var r = res.rows.item(i);
                print(r.weight)
                list.append({"id": r.id, "year": r.date, "month": r.month, "day": r.day, "sets": r.sets, "reps":r.reps,
                             "seconds":r.seconds, "weight":r.weight, "status":r.status});
            }

        }

    )
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
