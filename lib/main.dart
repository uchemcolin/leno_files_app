import 'package:flutter/material.dart';

//The spalshscreen dart file
import './splashScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        //primarySwatch: Colors.blue,
        
        //primaryColor: Colors.brown[600]
        //primarySwatch: Color.fromRGBO(26, 188, 156, 1)
        primaryColor: const Color.fromARGB(255, 40, 155, 65),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 31, 31, 31)
          //color: Colors.white
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            //backgroundColor: Colors.black, // background (button) color
            //foregroundColor: Colors.white, // foreground (text) Color
            //primary: Color.fromARGB(255, 17, 71, 18)
            primary: const Color.fromARGB(255, 40, 155, 65)
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            //backgroundColor: Colors.black, // background (button) color
            //foregroundColor: Colors.white, // foreground (text) Color
            //primary: Color.fromARGB(255, 17, 71, 18)
            //primary: Color.fromARGB(255, 40, 155, 65)
            primary: Colors.brown
          ),
        )
      ),
      home: MySplashScreenPage(),
    );
  }
}