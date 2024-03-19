// ignore_for_file: use_build_context_synchronously

import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:inspector/components/info_message.dart';
import 'package:inspector/pages/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_icons/solar_icons.dart';

import '../components/loadingoverlay.dart';
import 'kaidah_pertambangan.dart';

const List<TabItem> items = [
  TabItem(
    icon: Icons.home,
  ),
  TabItem(
    icon: Icons.notifications,
  ),
  TabItem(
    icon: Icons.menu_book,
  ),
  TabItem(
    icon: Icons.support_agent_outlined,
  ),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _selectedTab = _SelectedTab.home;
  late SharedPreferences _prefs;
  String name = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    setState(() {
      name = _prefs.getString('name')!;
    });
  }

  Future<void> _logout() async {
    CustomLoadingProgress.start(context);

    setState(() {
      _isLoading = true;
    });

    await _prefs.remove('email');
    await _prefs.remove('name');
    await _prefs.remove('token');
    await _prefs.remove('id');
    await _prefs.remove('jenis_users_id');
    _prefs.setBool('isLoggedIn', false);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    CustomLoadingProgress.stop();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) => const Login(),
      ),
      (route) => false,
    );
  }

  void _handleIndexChanged(int i) {
    setState(() {
      _selectedTab = _SelectedTab.values[i];
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
            child: SingleChildScrollView(
                child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/BG.png"),
                  fit: BoxFit.cover,
                ),
              ),
              width: screenWidth,
              height: screenHeight,
              child: Column(
                children: [
                  Visibility(
                      visible: _selectedTab == _SelectedTab.home,
                      child: Column(
                        children: [
                          Container(
                            width: screenWidth,
                            height: 180,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/images/banner1.png"),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, top: 20),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            SolarIconsOutline.userCircle,
                                            color: Colors.white,
                                            size: 35,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Halo, $name",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20, top: 20),
                                      child: IconButton(
                                        onPressed: () {
                                          AwesomeDialog(
                                                  context: context,
                                                  animType: AnimType.scale,
                                                  dialogType: DialogType.info,
                                                  title: 'Informasi',
                                                  desc:
                                                      'Apakah Anda Yakin Ingin Keluar ?',
                                                  btnOkText: 'Ya',
                                                  btnCancelText: 'Tidak',
                                                  btnOkOnPress: () {
                                                    _logout();
                                                  },
                                                  btnCancelOnPress: () {})
                                              .show();
                                        },
                                        icon: const Icon(
                                          SolarIconsOutline.logout,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    "Kaidah Pertambangan \nYang Baik",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const KaidahPertambangan()),
                              );
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/images/KP.png"),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              width: screenWidth,
                              height: 150,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: const Center(
                                child: Text(
                                  '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              InfoMessage().showMessage(context, 'Informasi',
                                  'Menu Ini Belum Dapat Di Akses');
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/images/TKPP.png"),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              width: MediaQuery.of(context).size.width,
                              height: 150,
                              margin: const EdgeInsets.only(
                                  top: 10, left: 20, right: 20, bottom: 20),
                              child: const Center(
                                child: Text(
                                  '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                  Visibility(
                    visible: _selectedTab == _SelectedTab.favorite,
                    child: SizedBox(
                      width: screenWidth,
                      height: screenHeight,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Favorite'),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _selectedTab == _SelectedTab.search,
                    child: SizedBox(
                      width: screenWidth,
                      height: screenHeight,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Search'),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _selectedTab == _SelectedTab.person,
                    child: SizedBox(
                      width: screenWidth,
                      height: screenHeight,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Person'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/BG.png"),
              fit: BoxFit.cover,
            ),
          ),
          padding: const EdgeInsets.only(bottom: 30, right: 32, left: 32),
          child: BottomBarInspiredFancy(
              backgroundColor: Colors.white,
              borderRadius: BorderRadius.circular(30),
              color: Colors.grey,
              colorSelected: Colors.blue,
              indexSelected: _SelectedTab.values.indexOf(_selectedTab),
              paddingVertical: 24,
              onTap: _handleIndexChanged,
              enableShadow: true,
              styleIconFooter: StyleIconFooter.dot,
              animated: true,
              items: items),
        ));
  }
}

enum _SelectedTab { home, favorite, search, person }
