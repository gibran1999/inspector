// ignore_for_file: use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/info_message.dart';
import '../components/loadingoverlay.dart';
import '../db_helpers/database.dart';
import '../models/personil_inspeksi.dart';
import '../models/surat_tugas.dart';

class DetailPengawasanRutin extends StatefulWidget {
  final int? suratTugasId;
  const DetailPengawasanRutin({Key? key, this.suratTugasId}) : super(key: key);

  @override
  State<DetailPengawasanRutin> createState() => _DetailPengawasanRutinState();
}

class _DetailPengawasanRutinState extends State<DetailPengawasanRutin> {
  late SharedPreferences _prefs;

  final DatabaseHelper db = DatabaseHelper();
  List<PersonilInspeksi> _personilInspeksi = [];
  Map<String, dynamic>? _suratTugas;
  bool _isgenerate = false;
  bool _isDone = false;
  bool _isLoading = true;
  bool _isOnline = false;
  String status = '';
  String? name = '';
  String textButton = '';

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initPrefs() async {
    CustomLoadingProgress.start(context);

    setState(() {
      _isLoading = true;
    });

    _prefs = await SharedPreferences.getInstance();

    await _checkConnection();

    await _loadSuratTugas();

    await _loadpersonilInspeksi();

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    CustomLoadingProgress.stop();
  }

  Future<void> _checkConnection() async {
    ConnectivityResult connectivityResult;

    connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
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
    }
  }

  Future<SuratTugas?> _loadSuratTugas() async {
    final database = DatabaseHelper();

    final suratTugas = await database.getSuratTugasById(widget.suratTugasId!);

    setState(() {
      _suratTugas = suratTugas?.toMap();
    });

    return null;
  }

  Future<void> _loadpersonilInspeksi() async {
    final database = DatabaseHelper();

    final personilInspeksiList =
        await database.getAllPersonilInspeksiByStId(widget.suratTugasId!);
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _personilInspeksi = personilInspeksiList;
      if (_suratTugas!['status'] == 0) {
        if (_personilInspeksi.first.nama_personil == prefs.getString('name')) {
          if (status == 'Online' && _isOnline == true) {
            _isgenerate = true;
            _isDone = false;
            textButton = 'Generate Pertanyaan';
          } else {
            _isgenerate = false;
            _isDone = false;
          }
        } else {
          _isgenerate = false;
          _isDone = false;
        }
      } else if (_suratTugas!['status'] == 1) {
        _isgenerate = true;
        textButton = 'Lanjutkan Inspeksi';
      } else if (_suratTugas!['status'] == 2) {
        _personilInspeksi.forEach((element) {
          if (element.nama_personil == prefs.getString('name') &&
              element.status == 2) {
            _isDone = true;
            _isgenerate = false;
            textButton = 'Lihat Hasil Inspeksi';
          } else if (element.nama_personil == prefs.getString('name') &&
              element.status == 0) {
            _isDone = false;
            _isgenerate = true;
            textButton = 'Lanjutkan Inspeksi';
          }
        });
      } else if (_suratTugas!['status'] == 3) {
        _personilInspeksi.forEach((element) {
          if (element.nama_personil == prefs.getString('name') &&
              element.status == 2) {
            _isDone = true;
            _isgenerate = false;
            textButton = 'Lihat Hasil Inspeksi';
          } else if (element.nama_personil == prefs.getString('name') &&
              element.status == 0) {
            _isDone = false;
            _isgenerate = true;
            textButton = 'Lanjutkan Inspeksi';
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        body: SafeArea(
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
          expandedHeight: 70.0,
          flexibleSpace: FlexibleSpaceBar(
            background: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.asset(
                'assets/images/banner1.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: const Text('Detail Pengawasan Rutin'),
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
          forceElevated: true,
        ),
        SliverList(
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              child: Column(
                children: [
                  ExpansionTile(
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: const Row(
                      children: [
                        Icon(Icons.library_books),
                        SizedBox(width: 10),
                        Text('Detail Surat Tugas'),
                      ],
                    ),
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 10, top: 0),
                        width: MediaQuery.of(context).size.width,
                        child: Text('${_suratTugas?['no_surat']}'),
                      ),
                      // add more widgets as needed
                    ],
                  ),
                  const SizedBox(height: 15),
                  ExpansionTile(
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: const Row(
                      children: [
                        Icon(Icons.apartment_rounded),
                        SizedBox(width: 10),
                        Text('Detail Perusahaan'),
                      ],
                    ),
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 10, top: 0),
                        width: MediaQuery.of(context).size.width,
                        child: Text('${_suratTugas?['nama_perusahaan']}'),
                      ),
                      // add more widgets as needed
                    ],
                  ),
                  const SizedBox(height: 15),
                  ExpansionTile(
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: const Row(
                      children: [
                        Icon(Icons.supervisor_account),
                        SizedBox(width: 10),
                        Text('Detail Personil Inspeksi'),
                      ],
                    ),
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 10, top: 0),
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _personilInspeksi.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                                title: Text(_personilInspeksi[index].nama_personil.toString()),
                                subtitle: Column(
                                  children: [
                                    Visibility(
                                        visible:
                                            _personilInspeksi[index].status ==
                                                1,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                              'Belum memulai Inspeksi',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        )),
                                    Visibility(
                                      visible:
                                          _personilInspeksi[index].status == 2,
                                      child: const Text('Sedang Inspeksi'),
                                    ),
                                  ],
                                )
                              );
                          },
                        ),
                      ),
                      // add more widgets as needed
                    ],
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            );
          }, childCount: 1),
        )
      ]),
    )));
  }
}
