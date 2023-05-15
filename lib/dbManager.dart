import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'photo.dart';

class dbManager {
  static Database? _db;
  static const String ID = 'id';
  static const String PHOTO_NAME = 'photo_name';
  static const String TABLE = 'PhotosTable';
  static const String DB_NAME = 'photos.db';

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }
  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY, $PHOTO_NAME TEXT)");
  }

  //insert
  Future<Photo> save(Photo photo) async {
    var dbClient = await db;
    photo.id = await dbClient.insert(TABLE, photo.toMap());
    return photo;
  }
  //select
  Future<List<Photo>> getPhotos() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE, columns: [ID, PHOTO_NAME], where: '$ID = ?', whereArgs: [1]);
    List<Photo> photos = [];

    if (maps.isNotEmpty) {
      for (int i = 0; i < maps.length; i++) {
        photos.add(Photo.fromMap(maps[i] as Map<String, dynamic>));
      }
    }
    return photos;
  }
  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
