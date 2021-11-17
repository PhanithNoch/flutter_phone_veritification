import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FirebasePhoneAuthProvider(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  final Function callBack;
  ButtonWidget({required this.callBack});
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          callBack();
        },
        child: Text("Sumit"));
  }
}

class HomePage extends StatelessWidget {
  TextEditingController username = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: username,
          ),
          ButtonWidget(
            callBack: () {},
          )
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  String? _enteredOTP;
  static const _phoneNumber = "+85511504463";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FirebasePhoneAuthHandler(
        phoneNumber: _phoneNumber,
        timeOutDuration: const Duration(seconds: 60),
        onLoginSuccess: (userCredential, autoVerified) async {
          print(autoVerified
              ? "OTP was fetched automatically"
              : "OTP was verified manually");

          print("Login Success UID: ${userCredential.user?.uid}");
        },
        onLoginFailed: (authException) {
          print("An error occurred: ${authException.message}");

          // handle error further if needed
        },
        builder: (context, controller) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Verification Code"),
              backgroundColor: Colors.black,
              actions: controller.codeSent
                  ? [
                      TextButton(
                        child: Text(
                          controller.timerIsActive
                              ? "${controller.timerCount.inSeconds}s"
                              : "RESEND",
                          style: TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                        onPressed: controller.timerIsActive
                            ? null
                            : () async {
                                await controller.sendOTP();
                              },
                      ),
                      SizedBox(width: 5),
                    ]
                  : null,
            ),
            body: controller.codeSent
                ? ListView(
                    padding: EdgeInsets.all(20),
                    children: [
                      Text(
                        "We've sent an SMS with a verification code to $_phoneNumber",
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                      SizedBox(height: 10),
                      Divider(),
                      AnimatedContainer(
                        duration: Duration(seconds: 1),
                        height: controller.timerIsActive ? null : 0,
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 50),
                            Text(
                              "Listening for OTP",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Divider(),
                            Text("OR", textAlign: TextAlign.center),
                            Divider(),
                          ],
                        ),
                      ),
                      Text(
                        "Enter Code Manually",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextField(
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        onChanged: (String v) async {
                          _enteredOTP = v;
                          if (this._enteredOTP?.length == 6) {
                            final res =
                                await controller.verifyOTP(otp: _enteredOTP!);
                            // Incorrect OTP
                            if (!res)
                              print(
                                "Please enter the correct OTP sent to $_phoneNumber",
                              );
                          }
                        },
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 50),
                      Center(
                        child: Text(
                          "Sending OTP",
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                    ],
                  ),
            floatingActionButton: controller.codeSent
                ? FloatingActionButton(
                    backgroundColor: Theme.of(context).accentColor,
                    child: Icon(Icons.check),
                    onPressed: () async {
                      if (_enteredOTP == null || _enteredOTP?.length != 6) {
                        print("Please enter a valid 6 digit OTP");
                        final res =
                            await controller.verifyOTP(otp: _enteredOTP!);
                        // Incorrect OTP
                        if (!res)
                          print(
                            "Please enter the correct OTP sent to $_phoneNumber",
                          );
                      }
                    },
                  )
                : null,
          );
        },
      ),
    );
  }
}
