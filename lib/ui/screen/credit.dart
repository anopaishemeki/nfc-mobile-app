import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_wallet/util/file_path.dart';

class CreditDetails extends StatefulWidget {
  @override
  _CreditDetailsFormState createState() => _CreditDetailsFormState();
}

class _CreditDetailsFormState extends State<CreditDetails> {
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

  void _makeWithdrawRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('user_id');
    final url = 'http://192.168.79.1:8000/api/credit/$username/';
    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        'amount': _amount,
        'currency': _currency,
        'receiving_services': _services,
        'account_number': _deviceId,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Credit Request made successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Credit to make Withdraw Request'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Credit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _topContent(),
              _centerContent(),
              _bottomContent(),
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

  Widget _centerContent() {
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
            'Make Credit Request',
            style: Theme.of(context).textTheme.headline5,
          ),
          const SizedBox(
            height: 18,
          ),
          // Form
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                // Amount Field
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
                // Currency Field
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
                // Receiving Service Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Receiving Service',
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
                // Account Number Field
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
                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _makeWithdrawRequest();
                    }
                  },
                  child: Text('Make Request'),
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
          'Credit',
          style: Theme.of(context).textTheme.button,
        ),
      ),
    );
  }
}
