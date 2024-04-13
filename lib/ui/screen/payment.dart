import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_wallet/util/file_path.dart';


class PaymentDetailsForm extends StatefulWidget {
  @override
  _PaymentDetailsFormState createState() => _PaymentDetailsFormState();
}

class _PaymentDetailsFormState extends State<PaymentDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  static DateTime now = DateTime.now();
  String formattedTime = DateFormat.jm().format(now);
  String formattedDate = DateFormat('EEE, MMM d, yyyy').format(now);

  String _amount = '';
  String _currency = '';
  String _services = '';
  String _deviceId = '';
  String _receiver= '';

  bool _isNFCEnabled = false;
  bool _isNFCSupported = false;
  bool _isNFCSessionStarted = false;

  @override
  void initState() {
    super.initState();
    _checkNFCStatus();
  }

  @override
  void dispose() {
    _clearNFCSession();
    super.dispose();
  }

  Future<void> _checkNFCStatus() async {
    bool isNFCEnabled = await NfcManager.instance.isAvailable();
    bool isNFCSupported = await NfcManager.instance.isAvailable();

    setState(() {
      _isNFCEnabled = isNFCEnabled;
      _isNFCSupported = isNFCSupported;
    });
  }

  Future<void> _makeWithdrawRequest(var nfcToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('user_id');
    final url = 'http://192.168.79.1:8000/api/payment/$username/';
    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        'amount': _amount,
        'currency': _currency,
        'paying_services': _services,
        'account_number': _deviceId,
        'nfc_token': nfcToken,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment made successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to make Payment'),
        ),
      );
    }
  }

  Future<void> _startNFCSession() async {
    try {
      if (!_isNFCSessionStarted) {
        setState(() {
          _isNFCSessionStarted = true;
        });

        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            var nfcToken =  tag.data;
            if (nfcToken != null) {
              _makeWithdrawRequest(nfcToken);
            } else {
              _makeWithdrawRequest('000');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('NFC Communication Failed'),
                ),
              );
            }
          },
        );
      }
    } catch (e) {
      print('Error during NFC communication: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during NFC communication'),
        ),
      );
    }
  }

  Future<void> _clearNFCSession() async {
    if (_isNFCSessionStarted) {
      await NfcManager.instance.stopSession();
      setState(() {
        _isNFCSessionStarted = false;
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _topContent(),
              _formContent(),
              _bottomContent()
            ],
          ),
        ),
      ),
    );
  }

    Widget _topContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 18,
        ),
        Row(
          children: <Widget>[
            Text(
              formattedTime,
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(
              width: 25,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              ' Smart NFC',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          formattedDate,
          style: Theme.of(context).textTheme.bodyText2,
        )
      ],
    );
  }

Widget _formContent() {
  return Align(
    alignment: Alignment.centerLeft,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Logo
        SvgPicture.asset(logo),
        const SizedBox(
          height: 18,
        ),
        // Title
        Text(
          'Make Payment Request',
          style: Theme.of(context).textTheme.headline5,
        ),
        const SizedBox(
          height: 18,
        ),
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount';
                  }
                  return null;
                },
                onSaved: (value) => _amount = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the currency';
                  }
                  return null;
                },
                onSaved: (value) => _currency = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Services',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the services';
                  }
                  return null;
                },
                onSaved: (value) => _services = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Device ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the device ID';
                  }
                  return null;
                },
                onSaved: (value) => _deviceId = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Receiver',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the receiver';
                  }
                  return null;
                },
                onSaved: (value) => _receiver = value!,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_isNFCSupported && _isNFCEnabled) {
                     _formKey.currentState!.save();
                    _startNFCSession();
                  } else {
                     _formKey.currentState!.save();
                    _makeWithdrawRequest('000');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('NFC is not supported or enabled on this device'),
                      ),
                    );
                  }
                },
                child: Text('Make Payment'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

 Widget _bottomContent() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.pop(context); // Navigate back to home page
        },
        child: Text(
          'Go Back',
          style: Theme.of(context).textTheme.button,
        ),
      ),
    );
  }
}
