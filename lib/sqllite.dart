import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'route.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class RouteDB {
  static Database? _database;

  Future<Database> get database async {
    print(_database);
    if (_database != null) return _database!;
    _database = await initDB();
    test();
    return _database!;
  }

  Future<void> dropTable(String tableName) async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS $tableName').catchError((error) {
      throw Exception('Failed to drop $tableName: $error');
    });
  }

  initDB() async {
    String path = join(await getDatabasesPath(), 'asf.db');
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute("""CREATE TABLE IF NOT EXISTS Route(
           Id TEXT NOT NULL,
           Title TEXT NOT NULL, 
           Description TEXT,
           GPX TEXT NOT NULL,
           Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
           Saved INTEGER NOT NULL DEFAULT 0,
           PRIMARY KEY (Id)
        )""");
    });
  }

  Future<void> test() async {
    print("Before 1");
    await createRoute(
      title: "Test Route 1",
      description: "This is a test route",
      gpxData: "<gpx><trk><name>Test Track</name></trk></gpx>",
    );
    print("After 1");

    await createRoute(
      title: "Test Route 2",
      description: "Another test route",
      gpxData: "<gpx><trk><name>Another Test Track</name></trk></gpx>",
      saved: true,
    );
    print("After 2");

    renameRoute("Test Route 1", "Renamed Test Route");

    var savedRoutes = await getRoutes(true);
    print("Saved Routes:");
    for (var route in savedRoutes) {
      print("${route.title}: ${route.gpx}");
    }

    var unsavedRoutes = await getRoutes(false);
    print("Unsaved Routes:");
    for (var route in unsavedRoutes) {
      print("${route.title}: ${route.gpx}");
    }

    await deleteRoute(title: "Renamed Test Route", saved: false);

    var remainingRoutes = await getRoutes(false);
    print("Remaining Unsaved Routes:");
    for (var route in remainingRoutes) {
      print("${route.title}: ${route.gpx}");
    }
  }

  Future<void> renameRoute(String currName, String newName) async {
    final db = await database;
    await db.update("Route", {"Title": newName},
        where: "Title = ?", whereArgs: [currName]);
  }

  Future<List<Route>> getRoutes(bool saved) async {
    final db = await database;
    List<Route> routes = [];
    List<Map<String, Object?>> queriedRoutes = await db.query(
      "Route",
      where: "Saved = ?",
      whereArgs: [saved ? 1 : 0],
      orderBy: 'Date DESC, ROWID ASC',
    );

    for (var route in queriedRoutes) {
      var id = route["Id"] as String;
      var title = route["Title"] as String;
      var desc = route["Description"] as String;

      var gpxFilePath = route["GPX"] as String;
      var gpx = await File(gpxFilePath).readAsString();

      var date = route["Date"] as String;
      routes.add(Route(
        id: id,
        title: title,
        description: desc,
        gpx: gpx,
        date: date,
      ));
    }
    return routes;
  }

  Future<void> deleteRoute({required String title, required bool saved}) async {
    final db = await database;

    List<Map<String, Object?>> result = await db.query(
      "Route",
      columns: ["GPX"],
      where: "Title = ? AND Saved = ?",
      whereArgs: [title, saved ? 1 : 0],
    );

    if (result.isNotEmpty) {
      var gpxFilePath = result.first["GPX"] as String;
      File(gpxFilePath).deleteSync();
    }

    await db.delete("Route",
        where: "Title = ? AND Saved = ?", whereArgs: [title, saved ? 1 : 0]);
  }

  Future<void> createRoute({
    required String title,
    required String description,
    required String gpxData,
    bool saved = false,
  }) async {
    print("gte4hr");
    final db = await database;
    print("rege");

    String fileName = "${DateTime.now().millisecondsSinceEpoch}.gpx";
    print(fileName); // Check if fileName is generated

    var status = await Permission.storage.request();
    print("Permission status: $status"); // Check permission status
    if (!status.isGranted) {
      print("Permission not granted");
      return;
    }

    Directory? baseDir;
    if (Platform.isAndroid) {
      baseDir = await getExternalStorageDirectory(); // Android
      print(
          "External storage directory: ${baseDir?.path}"); // Log directory path
    } else if (Platform.isIOS) {
      baseDir = await getApplicationDocumentsDirectory(); // iOS
    }

    if (baseDir == null) {
      print("Base directory not found");
      return;
    }

    String filePath = join(baseDir.path, fileName);
    print("File path: $filePath"); // Log file path

    File gpxFile = File(filePath);
    await gpxFile.writeAsString(gpxData);

    print("File written: ${gpxFile.readAsStringSync()}"); // Verify file content

    await db.insert("Route", {
      "Id": fileName,
      "Title": title,
      "Description": description,
      "GPX": filePath,
      "Saved": saved ? 1 : 0
    });

    print("inserted");
  }
}
