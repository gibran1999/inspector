import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

import '../components/info_message.dart';
import 'pengawasan_rutin.dart';

class KaidahPertambangan extends StatefulWidget {
  const KaidahPertambangan({super.key});

  @override
  State<KaidahPertambangan> createState() => _KaidahPertambanganState();
}

class _KaidahPertambanganState extends State<KaidahPertambangan> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: screenWidth,
                      height: 170,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                "Kaidah Teknik \n Pertambangan Yang Baik",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    SolarIconsBold.roundArrowLeft,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Kembali",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PengawasanRutin()));
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/images/PRT.png"),
                                  fit: BoxFit.fill,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              width: screenWidth / 2 - 30,
                              height: 150,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              InfoMessage().showMessage(context, 'Informasi',
                                  'Mohon Maaf \n Menu Ini Belum Dapat Di Akses');
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/images/PKKBKS.png"),
                                  fit: BoxFit.fill,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              width: screenWidth / 2 - 30,
                              height: 150,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              InfoMessage().showMessage(context, 'Informasi',
                                  'Mohon Maaf \n Menu Ini Belum Dapat Di Akses');
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/images/PPI.png"),
                                  fit: BoxFit.fill,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              width: screenWidth / 2 - 30,
                              height: 150,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              InfoMessage().showMessage(context, 'Informasi', 'Mohon Maaf \n Menu Ini Belum Dapat Di Akses');
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/images/EDT.png"),
                                  fit: BoxFit.fill,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              width: screenWidth / 2 - 30,
                              height: 150,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              InfoMessage().showMessage(context, 'Informasi',
                                  'Mohon Maaf \n Menu Ini Belum Dapat Di Akses');
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/images/evaluasi-keberhasilan-pelaksanaan-reklamasi.png"),
                                  fit: BoxFit.fill,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              width: screenWidth / 2 - 30,
                              height: 150,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              InfoMessage().showMessage(context, 'Informasi',
                                  'Mohon Maaf \n Menu Ini Belum Dapat Di Akses');
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      "assets/images/evaluasi-keberhasilan-pelaksanaan-pasca-tambang.png"),
                                  fit: BoxFit.fill,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              width: screenWidth / 2 - 30,
                              height: 150,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        )
      ),
    );
  }
}
