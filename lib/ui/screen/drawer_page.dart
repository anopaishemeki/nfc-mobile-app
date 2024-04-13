import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_wallet/ui/screen/home_page.dart';
import 'package:flutter_wallet/ui/screen/credit.dart';
import 'package:flutter_wallet/ui/screen/deposit.dart';
import 'package:flutter_wallet/ui/screen/withdraw.dart';
import 'package:flutter_wallet/ui/screen/payment.dart';
import 'package:flutter_wallet/util/file_path.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_wallet/util/file_path.dart';


String Fullname = '';
String email = '';


class DrawerPage extends StatefulWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> with TickerProviderStateMixin {
  bool sideBarActive = false;
  late AnimationController rotationController;
  @override
  void initState() {
    rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    super.initState();
    getUsernameFromPreferences().then((username) {
      fetchWithdrawals(username);
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
    Map<String, dynamic> wallet = jsonData['user'];
    Fullname = wallet['username'] + wallet['last_name'];
    email = wallet['email'];
  
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
      backgroundColor: Theme.of(context).cardColor,
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 100,
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(60)),
                        color: Theme.of(context).backgroundColor),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border:
                                    Border.all(color: const Color(0xffD8D9E4))),
                            child: CircleAvatar(
                              radius: 22.0,
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              child: ClipRRect(
                                child: SvgPicture.asset(avatorOne),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            
                            children: [
                              
                              Text(
                                Fullname,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              Text(
                                email,
                                style: Theme.of(context).textTheme.bodyText1,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    navigatorTitle("Home", true, () {
                      navigateToPage(HomePage());
                    }),
                    navigatorTitle("Make Payment", false, () {
                      navigateToPage(PaymentDetailsForm());
                    }),
            
                    navigatorTitle("Deposit Details", false, () {
                      navigateToPage(DepositDetails());
                    }),
                    navigatorTitle("Withdraw Details", false, () {
                      navigateToPage(WithdrawDetails());
                    }),
                    navigatorTitle("Credit Details", false, () {
                      navigateToPage(CreditDetails());
                    }),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.power_settings_new,
                      size: 24,
                      color: Theme.of(context).iconTheme.color,
                      // color: sideBarActive ? Colors.black : Colors.white,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Logout",
                      style: Theme.of(context).textTheme.headline6,
                    )
                  ],
                ),
              ),
              Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Ver 2.0.1",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              )
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: (sideBarActive) ? MediaQuery.of(context).size.width * 0.6 : 0,
            top: (sideBarActive) ? MediaQuery.of(context).size.height * 0.2 : 0,
            child: RotationTransition(
              turns: (sideBarActive)
                  ? Tween(begin: -0.05, end: 0.0).animate(rotationController)
                  : Tween(begin: 0.0, end: -0.05).animate(rotationController),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: (sideBarActive)
                    ? MediaQuery.of(context).size.height * 0.7
                    : MediaQuery.of(context).size.height,
                width: (sideBarActive)
                    ? MediaQuery.of(context).size.width * 0.8
                    : MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: sideBarActive
                      ? const BorderRadius.all(Radius.circular(40))
                      : const BorderRadius.all(Radius.circular(0)),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: sideBarActive
                      ? const BorderRadius.all(Radius.circular(40))
                      : const BorderRadius.all(Radius.circular(0)),
                  child: const HomePage(),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 20,
            child: (sideBarActive)
                ? IconButton(
                    padding: const EdgeInsets.all(30),
                    onPressed: closeSideBar,
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).iconTheme.color,
                      size: 30,
                    ),
                  )
                : InkWell(
                    onTap: openSideBar,
                    child: Container(
                      margin: const EdgeInsets.all(17),
                      height: 30,
                      width: 30,
                    ),
                  ),
          )
        ],
      ),
    );
  }

  void navigateToPage(Widget page) {
    setState(() {
      sideBarActive = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Row navigatorTitle(String name, bool isSelected, VoidCallback onTap) {
    return Row(
      children: [
        (isSelected)
            ? Container(
                width: 5,
                height: 40,
                color: const Color(0xffffac30),
              )
            : const SizedBox(
                width: 5,
                height: 40,
              ),
        const SizedBox(
          width: 10,
          height: 45,
        ),
        InkWell(
          onTap: onTap,
          child: Text(
            name,
            style: Theme.of(context).textTheme.headline6!.copyWith(
                  fontSize: 16,
                  fontWeight: (isSelected) ? FontWeight.w700 : FontWeight.w400,
                ),
          ),
        ),
      ],
    );
  }

  void closeSideBar() {
    sideBarActive = false;
    setState(() {});
  }

  void openSideBar() {
    sideBarActive = true;
    setState(() {});
  }
}
