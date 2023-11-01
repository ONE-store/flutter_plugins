import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_onestore_inapp/flutter_onestore_inapp.dart';

import '../widget/custom_widget.dart';
import '../../res/colors.dart';
import '../../config/app_config.dart';

class CheckLicensePage extends StatefulWidget {
  const CheckLicensePage({super.key});

  @override
  State<CheckLicensePage> createState() => _CheckLicensePageState();
}

class _CheckLicensePageState extends State<CheckLicensePage>
    implements LicenseCallback {
  // Licensing client 생성
  late LicenseClient _licensingClient;

  @override
  void initState() {
    super.initState();
    _licensingClient = LicenseClient(AppConfig.publicKey, this);
  }

  @override
  void dispose() {
    super.dispose();
    _licensingClient.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Check License'),
          backgroundColor: AppColors.primaryColor,
        ),
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildButton(
                    title: 'Query License',
                    action: () {
                      _licensingClient.queryLicense();
                    }),
                Container(height: 30),
                buildButton(
                    title: 'Strict Query License',
                    action: () {
                      _licensingClient.strictQueryLicense();
                    }),
              ],
            ),
          ),
        ));
  }

  @override
  void onGranted(String license, String signature) {
    Fluttertoast.showToast(
        msg: 'onGranted',
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT);
  }

  @override
  void onDenied() {
    Fluttertoast.showToast(
        msg: 'onDenied',
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT);
  }

  @override
  void onError(int code, String message) {
    Fluttertoast.showToast(
        msg: 'onError(code: $code, message: $message)',
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT);
  }
}
