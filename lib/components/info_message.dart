import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class InfoMessage {
  Future<void> showMessage(BuildContext context, String title, String message) async {
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      headerAnimationLoop: false,
      title: title,
      desc: message,
      btnOkOnPress: () {},
      btnOkIcon: Icons.check,
      btnOkColor: Colors.red,
    ).show();
  }
}