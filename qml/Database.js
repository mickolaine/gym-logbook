.pragma library
.import QtQuick.LocalStorage 2.0 as LS

function open() {
    try {
        var db = LS.LocalStorage.openDatabaseSync("gym-logbook", "", "Gym Logbook database", 1000000);

        if (db.version === "") {
            db.changeVersion("", "5",
                function(tx) {
                    tx.executeSql("CREATE TABLE IF NOT EXISTS exercisenames(id INTEGER UNIQUE, name TEXT, additional TEXT, type TEXT, popularity INTEGER, priority INTEGER);");
                    tx.executeSql("CREATE TABLE IF NOT EXISTS exercisedata(id INTEGER UNIQUE, exercise_id INTEGER, date DATE, sets INTEGER, reps INTEGER, seconds REAL, weight REAL, status INTEGER);");
                    tx.executeSql("CREATE TABLE IF NOT EXISTS workouts(id INTEGER UNIQUE, name TEXT, additional TEXT, dbname TEXT);");
                }
            );
        }
    } catch(e) {
        console.log("Could not open DB: " + e);
    }
    return db;
}

function open_4() {
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
        if (db.version === "4") {
            db.changeVersion("4", "5",
                function(tx) {
                    try {
                        tx.executeSql("CREATE TABLE IF NOT EXISTS exercisenames(id INTEGER UNIQUE, name TEXT, additional TEXT, type TEXT, popularity INTEGER, priority INTEGER);");
                        tx.executeSql("CREATE TABLE IF NOT EXISTS exercisedata(id INTEGER UNIQUE, exercise_id INTEGER, date DATE, sets INTEGER, reps INTEGER, seconds REAL, weight REAL, status INTEGER);");
                    }
                    catch(e) {print(e);}

                    try {
                        var result = tx.executeSql("SELECT max(id) FROM exercisenames;");
                        var newEID = result.rows.item(0)["max(id)"] + 1;
                    }
                    catch(e) {

                        var newEID = 0;
                    }
                    print(newEID);
                    try {
                        var result = tx.executeSql("SELECT max(priority) FROM exercisenames;");
                        var priority = result.rows.item(0)["max(priority)"] + 1;
                    }
                    catch(e) {
                        var priority = 0;
                    }

                    var res = tx.executeSql("SELECT * from exercises;");
                    print(JSON.stringify(res));

                    for ( var i = 0; i < res.rows.length; i++ ) {
                        var r = res.rows.item(i);
                        print(JSON.stringify(r));
                        try {
                            print(newEID + ", " + r.name + ", " + r.additional + "," + r.type + ", " + priority);
                            tx.executeSql("INSERT INTO exercisenames VALUES(?,?,?,?,?,?);", [newEID, r.name, r.additional, r.type, 0, priority]);

                        }
                        catch(e) { print(e);}
                        try {
                        result = tx.executeSql("SELECT * from " + r.dbname + ";");
                        }
                        catch(e) { print(e);}

                        try {
                            var sres = tx.executeSql("SELECT max(id) FROM exercisedata;");
                            print(JSON.stringify(sres));
                            var newSID = sres.rows.item(0)["max(id)"] + 1;
                        }
                        catch(e) { var newSID = 0; }

                        for ( var j = 0; j < result.rows.length; j++ ) {

                            var re = result.rows.item(j);
                            var date = new Date(re.year, re.month-1, re.day, 0, 0, 0);
                            print(newSID + ", " + newEID + ", " + date + ", " + re.sets + ", " + re.reps + ", " + re.seconds + ", " + re.weight + ", " + re.status);
                            tx.executeSql("INSERT INTO exercisedata VALUES(?,?,?,?,?,?,?,?);", [newSID, newEID, date, re.sets, re.reps, re.seconds, re.weight, re.status]);

                            newSID = newSID + 1;
                        }
                        newEID = newEID + 1;
                    }
                }
            );
        }
    }
    catch(e) {
        //console.log("Failure in updating database: " + e);

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

            var id = 0;
            for (var i = 0; i < days.count; i++) {
                //console.log("INSERT INTO " + dbname + " VALUES(" + days.get(i).id + ", " + days.get(i).day + ", null);");
                tx.executeSql("INSERT INTO " + dbname + " VALUES(" + days.get(i).id + ", '" + days.get(i).day + "', null);");
                id++;
            }

            return dbname;
        }
    );
}

