import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

//My imported files
import './home.dart';
import './dashboard.dart';
import './loginPage.dart';

class MySplashScreenPage extends StatefulWidget {
  //const MySplashScreenPage({Key? key}) : super(key: key);

  @override
  _MySplashScreenPageState createState() => _MySplashScreenPageState();

}

class _MySplashScreenPageState extends State<MySplashScreenPage> {

  late SharedPreferences _prefs;

  late String loggedInUserToken;

  _MySplashScreenPageState();

  // check if the user is logged in
  _checkLoggedInUserToken() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.getString("loggedInUserToken") != null) {
      loggedInUserToken = _prefs.getString("loggedInUserToken")!;
      setState(() {});
    } else {
      loggedInUserToken = "";
    }

    if(loggedInUserToken == null || loggedInUserToken =="") {
        //if the user is not logged in,
        //go to the login page
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const Home())
        );
      } else {
        //if the user is logged in
        //take him to the homepage
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => Dashboard())
        );
      }
  }

  @override
  void initState() {
    super.initState();

    //Automatically redirect to the next phase
    //after displaying the splashscreen for 5 seconds
    Timer(const Duration(seconds: 5), () {
        _checkLoggedInUserToken();
      }
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        //primaryColor: Colors.brown[600]
        //primarySwatch: Colors.brown
        primaryColor: const Color.fromRGBO(26, 188, 156, 1)
        //primarySwatch: Colors.green,
        //primaryColor: Color.fromARGB(255, 38, 120, 40)
      ),
      home: Container(
        decoration: const BoxDecoration(color: Colors.white),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                "assets/images/file-upload-image2.png",
                width: 200,
                height: 200,
              )
            ),
            Center(
              child: Text(
                "Leno Files",
                style: GoogleFonts.acme(
                  textStyle: const TextStyle(
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.black
                  )
                ),
              )
            ),
            Center(
              child: Text(
                "Developed by Colin Uchem",
                style: GoogleFonts.acme(
                  fontStyle: FontStyle.italic,
                  textStyle: const TextStyle(
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black,
                  )
                ),
              )
            )
          ],
        )
      )
    );
  }
}