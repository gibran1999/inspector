// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:inspector/env.dart';
import 'package:inspector/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/error_message.dart';
import '../../components/loadingoverlay.dart';
import '../../db_helpers/database.dart';
import '../../models/user.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late SharedPreferences _prefs;
  final DatabaseHelper db = DatabaseHelper();

  bool _isLoading = false;
  bool _isHidden = true;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _login() async {
    CustomLoadingProgress.start(context);

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ENV.Login),
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _prefs.setInt('id', responseData['data']['id']);
        _prefs.setString('token', responseData['meta']['token']);
        _prefs.setString('email', responseData['data']['email']);
        _prefs.setString('name', responseData['data']['name']);
        _prefs.setInt('jenis_users_id', responseData['data']['jenis_users']);
        _prefs.setBool('isLoggedIn', true);

        final User user = User(
          id_user: responseData['data']['id'],
          name: responseData['data']['name'],
          email: responseData['data']['email'],
        );

        await db.getUserByEmail(responseData['data']['email']).then((value) async {
          if (value == null) {
            await db.saveUser(user);
          } else {
            await db.updateUser(user);
          }
        });

        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          _isLoading = false;
        });

        CustomLoadingProgress.stop();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => const HomePage(),
          ),
          (route) => false,
        );
      } else if (responseData['success'] == 'false') {
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          _isLoading = false;
        });

        CustomLoadingProgress.stop();

        ErrorMessage().showMessage(context, 'Terjadi Kesalahan',
            'Email atau password yang anda masukan salah');
      } else {
        print(response.body);
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      CustomLoadingProgress.stop();

      ErrorMessage().showMessage(context, 'Terjadi Kesalahan', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: WillPopScope(
            onWillPop: () async {
              if (_isLoading) {
                return Future.value(false);
              } else {
                return Future.value(true);
              }
            },
            child: SingleChildScrollView(
              child: Container(
                width: screenWidth,
                height: screenHeight,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/bg-login.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/text_logo.png",
                      width: screenWidth / .5,
                    ),
                    Text(
                      "Silahkan masuk menggunakan akun anda",
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                          fontSize: 16),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'Masukkan email anda',
                                  labelStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  hintStyle: const TextStyle(
                                      color: Color(0xFFD7DBDD),
                                      fontWeight: FontWeight.w400),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(
                                            0xFFF9F9F9)), // Merubah warna border saat normal
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(
                                            0xFFF9F9F9)), // Merubah warna border saat sedang aktif/focus
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(0xFFF9F9F9)),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email harus diisi';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _isHidden,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Masukkan password anda',
                                  labelStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  hintStyle: const TextStyle(
                                      color: Color(0xFFD7DBDD),
                                      fontWeight: FontWeight.w400),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isHidden
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isHidden = !_isHidden;
                                      });
                                    },
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(0xFFF9F9F9)),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(0xFFF9F9F9)),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(0xFFF9F9F9)),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password harus diisi';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF78272E),
                                      Color(0xFF984C59)
                                    ],
                                    stops: [0, 1],
                                    tileMode: TileMode.clamp,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    if (_formKey.currentState != null &&
                                        _formKey.currentState!.validate()) {
                                      // Login();
                                    }

                                    _login();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    backgroundColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    "Masuk",
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 18),
                                  ),
                                ),
                              )
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            )));
  }
}
