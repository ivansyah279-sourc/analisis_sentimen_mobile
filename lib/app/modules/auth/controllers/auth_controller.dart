import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentimen_mobile/app/routes/app_pages.dart';

class AuthController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  var isPasswordVisible = false.obs;

  void login() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username == 'user' && password == 'user123') {
      Get.offAllNamed(Routes.INDEX);
    } else {
      Get.snackbar('Gagal', 'Username atau password salah',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
