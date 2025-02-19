import 'package:flutter/material.dart';
import 'package:flutter_wallet/ui/screen/sign_in.dart';
import 'package:flutter_wallet/ui/screen/deposit.dart';
import 'package:flutter_wallet/ui/screen/payment.dart';
import 'package:flutter_wallet/ui/screen/credit.dart';
import 'package:flutter_wallet/util/constant.dart';
import 'package:flutter_wallet/util/theme.dart';
import 'package:flutter_wallet/ui/screen/withdraw.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

ThemeManager _themeManager = ThemeManager();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    _themeManager.addListener(themeListener);
    super.initState();
  }

  @override
  void dispose() {
    _themeManager.removeListener(themeListener);
    super.dispose();
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart NFC App',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: SignInPage(),
    );
  }
}