function addExercise(table, day, exercise) {
    withDB(
        function(tx) {
            try {
                var res = tx.executeSql("SELECT max(id) FROM " + table + ";");
                var maxId = res.rows.item(0)["max(id)"];
            }
            catch(e) {
                // Shouldn't end in here. At least one entry should be in table
                var maxId = 0;
            }

            var newId = maxId + 1;
            //console.log("New Id is " + newId);
            tx.executeSql("INSERT INTO " + table + " VALUES(?, ?, ?);", [newId, day, exercise]);
        }
    );
}

function removeExercise(table, wid) {
    withDB(
        function(tx) {
            tx.executeSql("DELETE FROM " + table + " WHERE id = " + wid + ";");
        }
    );
}

function deleteExercise(id) {
    return withDB(
        function(tx) {
            try {
                var res = tx.executeSql("SELECT * from exercises WHERE id = " + id + ";");
                var table = res.rows.item(0).dbname;

                tx.executeSql("DELETE FROM exercises WHERE id = " + id + ";");
                tx.executeSql("DROP TABLE " + table + ";");
                return true;
            }
            catch(e) {return false}
        }

    );
}

function moveExercise(table, wid, day, up){
    withDB(
        function(tx) {
            var res = tx.executeSql("SELECT " + table + ".id as wid, " +
                                                table + ".day as day," +
                                            "exercises.id as eid, " +
                                            "exercises.name as name, " +
                                            "exercises.additional as info " +
                                 "FROM " + table + " LEFT JOIN exercises " +
                                 "WHERE " +
                                     table + ".exercise = exercises.id AND " +
                                     table + ".day = '" + day + "' AND " +
                                     "exercise IS NOT NULL " +
                                 "ORDER BY " + table + ".id;");

            var i = 1;
            while ( i < res.rows.length) {
                if (wid === res.rows.item(i).wid) {
                    var newid;
                    if (up) {
                        newid = res.rows.item(i-1).wid;
                    }
                    else {
                        newid = res.rows.item(i+1).wid;
                    }

                    tx.executeSql("UPDATE " + table + " SET id = 99999 WHERE id = " + wid + ";");
                    tx.executeSql("UPDATE " + table + " SET id = " + wid + " WHERE id = " + newid + ";");
                    tx.executeSql("UPDATE " + table + " SET id = " + newid + " WHERE id = 99999;");
                }
                i++;
            }
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
                //console.log("Got: " + r.day + ", " + r.id);
            }
        }
    );
}

function getWorkoutRoutine(table, routine) {
    withDB(
        function(tx) {
            // Long query is long...
            var res = tx.executeSql("SELECT " + table + ".id as wid, " +
                                                table + ".day as day," +
                                               "exercises.id as eid, " +
                                               "exercises.name as name, " +
                                               "exercises.additional as info, " +
                                                "exercises.dbname as exercisetable " +
                                    "FROM " + table + " LEFT JOIN exercises " +
                                    "WHERE " +
                                        table + ".exercise = exercises.id " + // AND " +
                                        //"exercise IS NOT NULL " +
                                    "ORDER BY " + table + ".day, " + table + ".id;");
            for ( var i = 0; i < res.rows.length; i++ ) {
                var r = res.rows.item(i);
                routine.append({"wid": r.wid, "day": r.day, "eid": r.eid, "exercise": r.name, "info": r.info, "exercisetable": r.exercisetable});
                //console.log("Got: " + r.wid + ", " + r.day + ", " + r.eid + " and " + r.name);
            }
        }
    );
}

