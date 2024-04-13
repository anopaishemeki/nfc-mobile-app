import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter_wallet/ui/screen/drawer_page.dart';
import 'package:flutter_wallet/util/file_path.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_wallet/util/file_path.dart';
import 'package:url_launcher/url_launcher.dart';
class DepositDetails extends StatefulWidget {
  @override
  _DepositDetailsFormState createState() => _DepositDetailsFormState();
}

class _DepositDetailsFormState extends State<DepositDetails> {
  final _formKey = GlobalKey<FormState>();
  static DateTime now = DateTime.now();
  String formattedTime = DateFormat.jm().format(now);
  String formattedDate = DateFormat('EEE, MMM d, yyyy').format(now);

  String _amount = '';
  String _currency = '';
  String _services = '';
  String _deviceId = '';

  // @override
  // void initState() {
  //   super.initState();
  //   getUsernameFromPreferences().then((username) {
  //     fetchWithdrawals(
  //         username); // Call fetchWithdrawals with the retrieved username
  //   });
  // }
  
Future<void> _launchInBrowserView(Uri url) async {
  if (!await launch(url.toString(), forceWebView: true, enableJavaScript: true)) {
    throw Exception('Could not launch $url');
  }
}

  void _makeWithdrawRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('user_id');
    final url = 'http://192.168.79.1:8000/api/deposit/$username/';
    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        'amount': _amount,
        'currency': _currency,
        'paying_services': _services,
        'account_number': _deviceId,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    final String redirectUrl = responseData['redirect_url'];
    
    // Launch the URL in the browser
    await _launchInBrowserView(Uri.parse(redirectUrl));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Withdraw Request made successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to make Withdraw Request'),
        ),
      );
    }
  }

   Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Enable resizing to avoid bottom insets
      appBar: AppBar(
        title: Text('Deposit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView( // Wrap your content with SingleChildScrollView
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _topContent(),
              _centerContent(),
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
        ),
      ],
    );
  }

  Widget _centerContent() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SvgPicture.asset(logo),
          const SizedBox(
            height: 18,
          ),
          Text(
            'Make Deposit',
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
                const SizedBox(
                  height: 16,
                ),
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
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Paying Service',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter service';
                    }
                    return null;
                  },
                  onSaved: (value) => _services = value!,
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Account Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the account id';
                    }
                    return null;
                  },
                  onSaved: (value) => _deviceId = value!,
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _makeWithdrawRequest();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Deposit Made successfully'),
                        ),
                      );
                    }
                  },
                  child: Text('Make Deposit'),
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
          // Perform navigation to next page
        },
        child: Text(
          'Deposit',
          style: Theme.of(context).textTheme.button,
        ),
      ),
    );
  }
}
