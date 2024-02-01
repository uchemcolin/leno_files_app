import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

//My dart files
import './home.dart';
import './dashboard.dart';

class RegisterPage extends StatefulWidget {

  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _formKey = GlobalKey<FormState>(); // the form key

  late final TextEditingController _emailController; // controller for the email text field
  late final TextEditingController _passwordController; // controller for the password text field
  late final TextEditingController _passwordConfirmationController; // controller for the password confirmation text field
  late final TextEditingController _firstNameController; // controller for the first name text field
  late final TextEditingController _lastNameController; // controller for the last text field

  late var userDetails; // to store the newly created user's account details

  late String userToken; // to store the token from the server after successful creation of an account

  int registerStatusInt = 0; // store the status of the registration

  late String registerStatusErrorText; // the message to store after trying to create the new user

  // Function to register the new user
  Future registerUser() async {

    setState(() {
      registerStatusInt = 4; //to show the loading circular icon
    });
    
    var url = "http://lenofiles.uchemcolin.xyz/api/register";
  
    // The form fields to submit to the server
    var formSubmission = {
      "firstname": _firstNameController.text,
      "lastname": _lastNameController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
      "password_confirmation": _passwordConfirmationController.text,
    };

    print(formSubmission);

    var response = await http.post(
      Uri.parse(url),
      //headers: headers, 
      body: formSubmission
      //body: jsonEncode(formSubmission)
    ).then((value) async {

      var response = value;
      
      print(response.body);

      if(response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        userDetails = responseData["user"];
        userToken = responseData["message"]["token"];

        print("Register User async function");
        print(formSubmission);
        print(response.body);

        if(responseData["message"]["type"] == "success") {
          registerStatusInt = 3;

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("loggedInUserToken", responseData["message"]["token"]); // store the user's token on the device

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Dashboard())
          );
        } else {
          

          setState(() {
            registerStatusInt = 2;
            registerStatusErrorText = responseData["message"]["text"];
          });
        }
      } else {

        setState(() {
          registerStatusInt = 1; 
          registerStatusErrorText = "An error occured, please try again.";
        });

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  registerStatusErrorText,
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
                    registerStatusInt = 0;
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

      print("Registration Error: ");

      print(error.toString());

      setState(() {
        registerStatusInt = 1; 
        registerStatusErrorText = "An error occured, please try again.";
      });

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                registerStatusErrorText,
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
                  registerStatusInt = 0;
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

  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordConfirmationController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
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
                    "Create an Account",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
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
                      
                      return null;
                    },
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
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

                      return null;
                    },
                  )
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
                  child: TextFormField(
                    controller: _passwordConfirmationController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Confirm Password',
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
                      if (!(value == _passwordController.text)) {
                        return "Passwords do not match";
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
                    visible: registerStatusInt == 4, //meaning it has been clicked, content been retrievd from server
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {

                      registerUser();
                      
                    }
                  },
                  child: const Text(
                    'Sign Up',
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