function getWorkoutContent(table, day, exercises) {
    withDB(
        function(tx) {
            // Long query is long...
            var res = tx.executeSql("SELECT " + table + ".id as wid, " +
                                                table + ".day as day," +
                                               "exercises.id as eid, " +
                                               "exercises.name as name, " +
                                               "exercises.additional as info, " +
                                               "exercises.dbname as exercisetable " +
                                    "FROM " + table + " LEFT JOIN exercises " +
                                    "WHERE " +
                                        table + ".exercise = exercises.id AND " +
                                        table + ".day = '" + day + "' AND " +
                                        "exercise IS NOT NULL " +
                                    "ORDER BY " + table + ".id;");
            for ( var i = 0; i < res.rows.length; i++ ) {
                var r = res.rows.item(i);
                exercises.append({"wid": r.wid, "day": r.day, "eid": r.eid, "exercise": r.name, "info": r.info, "exercisetable": r.exercisetable});
                //console.log("Got: " + r.wid + ", " + r.day + ", " + r.eid + " and " + r.name);
            }
        }
    );
}

function getWorkoutInfo(dbname) {
    return withDB(
        function(tx){
            var res = tx.executeSql("SELECT * from workouts WHERE dbname = '" + dbname + "';");
            return [res.rows.item(0).name, res.rows.item(0).additional];
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

function updateExercise(name, additional, type, eid) {
    // If tablename is set, this updates the table in question. Otherwise creates a new one.
    withDB(
        function(tx) {
            if (eid) {
                tx.executeSql("UPDATE exercisenames SET name = '" + name +
                                                    "', additional = '" + additional +
                                                    "', type = '" + type +
                                             "' WHERE id = '" + eid + "';");
                return;
            }

            try {
                var result = tx.executeSql("SELECT max(id) FROM exercisenames;");
                //print(result.rows.item(0)["max(id)"]);
                var newId = result.rows.item(0)["max(id)"];
            }
            catch(e) {
                var newId = 0;
            }
            try {
                var result = tx.executeSql("SELECT max(priority) FROM exercisenames;");
                var priority = result.rows.item(0)["max(priority)"] + 1;
            }
            catch(e) {
                var priority = 0;
            }

            var newId = newId + 1;
            try {
                tx.executeSql("INSERT INTO exercisenames VALUES(?, ?, ?, ?, ?, ?);", [newId, name, additional, type, 0, priority]);
            }
            catch(e) {
                console.log(e);
            }
        }
    );
}


function updateExercise_old(name, additional, type, tablename) {
    // If tablename is set, this updates the table in question. Otherwise creates a new one.
    withDB(
        function(tx) {
            if (tablename) {
                tx.executeSql("UPDATE exercises SET name = '" + name +
                                                "', additional = '" + additional +
                                                "', type = '" + type +
                              "' WHERE dbname = '" + tablename + "';");
                return;
            }

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

// Version 5
function newSet(eid, date, sets, reps, weight, seconds, status) {
    withDB(
        function(tx) {
            try {
                var result = tx.executeSql("SELECT max(id) FROM exercisedata;");
                var maxId = result.rows.item(0)["max(id)"];

            }
            catch(e) {
                var maxId = 0;
            }

            try {
                var result = tx.executeSql("SELECT max(popularity) FROM exercisedata;");
                var popularity = result.rows.item(0)["max(popularity)"] + 1;
            }
            catch(e) {
                var popularity = 1;
            }

            var newId = maxId + 1;
            try {
                tx.executeSql("INSERT INTO exercisedata VALUES(" + newId + ", " + eid + ", '" + date + "', " + sets + ", " + reps + ", '"
                                                 + seconds.replace(",", ".") + "', '" + weight.replace(",", ".") + "', '" + status + "');");
                tx.executeSql("UPDATE exercisenames SET popularity = " + popularity + " WHERE id = " + eid + ";");
            }
            catch(e) {
                console.log(e);
            }
        }
    )

}

// Version 4
function newSet_old(table, year, month, day, sets, reps, weight, seconds, status) {
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
            try {

                tx.executeSql("INSERT INTO "+ table + " VALUES(" + newId + ", " + year + ", " + month + ", " + day +
                          ", " + sets + ", " + reps + ", '" + seconds.replace(",", ".") + "', '" + weight.replace(",", ".") + "', '" + status + "');");
            }
            catch(e) {
                console.log(e);
            }
        }
    )

}

// Version 5
function updateSet(sid, date, sets, reps, weight, seconds, status) {
    withDB(
        function(tx) {
            tx.executeSql("UPDATE exercisedata SET date=" + date + ", sets=" + sets + ", reps=" + reps +
                          ", seconds='" + seconds.replace(",", ".") + "', weight='" + weight.replace(",", ".") + "', status='" + status + "' WHERE sid=" + sid +";");
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

function getExercises(list, order) {
    withDB(
        function(tx) {
            var res = tx.executeSql("select * from exercisenames order by " + order + " DESC;");
            for ( var i = 0; i < res.rows.length; i++ ) {
                var r = res.rows.item(i);
                list.append({"id": r.id, "name": r.name, "info": r.additional, "popularity": r.popularity, "priority": r.priority});
            }
        }
    )
}

function getExerciseByEID(eid) {
    return withDB(
        function(tx) {
            var res = tx.executeSql("SELECT id, name, additional, type, popularity, priority FROM exercisenames where id =?;",[eid]);
            return res.rows.item(0);
        }
    )
}

function getExerciseByTable(table){
    return withDB(
        function(tx) {
            var res = tx.executeSql("SELECT name, additional, type FROM exercises where dbname = ?;",[table]);
            return [res.rows.item(0).name, res.rows.item(0).additional, res.rows.item(0).type];
        }
    )
}

// Version 5
function getExerciseData(list, eid, future) {
    withDB(
        function(tx) {

            if (!future){
                var myDate = new Date();
                var year = myDate.getFullYear();
                var month = myDate.getMonth();
                var day = myDate.getDate();
            }

            var res;
            if (future) {
                res = tx.executeSql("SELECT N.id as eid, D.id as sid, date, sets, reps, seconds, weight, status FROM exercisedata AS D JOIN exercisenames AS N WHERE D.exercise_id = N.id AND exercise_id = " + eid + " ORDER BY date DESC;");
            }
            else {
                res = tx.executeSql("SELECT * FROM exercisedata " +
                                    " WHERE year < " + year +
                                      " or (year == " + year + " and month < " + (month + 1) + ")" +
                                      " or (year == " + year + " and month ==" + (month + 1) + " and day <= " + day + ")" +
                                      " ORDER BY year DESC, month DESC, day DESC, id DESC;");
            }

            for ( var i = 0; i < res.rows.length; i++ ) {

                var r = res.rows.item(i);
                //print(JSON.stringify(r));

                list.append({"id":r.sid, "eid":r.eid, "date": r.date, "sets":r.sets, "reps":r.reps, "seconds":parseFloat(r.seconds), "weight":parseFloat(r.weight), "status":r.status});

            }

        }
    )
}


function getExercise(list, tablename, future) {
    withDB(
        function(tx) {

            if (!future){
                var myDate = new Date();
                var year = myDate.getFullYear();
                var month = myDate.getMonth();
                var day = myDate.getDate();
            }

            var weight;
            if (getExerciseType(tablename) === "Weight") {
                weight = true;
            }
            else {
                weight = false;
            }

            var res;
            if (future) {
                res = tx.executeSql("SELECT * FROM " + tablename + " ORDER BY year DESC, month DESC, day DESC, id DESC;");
            }
            else {
                res = tx.executeSql("SELECT * FROM " + tablename +
                                    " WHERE year < " + year +
                                      " or (year == " + year + " and month < " + (month + 1) + ")" +
                                      " or (year == " + year + " and month ==" + (month + 1) + " and day <= " + day + ")" +
                                      " ORDER BY year DESC, month DESC, day DESC, id DESC;");
            }

            for ( var i = 0; i < res.rows.length; i++ ) {
                var r = res.rows.item(i);

                if (weight) {
                    list.append({"id": r.id, "year": r.year, "month": r.month, "day": r.day, "sets": r.sets, "reps":r.reps,
                                 "seconds":parseFloat(r.seconds), "weight":parseFloat(r.weight), "status":r.status, "data":r.weight});
                }
                else {
                    list.append({"id": r.id, "year": r.year, "month": r.month, "day": r.day, "sets": r.sets, "reps":r.reps,
                                 "seconds":parseFloat(r.seconds), "weight":parseFloat(r.weight), "status":r.status, "data":r.seconds});
                }
            }

        }
    )
}

function getSetData(sid) {
    return withDB(
        function(tx) {
            var res = tx.executeSql("SELECT * FROM exercisedata WHERE id = " + sid + ";");
            return res.rows.item(0);
        }
    );
}

function getSet(sid) {
    return withDB(
        function(tx) {
            var res = tx.executeSql("SELECT * FROM exercisedata WHERE id = " + sid + ";");
            return [res.rows.item(0).date, res.rows.item(0).sets, res.rows.item(0).reps, res.rows.item(0).seconds, res.rows.item(0).weight, res.rows.item(0).status];
        }
    );
}

function deleteSet(table, id) {
    withDB(
        function(tx) {
            tx.executeSql("DELETE FROM " + table + " WHERE id = " + id + ";");
        }
    );
}

// Version 5
function get1RMSet(eid, alltime) {
    return withDB(
        function(tx) {
            var rm = 0;
            var rmnew = 0;

            var res = tx.executeSql("SELECT * FROM exercisedata WHERE exercise_id = " + eid + " AND status = 'Done' ORDER BY date DESC;");

            for ( var i = 0; i < res.rows.length; i++ ) {
                var r = res.rows.item(i);
                rmnew = r.weight * (36/(37-r.reps));

                if (rmnew > rm) {
                    rm = rmnew;
                }
            }
            return rm.toFixed(1);
        }
    );
}

// Version 4
function get1RMSet_old(table, alltime) {
    return withDB(
        function(tx) {
            var rm = 0;
            var rmnew = 0;
            var month;
            var year;
            var res = tx.executeSql("SELECT * FROM " + table + " WHERE status = 'Done' ORDER BY year DESC, month DESC, day DESC;");

            for ( var i = 0; i < res.rows.length; i++ ) {
                var r = res.rows.item(i);
                //console.log(parseFloat(r.weight));
                //console.log(parseFloat(r.reps));

                if (i === 0) {
                    month = r.month;
                    year = r.year;
                }

                if ((month < r.month) | (year < r.year)){
                    if (!alltime) {
                        break;
                    }
                }

                rmnew = r.weight * (36/(37-r.reps));
                //rmnew = parseFloat(r.weight) * (1.0 + parseFloat(r.reps)/30.0);
                //console.log(rmnew);
                if (rmnew > rm) {
                    rm = rmnew;
                }

            }
            return rm.toFixed(1);
        }

    );
}

function getExerciseType(eid) {
    return withDB(
        function(tx) {
            var res = tx.executeSql("SELECT type FROM exercisenames where id = ?;", [eid]);
            return res.rows.item(0).type;
        }
    )
}

function getExerciseType_old(dbname) {
    return withDB(
        function(tx) {
            var res = tx.executeSql("SELECT type FROM exercises where dbname = ?;", [dbname]);
            return res.rows.item(0).type;
        }
    )
}

function changeStatus(sid, status) {
    withDB(
        function(tx) {
            try {
                tx.executeSql("UPDATE exercisedata SET status = '" + status + "' WHERE id = " + sid + ";");
            }
            catch(e) {
                //console.log(e);
            }
        }

    )
}

function addDay(days) {

    var id = days.count;
    if (isNaN(id)) {
        id = 0;
    }

    days.set(id, {"id": id + 1, "day": "Day " + (id + 1), "exercise": null});
}

function isLast(days, id) {

    var max = days.count;
    if ((parseInt(id + 1) === max) | (days.count === 1)){
        return true;
    }
    else {
        return false;
    }
}

function removeDay(days, id) {
    //console.log(id);
    //console.log(days.count);
    days.remove(parseInt(id));
    //console.log("move " + (parseInt(id) + 1) + ", to " + parseInt(id) + " with range " + (days.count - parseInt(id)));
    days.move(parseInt(id)+1, parseInt(id), days.count - parseInt(id));
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
        //console.log("database transaction failed: " + e);
    }

    return res;
}
