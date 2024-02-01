import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//My dart files
import './registerPage.dart';
import './loginPage.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Leno Files",
                  style: GoogleFonts.acme(
                    textStyle: const TextStyle(
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.black
                    )
                  ),
                ),
                Image.asset(
                  "assets/images/mw1920_internalasset1-1.png",
                  width: 370,
                  height: 370,
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Text(
                    "A simple cloud storage app for you.",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const RegisterPage())
                      );
                    },
                    child: const Text("Create An Account")
                  )
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(
                      width: 1.0,
                      color: Colors.brown
                    ),
                    primary: Colors.white, // Background color
                    onPrimary: Colors.brown, // Text Color (Foreground color)
                  ),
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const LoginPage())
                    );
                  },
                  child: const Text("Login")
                )
              ]
            )
          )
        )
      )
    );
  }
}