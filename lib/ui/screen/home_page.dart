import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_wallet/ui/screen/credit.dart';
import 'package:flutter_wallet/ui/screen/deposit.dart';
import 'package:flutter_wallet/ui/screen/drawer_page.dart';
import 'package:flutter_wallet/ui/screen/payment.dart';
import 'package:flutter_wallet/ui/screen/withdraw.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_wallet/util/file_path.dart';

int walletId = 0;
String accountName = '';
String currency = '';
String dateAdded = '';
String dualAccount = '';
double amountZig = 0.0;
double amountUsd = 0.0;
String cellNumber = '';
String walletDate = '';
int userId = 0;
int createdBy = 0;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    getUsernameFromPreferences().then((username) {
      fetchWithdrawals(
          username); // Call fetchWithdrawals with the retrieved username
    });
  }

  Future<String> getUsernameFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ??
        ''; // Assuming 'username' is the key used to store the username
  }

  Future<void> fetchWithdrawals(String username) async {
    final String apiUrl = 'http://192.168.79.1:8000/api/dashboard/$username/';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        final Map<String, dynamic> data = jsonDecode(response.body);

// Call a function to parse the JSON and extract the data
        parseJsonResponse(data);
        // Iterate over the list of withdrawals and do something with;each withdrawal
      } else {
        // If the server returns an error response, throw an exception
        throw Exception(
            'Failed to load withdrawals. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Catch any errors that occur during the HTTP request
      print('Error: $e');
    }
  }

  void parseJsonResponse(Map<String, dynamic> jsonData) {
    Map<String, dynamic> wallet = jsonData['wallet'];
    walletId = wallet['id'];
    accountName = wallet['account_name'];
    currency = wallet['currency'];
    dateAdded = wallet['date_added'];
    dualAccount = wallet['dual_account'];
    amountZig = double.parse(wallet['amount_zig']);
    amountUsd = double.parse(wallet['amount_usd']);
    cellNumber = wallet['cell_number'];
    walletDate = wallet['date'];
    userId = wallet['user'];
    createdBy = wallet['created_by'];

    // Extract transactions
    // List<dynamic> transactions = data['transactions'];
    // List<Transaction> transactionList = [];
    // for (var transaction in transactions) {
    //   int id = transaction['id'];
    //   String date = transaction['date'];
    //   String transId = transaction['trans_id'];
    //   double amount = double.parse(transaction['amount']);
    //   String transactionCurrency = transaction['currency'];
    //   String transactionType = transaction['transaction_type'];
    //   String status = transaction['status'];
    //   int userId = transaction['user'];

    //   // Create Transaction object and add it to the list
    //   Transaction newTransaction = Transaction(
    //     id: id,
    //     date: date,
    //     transId: transId,
    //     amount: amount,
    //     currency: transactionCurrency,
    //     transactionType: transactionType,
    //     status: status,
    //     userId: userId,
    //   );
    //   transactionList.add(newTransaction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(left: 18, right: 18, top: 34),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _contentHeader(),
              const SizedBox(
                height: 30,
              ),
              Text(
                accountName,
                style: Theme.of(context).textTheme.headline4,
              ),
              const SizedBox(
                height: 16,
              ),
              _contentOverView(),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Available Services',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  SvgPicture.asset(
                    scan,
                    color: Theme.of(context).iconTheme.color,
                    width: 18,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _contentSendMoney(),
              const SizedBox(
                height: 30,
              ),
              _contentDeposit(),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Coming soon',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  SvgPicture.asset(
                    filter,
                    color: Theme.of(context).iconTheme.color,
                    width: 18,
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              _contentServices(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contentHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            SvgPicture.asset(
              logo,
              width: 34,
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              'Smart NFC',
              style: Theme.of(context).textTheme.headline3,
            )
          ],
        ),
        InkWell(
          onTap: () {
            setState(() {
              // print('call');
              // xOffset = 240;
              // yOffset = 180;
              // scaleFactor = 0.7;
              // isDrawerOpen = true;
            });
          },
          child: SvgPicture.asset(
            menu,
            width: 16,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
      ],
    );
  }

  Widget _contentOverView() {
    return Container(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 22, bottom: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).cardColor,
        // color: const Color(0xffF1F3F6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Column for the first balance
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                amountUsd.toString(),
                style: Theme.of(context).textTheme.headline5,
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                'USD Balance',
                style: Theme.of(context).textTheme.headline4!.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ],
          ),
          const SizedBox(
            width: 24, // Adjust the spacing between the balances as needed
          ),
          // Column for the second balance
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                amountZig.toString(),
                style: Theme.of(context).textTheme.headline5,
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                'ZIG Balance',
                style: Theme.of(context).textTheme.headline4!.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ],
          ),
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: const Color(0xffFFAC30),
              borderRadius: BorderRadius.circular(80),
            ),
            child: const Center(
              child: Icon(
                Icons.add,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentSendMoney() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          InkWell(
            onTap: () {
              // Navigate to the withdrawal page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WithdrawDetails()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(16),
              width: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).cardColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: const Color(0xffD8D9E4))),
                    child: CircleAvatar(
                      radius: 22.0,
                      backgroundColor: Theme.of(context).backgroundColor,
                      child: ClipRRect(
                        child: SvgPicture.asset(cashback),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                  ),
                  Text(
                    'Withdraw',
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              // Navigate to the payments page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaymentDetailsForm()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(16),
              width: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).cardColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xffD8D9E4))),
                    child: CircleAvatar(
                      radius: 22.0,
                      backgroundColor: Theme.of(context).backgroundColor,
                      child: ClipRRect(
                        child: SvgPicture.asset(send),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                  ),
                  Text(
                    'Payment',
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
Widget _contentDeposit() {
  return SizedBox(
    height: 100,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        InkWell(
          onTap: () {
            // Navigate to the deposit money page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DepositDetails()),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(16),
            width: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xffD8D9E4))),
                  child: CircleAvatar(
                    radius: 22.0,
                    backgroundColor: Theme.of(context).backgroundColor,
                    child: ClipRRect(
                      child: SvgPicture.asset(mobile),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                ),
                Text(
                  'Deposit Money',
                  style: Theme.of(context).textTheme.bodyText1,
                )
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            // Navigate to the credit page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreditDetails()),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(16),
            width: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xffD8D9E4))),
                  child: CircleAvatar(
                    radius: 22.0,
                    backgroundColor: Theme.of(context).backgroundColor,
                    child: ClipRRect(
                      child: SvgPicture.asset(more),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                ),
                Text(
                  'Credit',
                  style: Theme.of(context).textTheme.bodyText1,
                )
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _contentServices(BuildContext context) {
    List<ModelServices> listServices = [];

    listServices.add(ModelServices(title: "Send\nMoney", img: send));
    listServices.add(ModelServices(title: "Receive\nMoney", img: recive));
    listServices.add(ModelServices(title: "Mobile\nPrepaid", img: mobile));
    listServices
        .add(ModelServices(title: "Electricity\nBill", img: electricity));
    listServices.add(ModelServices(title: "Cashback\nOffer", img: cashback));
    listServices.add(ModelServices(title: "Movie\nTickets", img: movie));
    listServices.add(ModelServices(title: "Flight\nTickets", img: flight));
    listServices.add(ModelServices(title: "More\nOptions", img: menu));

    return SizedBox(
      width: double.infinity,
      height: 400,
      child: GridView.count(
        crossAxisCount: 4,
        childAspectRatio: MediaQuery.of(context).size.width /
            (MediaQuery.of(context).size.height / 1.1),
        children: listServices.map((value) {
          return GestureDetector(
            onTap: () {
              // print('${value.title}');
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).cardColor,
                  ),
                  child: SvgPicture.asset(
                    value.img,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  value.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(
                  height: 14,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ModelServices {
  String title, img;
  ModelServices({required this.title, required this.img});
}
