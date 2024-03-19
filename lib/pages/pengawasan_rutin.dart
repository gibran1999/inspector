// ignore_for_file: use_build_context_synchronously, avoid_function_literals_in_foreach_calls
import 'dart:convert';

import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:inspector/components/info_message.dart';
import 'package:inspector/env.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/error_message.dart';
import '../components/loadingoverlay.dart';
import '../db_helpers/database.dart';
import '../models/kategori_inspeksi.dart';
import '../models/personil_inspeksi.dart';
import '../models/surat_tugas.dart';
import 'detail_pengawasan_rutin.dart';

class PengawasanRutin extends StatefulWidget {
  const PengawasanRutin({super.key});

  @override
  State<PengawasanRutin> createState() => _PengawasanRutinState();
}

class _PengawasanRutinState extends State<PengawasanRutin> {
  late SharedPreferences _prefs;

  final DatabaseHelper db = DatabaseHelper();
  List<SuratTugas> _suratTugasList = [];
  final TextEditingController _searchController = TextEditingController();
  List<SuratTugas> _searchResult = [];

  bool _isLoading = false;
  bool _isDone = false;
  String status = '';

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkConnection() async {
    ConnectivityResult connectivityResult;

    connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      await _getLocalData();

      setState(() {
        _isLoading = false;
        status = 'Offline';
      });

      InfoMessage().showMessage(context, 'Koneksi Internet Terputus',
          'Silahkan aktifkan kembali untuk melakukkan sinkronisasi data');
    } else {
      setState(() {
        status = 'Online';
      });

      await _getSingkronisasiData();
    }
  }

  Future<void> _getSingkronisasiData() async {
    CustomLoadingProgress.start(context);

    setState(() {
      _isLoading = true;
    });

    await db.deleteAllSuratTugas();

    try {
      int? userId = _prefs.getInt('id');
      String? token = _prefs.getString('token');
      Map<String, String> headers = {"Authorization": "Bearer $token"};

      final response = await http.post(
          Uri.parse('${ENV.GetSuratTugas}?id_user=$userId'),
          headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body)['data'];

        responseData.forEach((dataItem) {
          List<dynamic> suratTugas = dataItem['surat_tugas'];
          suratTugas.forEach((suratTugasItem) async {

            SuratTugas suratTugas = SuratTugas(
              id_surat_tugas: suratTugasItem['id'],
              no_surat: suratTugasItem['no_surat'],
              tgl_inspeksi: suratTugasItem['tgl_inspeksi'],
              status: suratTugasItem['status'],
              userId: dataItem['id_user'],
              jenis_pengawasan_id: suratTugasItem['jenis_pengawasan'],
              nama_perusahaan: suratTugasItem['detail_perusahaan']
                  ['nama_perusahaan'],
              komoditas_perusahaan: suratTugasItem['detail_perusahaan']
                  ['komoditas_perusahaan'],
            );

            await db
                .getSuratTugasById(suratTugasItem['id'])
                .then((result) async {
              if (result == null) {
                await db.saveSuratTugas(suratTugas);

                setState(() {
                  _suratTugasList.add(suratTugas);
                });
              } else {
                SuratTugas suratTugasUpdate = SuratTugas(
                  id: result.id,
                  id_surat_tugas: suratTugasItem['id'],
                  no_surat: suratTugasItem['no_surat'],
                  tgl_inspeksi: suratTugasItem['tgl_inspeksi'],
                  status: suratTugasItem['status'],
                  userId: dataItem['id_user'],
                  jenis_pengawasan_id: suratTugasItem['jenis_pengawasan'],
                  nama_perusahaan: suratTugasItem['detail_perusahaan']
                      ['nama_perusahaan'],
                  komoditas_perusahaan: suratTugasItem['detail_perusahaan']
                      ['komoditas_perusahaan'],
                );

                await db.updateSuratTugasInspeksi(suratTugasUpdate);

                setState(() {
                  _suratTugasList.add(suratTugasUpdate);
                });
              }
            });

            await _getDataPersonilInspeksi(suratTugasItem['id'].toString());

            await _getDataKategoriInspeksi(
                suratTugasItem['kategori_jenis'].toString(),
                suratTugasItem['inspeksi_jenis'].toString());
          });
        });

        setState(() {
          _isLoading = false;
        });

        CustomLoadingProgress.stop();
      } else {
        setState(() {
          _isLoading = false;
        });

        CustomLoadingProgress.stop();

        ErrorMessage().showMessage(context, 'Terjadi Kesalahan', response.body);
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      CustomLoadingProgress.stop();

      ErrorMessage().showMessage(context, 'Terjadi Kesalahan', e.toString());

      return;
    }
  }

  Future<void> _getDataPersonilInspeksi(String idSuratTugas) async {

    await db.deleteAllPersonilInspeksi();

    String? token = _prefs.getString('token');
    String? name = _prefs.getString('name');
    String? email = _prefs.getString('email');
    Map<String, String> headers = {"Authorization": "Bearer $token"};

    final responsePersonilInspeksi =
        await http.post(Uri.parse(ENV.DetailSuratTugas),
            body: {
              'id_surat_tugas': idSuratTugas,
            },
            headers: headers);

    if (responsePersonilInspeksi.statusCode == 200) { 
      final responseDataPersonilInspeksi = jsonDecode(responsePersonilInspeksi.body)['data'];

      List<dynamic> personils = responseDataPersonilInspeksi['personil'];

        for (var personil in personils) {
            PersonilInspeksi personilInspeksi = PersonilInspeksi(
              id_personil: personil['id'],
              st_inspeksi_id: personil['st_inspeksi_id'],
              nama_personil: personil['detail_user']['name'],
              status: personil['status'],
            );

            if (personil['detail_user']['name'] == name && personil['detail_user']['email'] == email) {
              if (responseDataPersonilInspeksi['status'] == 2) {
                _isDone = true;
              } else {
                _isDone = false;
              }
            } else {
              _isDone = false;
            }

            await db.findPersonilInspeksiByStIdAndName(personil['st_inspeksi_id'], personil['detail_user']['name']).then((value) async {
              if (value == null) {
                await db.savePersonilInspeksi(personilInspeksi);
              } else {

                PersonilInspeksi personilInspeksiUpdate = PersonilInspeksi(
                  id: value.id,
                  id_personil: personil['id'],
                  st_inspeksi_id: personil['st_inspeksi_id'],
                  nama_personil: personil['detail_user']['name'],
                  status: personil['status'],
                );

                await db.updatePersonilInspeksi(personilInspeksiUpdate);
              }
            });
        }
    } else {
      ErrorMessage().showMessage(
          context, 'Terjadi Kesalahan', responsePersonilInspeksi.body);

      return;
    }
  }

  Future<void> _getDataKategoriInspeksi(
    String kategoriJenis, inspeksiJenis) async {

    await db.deleteAllKategoriInspeksi();

    String? token = _prefs.getString('token');
    Map<String, String> headers = {"Authorization": "Bearer $token"};

    final responseKategoriInspeksi =
        await http.post(Uri.parse(ENV.GetKategoriInspeksi),
            body: {
              'inspeksi_jenis': inspeksiJenis,
              'kategori_jenis': kategoriJenis,
            },
            headers: headers);

    if (responseKategoriInspeksi.statusCode == 200) {
      final responseDataKategoriInspeksi = jsonDecode(responseKategoriInspeksi.body)['data'];

      responseDataKategoriInspeksi.forEach((kategori) async {
        KategoriInspeksi kategoriInspeksi = KategoriInspeksi(
          id_kategori: kategori['id'].toString(),
          inspeksi_jenis: kategori['inspeksi_jenis'],
          kategori_jenis: kategori['kategori_jenis'],
          nama_kategori: kategori['nama_kategori'],
        );

        await db.getKategoriInspeksiById(kategori['id']).then((value) async {
          if (value == null) {
            await db.saveKategoriInspeksi(kategoriInspeksi);
          } else {
            KategoriInspeksi kategoriInspeksiupdate = KategoriInspeksi(
              id: value.id,
              id_kategori: kategori['id'].toString(),
              inspeksi_jenis: kategori['inspeksi_jenis'],
              kategori_jenis: kategori['kategori_jenis'],
              nama_kategori: kategori['nama_kategori'],
            );

            await db.updateKategoriInspeksi(kategoriInspeksiupdate);
          }
        });
      });
    } else {
      ErrorMessage().showMessage(
          context, 'Terjadi Kesalahan', responseKategoriInspeksi.body);
    }
  }

  Future<void> _getLocalData() async {
    List<SuratTugas> suratTugasList = await db.getAllSuratTugas();

    setState(() {
      _suratTugasList = suratTugasList;
    });
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    await _checkConnection();
  }

  void _searchItem(String value) {
    setState(() {
      _searchResult = _suratTugasList
          .where((item) =>
              item.no_surat.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          if (_isLoading) {
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: SafeArea(
          child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/BG.png"),
                  fit: BoxFit.cover,
                ),
              ),
              width: screenWidth,
              height: screenHeight,
              child: CustomScrollView(slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: 130.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Image.asset(
                      'assets/images/banner1.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  title: const Text('Pengawasan Rutin'),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                  ),
                  centerTitle: true,
                  snap: true,
                  pinned: true,
                  floating: true,
                  bottom: AppBar(
                    toolbarHeight: 75,
                    backgroundColor: Colors.transparent,
                    title: SizedBox(
                      height: 50,
                      child: TextFormField(
                        controller: _searchController,
                        onChanged: (value) {
                          _searchItem(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari Surat Tugas',
                          hintStyle: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.normal,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          suffixIcon: const Icon(
                            Icons.search,
                            color: Colors.blue,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    automaticallyImplyLeading: false,
                  ),
                ),
                SliverList(
                  delegate: _suratTugasList.isEmpty
                      ? SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return const ListTile(
                              title: Text('No data available'),
                            );
                          },
                          childCount: 1, // Display a single ListTile
                        )
                      : SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            final suratTugas = _searchResult.isNotEmpty
                                ? _searchResult[index]
                                : _suratTugasList[index];
                            Icon leadingIcon;
                            Widget statusText;

                            if (suratTugas.status == 1) {
                              leadingIcon = const Icon(
                                Icons.stacked_bar_chart,
                                color: Colors.blue,
                                size: 33,
                              );
                              statusText = Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                                width: double.infinity,
                                child: const Text(
                                  'Siap Inspeksi',
                                  style: TextStyle(
                                    color: Colors
                                        .white, // Set text color for status 1
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            } else if (suratTugas.status == 2) {
                              leadingIcon = _isDone
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 33,
                                    )
                                  : const Icon(
                                      Icons.stacked_bar_chart,
                                      color: Colors.blue,
                                      size: 33,
                                    );
                              statusText = Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: _isDone ? Colors.green : Colors.blue,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                                width: double.infinity,
                                child: Text(
                                  _isDone
                                      ? 'Menunggu Inspeksi Lain'
                                      : 'Siap Inspeksi',
                                  style: const TextStyle(
                                    color: Colors
                                        .white, // Set text color for status 2
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            } else if (suratTugas.status == 3) {
                              leadingIcon = const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 33,
                              );
                              statusText = Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                                width: double.infinity,
                                child: const Text(
                                  'Selesai Inspeksi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            } else {
                              leadingIcon = const Icon(
                                Icons.apps,
                                color: Colors.orangeAccent,
                                size: 33,
                              );
                              statusText = Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                decoration: const BoxDecoration(
                                  color: Colors
                                      .orangeAccent, // Set background color for other statuses
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                                width: double.infinity,
                                child: const Text(
                                  'Belum Generate Pertanyaan',
                                  style: TextStyle(
                                    color: Colors
                                        .white, // Set text color for other statuses
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            return Container(
                                margin: const EdgeInsets.only(
                                    left: 10, right: 10, top: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: leadingIcon,
                                      title: Text(suratTugas.no_surat,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      subtitle: Text(
                                          DateFormat(
                                                  "EEEE, d MMMM yyyy", "id_ID")
                                              .format(DateTime.parse(suratTugas
                                                  .tgl_inspeksi
                                                  .toString())),
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                          )),
                                      trailing:
                                          const Icon(Icons.arrow_forward_ios),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailPengawasanRutin(suratTugasId: suratTugas.id_surat_tugas),
                                          ),
                                        );
                                      },
                                    ),
                                    statusText,
                                  ],
                                ));
                          },
                          childCount: _searchResult.isNotEmpty
                              ? _searchResult.length
                              : _suratTugasList.length,
                        ),
                ),
              ])),
        ),
      ),
    );
  }
}
