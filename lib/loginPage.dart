import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

//My dart files
import './home.dart';
import './dashboard.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController; // controller for the email text field
  late final TextEditingController _passwordController; // controller for the password text field

  late var userDetails; // the user details gotten from the server

  late String userToken; // the logged in user token from the server after successful login

  int loginStatusInt = 0; // int to store if the user logged in successfully or not

  late String loginStatusErrorText; // message after login. Either successful or error

  // Function to login the user
  Future loginUser() async {

    setState(() {
      loginStatusInt = 4; //to show the loading circular icon
    });
    
    var url = "http://lenofiles.uchemcolin.xyz/api/login";

    // form fields to submit
    var formSubmission = {
      "email": _emailController.text,
      "password": _passwordController.text,
    };

    print(formSubmission);

    var response = await http.post(
      Uri.parse(url),
      body: formSubmission
    ).then((value) async {

      var response = value;

      if(response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        userDetails = responseData["user"];
        userToken = responseData["token"];

        print("Login User async function");
        print(formSubmission);
        print(response.body);

        if(responseData["type"] == "success") {
          loginStatusInt = 3;

          SharedPreferences prefs = await SharedPreferences.getInstance();
          // store the logged in user token in the shared preferences of the app for use 
          // throughout the app while it is still valid
          prefs.setString("loggedInUserToken", responseData["token"]);

          // Take the person to the dashboard after successfully logging in
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Dashboard())
          );

        } else {
          

          setState(() {
            loginStatusInt = 2;
            loginStatusErrorText = responseData["message"];
          });

          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    loginStatusErrorText,
                    style: const TextStyle(
                      color: Colors.red
                    ),
                  )
                ]
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {

                    setState(() {
                      loginStatusInt = 0;
                    });

                    Navigator.of(ctx).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    child: const Text("Ok"),
                  ),
                ),
              ],
            ),
          );
        }
      } else {

        setState(() {
          loginStatusInt = 1; 
          loginStatusErrorText = "An error occured, please try again";
        });

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loginStatusErrorText,
                  style: const TextStyle(
                    color: Colors.red
                  ),
                )
              ]
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {

                  setState(() {
                    loginStatusInt = 0;
                  });

                  Navigator.of(ctx).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  child: const Text("Ok"),
                ),
              ),
            ],
          ),
        );
      }  
    }).onError((error, stackTrace) {
      setState(() {
        loginStatusInt = 1; 
        loginStatusErrorText = "An error occured, please try again";
      });

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loginStatusErrorText,
                style: const TextStyle(
                  color: Colors.red
                ),
              )
            ]
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {

                setState(() {
                  loginStatusInt = 0;
                });

                Navigator.of(ctx).pop();
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                child: const Text("Ok"),
              ),
            ),
          ],
        ),
      );
    });

    print("loginStatusInt: " + loginStatusInt.toString());
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    loginStatusErrorText = "";
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    "Login to your Account",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      //hintText: "example@domain.com",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.black12, //<-- SEE HERE
                        ),
                      ),
                      filled: true, //<-- SEE HERE
                      fillColor: Color.fromARGB(255, 240, 240, 240), //<-- SEE HERE
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      bool emailValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value);

                      if (!emailValid) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Password',
                        //hintText: "example@domain.com",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.black12, //<-- SEE HERE
                          ),
                        ),
                        filled: true, //<-- SEE HERE
                        fillColor: Color.fromARGB(255, 240, 240, 240), //<-- SEE HERE
                      ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
                  child: Visibility(
                    child: const CircularProgressIndicator(
                      color: Color.fromARGB(255, 40, 155, 65)
                    ),
                    visible: loginStatusInt == 4, //meaning it has been clicked, content been retrievd from server
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {

                      loginUser(); // login the user if validation tests all passed
                      
                    }
                  },
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 15
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: TextButton.icon(
                    onPressed: () {

                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (context) => const Home())
                      );
                    },
                    icon: const Icon( // <-- Icon
                      Icons.arrow_back,
                      size: 24.0,
                    ),
                    label: const Text('Back'), // <-- Text
                  )
                )
              ],
            )
          ),
        ),
      ),
    );
  }
}