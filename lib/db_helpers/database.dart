import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/kategori_inspeksi.dart';
import '../models/personil_inspeksi.dart';
import '../models/surat_tugas.dart';
import '../models/user.dart';

class DatabaseHelper {
  factory DatabaseHelper() => _instance;

  DatabaseHelper._();

  static Database? _db;
  static final DatabaseHelper _instance = DatabaseHelper._();

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'inspector.db');
    return _db = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE user (
          id INTEGER PRIMARY KEY,
          id_user INTEGER,
          name TEXT,
          email TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE surat_tugas (
          id INTEGER PRIMARY KEY,
          id_surat_tugas INTEGER,
          no_surat VARCHAR(255),
          tgl_inspeksi TEXT,
          status INTEGER,
          userId INTEGER,
          jenis_pengawasan_id INTEGER,
          nama_perusahaan VARCHAR(255),
          komoditas_perusahaan VARCHAR(255)
        )
      ''');

      await db.execute('''
        CREATE TABLE personil_inspeksi (
          id INTEGER PRIMARY KEY,
          id_personil INTEGER,
          st_inspeksi_id INTEGER,
          nama_personil VARCHAR(255),
          status INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE kategori_inspeksi (
          id INTEGER PRIMARY KEY,
          id_kategori INTEGER,
          nama_kategori VARCHAR(255),
          inspeksi_jenis INTEGER,
          kategori_jenis VARCHAR(255),
          status INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE kategori_soal_inspeksi (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_kategori INTEGER,
          id_soal_kategori INTEGER,
          nama_kategori VARCHAR(255),
          surat_tugas_id INTEGER
        )
      ''');

    await db.execute('''
        CREATE TABLE inspeksi_kategori (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_kategori INTEGER,
          kategori_id INTEGER,
          nama_kategori VARCHAR(255),
          surat_tugas_id INTEGER
        )
      ''');
    await db.execute('''
        CREATE TABLE inspeksi_area (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_area INTEGER,
          kategori_inspeksi_id INTEGER,
          nama_area VARCHAR(255)
        )
      ''');

    await db.execute('''
        CREATE TABLE subkategori_inspeksi (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_subkategori INTEGER,
          area_id INTEGER,
          nama_subkategori VARCHAR(255)
        )
      ''');

      await db.execute('''
        CREATE TABLE inspeksi_pertanyaan (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_inspeksi_pertanyaan INTEGER,
          id_pertanyaan INTEGER,
          subkategori_inspeksi_id INTEGER,
          jawaban INTEGER,
          aman INTEGER,
          ramah_lingkungan INTEGER,
          catatan TEXT,
          personil_inspeksi INTEGER,
          review TEXT,
          rekomendasi TEXT,
          pertanyaan TEXT,
          video TEXT,
          foto BLOB
        )
      ''');

      await db.execute('''
        CREATE TABLE foto_inspeksi (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_foto_inspeksi INTEGER,
          nama_file TEXT,
          longitude TEXT,
          latitude TEXT,
          id_inspeksi_pertanyaan INTEGER
        )
      ''');

    

    await db.execute('''
        CREATE TABLE area_inspeksi (
          id INTEGER PRIMARY KEY,
          id_area INTEGER,
          kategori_id INTEGER,
          id_soal_kategori INTEGER,
          nama_area VARCHAR(255),
          surat_tugas_id INTEGER,
          is_saved BOOLEAN
        )
      ''');



      await db.execute('''
        CREATE TABLE subcategory_inspeksi (
          id INTEGER PRIMARY KEY,
          id_subkategori_inspeksi INTEGER,
          area_id INTEGER,
          subkategori_id INTEGER,
          kategori_id INTEGER,
          surat_tugas_id INTEGER,
          nama_subkategori TEXT,
          status INTEGER,
          inspeksi_jenis INTEGER,
          kode_edupak INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE rekomendasi (
          id INTEGER PRIMARY KEY,
          id_rekomendasi INTEGER,
          inspeksi_pertanyaan_id INTEGER,
          tindak_lanjut TEXT,
          penanggung_jawab STRING,
          due_date STRING,
          prioritas INTEGER,
          status_tindakan INTEGER,
          catatan_tindakan TEXT,
          file BLOB,
          rekomendasi TEXT,
          review INTEGER,
          keterangan_review TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE pertanyaan_inspeksi (
          id INTEGER PRIMARY KEY,
          id_pertanyaan INTEGER,
          area_id INTEGER,
          subkategori_inspeksi_id INTEGER,
          personil_inspeksi INTEGER,
          jawaban INTEGER Comment '0 = belum dijawab, 1 = ya, 2 = tidak',
          aman INTEGER Comment '0 = belum dijawab, 1 = ya, 2 = tidak',
          ramah_lingkungan INTEGER Comment '0 = belum dijawab, 1 = ya, 2 = tidak',
          catatan TEXT,
          review TEXT,
          pertanyaan_id INTEGER,
          pertanyaan TEXT,
          rekomendasi TEXT,
          foto BLOB
        )
      ''');
    });
  }

  Future<Database> _getDb() async {
    // if (_db == null) {
    //   _db = await initDatabase();
    // }
    _db ??= await initDatabase();
    return _db!;
  }

  Future<int> saveUser(User user) async {
    final dbClient = await _getDb();
    return await dbClient.insert('user', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('user', where: 'email = ?', whereArgs: [email]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('user', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateUser(User modelUser) async {
    final dbClient = await _getDb();
    return await dbClient.update('user', modelUser.toMap(), where: 'id = ?', whereArgs: [modelUser.id]);
  }

  Future<List<User>> getAllUsers() async {
    final dbClient = await _getDb();
    final result = await dbClient.query('user');
    return result.map((user) => User.fromMap(user)).toList();
  }

  Future<void> deleteUserById(int id) async {
    final dbClient = await _getDb();
    await dbClient.delete('user', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllUsers() async {
    final dbClient = await _getDb();
    await dbClient.delete('user');
  }

  Future<int> saveSuratTugas(SuratTugas suratTugas) async {
    final dbClient = await _getDb();
    return await dbClient.insert('surat_tugas', suratTugas.toMap());
  }

  Future<SuratTugas?> getSuratTugasById(int id) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('surat_tugas', where: 'id_surat_tugas = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return SuratTugas.fromMap(result.first);
    }
    return null;
  }

  Future<void> updateSuratTugas(int id, int status) async {
    final dbClient = await _getDb();
    await dbClient.update('surat_tugas', {'status': status}, where: 'id_surat_tugas = ?', whereArgs: [id]);
  }

  Future<int> updateSuratTugasInspeksi(SuratTugas suratTugas) async {
    final dbClient = await _getDb();
    return await dbClient.update('surat_tugas', suratTugas.toMap(), where: 'id = ?', whereArgs: [suratTugas.id]);
  }

  Future<void> deleteSuratTugasById(int id) async {
    final dbClient = await _getDb();
    await dbClient.delete('surat_tugas', where: 'id_surat_tugas = ?', whereArgs: [id]);
  }

  Future<void> deleteAllSuratTugas() async {
    final dbClient = await _getDb();
    await dbClient.delete('surat_tugas');
  }

  Future<List<SuratTugas>> getAllSuratTugas() async {
    final dbClient = await _getDb();
    final result = await dbClient.query('surat_tugas');
    return result.map((suratTugas) => SuratTugas.fromMap(suratTugas)).toList(); 
  }

  Future<int> savePersonilInspeksi(PersonilInspeksi personilInspeksi) async {
    final dbClient = await _getDb();
    return await dbClient.insert('personil_inspeksi', personilInspeksi.toMap());
  }

  Future<int> updatePersonilInspeksi(PersonilInspeksi personilInspeksi) async {
    final dbClient = await _getDb();
    return await dbClient.update('personil_inspeksi', personilInspeksi.toMap(), where: 'id = ?', whereArgs: [personilInspeksi.id]);
  }

  Future<PersonilInspeksi?> getAllPersonilInspeksiById(int id) async {
    final dbClient = await _getDb();
    final result =
        await dbClient.query('personil_inspeksi', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return PersonilInspeksi.fromMap(result.first);
    }
    return null;
  }

  Future<PersonilInspeksi?> findPersonilInspeksiByStIdAndName(int stId, String name) async {
    final dbClient = await _getDb();
    final result =
        await dbClient.query('personil_inspeksi', where: 'st_inspeksi_id = ? AND nama_personil = ?', whereArgs: [stId, name]);
    if (result.isNotEmpty) {
      return PersonilInspeksi.fromMap(result.first);
    }
    return null;
  }

  Future<List<PersonilInspeksi>> getAllPersonilInspeksiByStId(int stId) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('personil_inspeksi', where: 'st_inspeksi_id = ?', whereArgs: [stId]);
    return result.map((personilInspeksi) => PersonilInspeksi.fromMap(personilInspeksi)).toList();
  }

  Future<void> deleteAllPersonilInspeksi() async {
    final dbClient = await _getDb();
    await dbClient.delete('personil_inspeksi');
  } 

  Future<int> saveKategoriInspeksi(KategoriInspeksi kategoriInspeksi) async {
    final dbClient = await _getDb();
    return await dbClient.insert('kategori_inspeksi', kategoriInspeksi.toMap());
  }

  Future<KategoriInspeksi?> getKategoriInspeksiById(int id) async {
    final dbClient = await _getDb();
    final result =
        await dbClient.query('kategori_inspeksi', where: 'id_kategori = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return KategoriInspeksi.fromMap(result.first);
    }
    return null;
  }

  Future<void> deleteKategoriInspeksiById(int id) async {
    final dbClient = await _getDb();
    await dbClient.delete('kategori_inspeksi', where: 'id_kategori = ?', whereArgs: [id]);
  }

  Future<void> deleteAllKategoriInspeksi() async {
    final dbClient = await _getDb();
    await dbClient.delete('kategori_inspeksi');
  }

   Future<int> updateKategoriInspeksi(KategoriInspeksi kategoriInspeksi) async {
    final dbClient = await _getDb();
    return await dbClient.update('kategori_inspeksi', kategoriInspeksi.toMap(), where: 'id = ?', whereArgs: [kategoriInspeksi.id]);
   }

}