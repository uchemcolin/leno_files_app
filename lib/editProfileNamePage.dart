import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

//My dart files
import './home.dart';
import './dashboard.dart';

class EditProfileNamePage extends StatefulWidget {

  const EditProfileNamePage({Key? key}) : super(key: key);

  @override
  State<EditProfileNamePage> createState() => _EditProfileNamePageState();
}

class _EditProfileNamePageState extends State<EditProfileNamePage> {

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController; // controller for the first name text field
  late final TextEditingController _lastNameController; // controller for the last name text field

  late var userDetails; // the details of the user from the server's db

  late String userToken; // the logged in user token stored on the app

  int editProfileStatusInt = 0; // to store the status after the attempt to update the user's email. If it is successful or failed

  String editProfileStatusErrorText = ""; // the error text from attempting to update the user's email

  // checks to see if the user is still logged in with 
  // the stored token on the server's db
  late Future<int> _checkIfUserTokenIsLoggedUserInt;

  // checks to see if the user is still logged in with 
  // the stored token on the server's db
  late SharedPreferences _prefs;

  late String loggedInUserToken; // the logged in user token from the server for the FutureBuilder

  // checks to see if the user is still logged in with 
  // the stored token on the server's db
  Future<int> _checkIfUserTokenIsLoggedUser() async {
    
    late int numberToReturn; // the number to return from this function

    _prefs = await SharedPreferences.getInstance(); // get the shared preferences data stored in the device
    if (_prefs.getString("loggedInUserToken") != null) {
      loggedInUserToken = _prefs.getString("loggedInUserToken")!;
      setState(() {});

    } else {
      loggedInUserToken = "";

      setState(() {
        numberToReturn = 0;
      });
    }

    /** The user's logged in token (saved on the app) and the headers to use */
    final token = loggedInUserToken;
    final headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    };

    print("loggedInUserToken: " + loggedInUserToken);

    String url = "http://lenofiles.uchemcolin.xyz/api/users/profile";
    final response = await http.get(
      Uri.parse(url),
      headers: headers
    ).then((value) async {

      var response = value;

      print("response");
      print(response.body);

      if(response.body.isEmpty) {
        userDetails = [];

        setState(() {
          numberToReturn = 1;
        });

      } 
        
      var responseData = json.decode(response.body);

      userDetails = responseData;

      print("user's email:");
      print(userDetails["user"]["email"]);
      //Check if the message is not unauthenticated or success
      //meaning the user logged in on the app, but the login token
      //has probably expired on the database,
      //redirect to the login page so the user can login again and get a new token
      if(userDetails["user"]["email"].isEmpty || userDetails["user"]["email"] == null || userDetails["user"]["email"] ==  "") {

        print("token expired and user should login");

        if (_prefs.getString("loggedInUserToken") != null) {
          await _prefs.clear(); //cleared the saved user login tokens on the app
          setState(() {});
        }

        // Redirect back to homepage for user to navigate to login page
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const Home())
        );
      }

      // If user is not logged in and the sent token does not exist
      // or has logged out before the expiry date and time
      // it returns "Unauthenticated."
      if(userDetails.isEmpty || userDetails["message"] == "Unauthenticated.") {

        userDetails = [];

        setState(() {
          numberToReturn = 1;
        });

      }

      userDetails = responseData;

      print("userDetails responseData:");
      print(userDetails);

      setState(() {
        _firstNameController.text = userDetails["user"]["firstname"];
        _lastNameController.text = userDetails["user"]["lastname"];
        numberToReturn = 2;
      });

    }).onError((error, stackTrace) async {

      /** Login most likely expired expired and user should re-login */
      print("token expired and user should login from http error:");
      print(error);

      setState(() {
        numberToReturn = 1;
      });

      if (_prefs.getString("loggedInUserToken") != null) {
        await _prefs.clear(); //cleared the saved user login tokens on the app
        setState(() {});
      }

      // Redirect back to homepage for user to navigate to login page
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const Home())
      );

    });

    return numberToReturn;
  }

  // Function to edit the user's name
  Future editUserProfileName() async {

    setState(() {
      editProfileStatusInt = 4; //to show the loading circular icon
    });
    
    var url = "http://lenofiles.uchemcolin.xyz/api/users/update_profile_name";

    // the logged in user's token
    final token = loggedInUserToken;
    print("final token editUserProfileName: " + token);
    // the headers to use to run the api call
    final headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    };

    // form fields to submit
    var formSubmission = {
      "firstname": _firstNameController.text,
      "lastname": _lastNameController.text,
    };

    print("form submission");

    print(formSubmission);

    var response = await http.post(
      Uri.parse(url),
      headers: headers, 
      body: jsonEncode(formSubmission)
    ).then((value) async {

      print("editUserProfileName() value");
      print(value);

      var response = value;

      print("response inside editUserProfileName()");

      print(response.body);

      if(response.body.isNotEmpty) {
        var responseData = json.decode(response.body);

        userDetails = responseData["user"];

        print("user details after successful name update:");
        print(userDetails);

        print("edit User Profile Name async function");
        print(formSubmission);
        print(response.body);

        if(responseData["message"]["type"] == "success") {
          editProfileStatusInt = 3;

          // If the email was successfully updated,
          // return back to the Dashboard page
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => Dashboard(2))
          );

        } else {
          
          setState(() {
            editProfileStatusInt = 2;
            editProfileStatusErrorText = responseData["message"]["text"];
          });

          setState(() {
            editProfileStatusInt = 0;
          });

          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    editProfileStatusErrorText,
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
                      editProfileStatusInt = 0;
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
          editProfileStatusInt = 1; 
          editProfileStatusErrorText = "An error occured, please try again";
        });

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  editProfileStatusErrorText,
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
                    editProfileStatusInt = 0;
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

      /** Login most likely expired expired and user should re-login */
      print("onError: ");

      print(error);

      setState(() {
        editProfileStatusInt = 1;
        editProfileStatusErrorText = "An error occured, please try again";
      });

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                editProfileStatusErrorText,
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
                  editProfileStatusInt = 0;
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
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();

    // check server for it the user is logged in
    _checkIfUserTokenIsLoggedUserInt = _checkIfUserTokenIsLoggedUser();
    
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leno Files'),
      ),
      body: FutureBuilder<int>(
        future: _checkIfUserTokenIsLoggedUserInt,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 40, 155, 65)
              )
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              print("snapshot error: ");
              print(snapshot.error);

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red,
                      size: 50,
                    ),
                    const Text(
                      "An error occured! Please reload.",
                      style: TextStyle(
                        color: Colors.red
                      ),
                    ),
                    ElevatedButton(
                      child: const Text("Reload"),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (context) => const EditProfileNamePage())
                        );
                      }
                    ),
                  ]
                )
              );
            } else if (snapshot.hasData) {

              if(snapshot.data == 2) {

                // if the retrieval of the user's details info was successful
                // show the update name form

                return Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text(
                            "Edit your Name",
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
                              //hintText: "John",
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

                              if (value.length < 3 || value.length > 30) {
                                return 'Please the first name must be between 3 to 30 characters long';
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
                              //hintText: "Doe",
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

                              if (value.length < 3 || value.length > 30) {
                                return 'Please the last name must be between 3 to 30 characters long';
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
                            visible: editProfileStatusInt == 4, //meaning it has been clicked, content been retrievd from server
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {

                              editUserProfileName(); // update the user's name via the function

                            }
                          },
                          child: const Text(
                            'Update',
                            style: TextStyle(
                              fontSize: 15
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: TextButton.icon(
                            onPressed: () {

                              // Go back to the profile page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => Dashboard(2))
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
                );
              } else {

                return const Text("Please login");
              }
              
            } else {
              return const Text('Empty data');
            }

          } else {
            return Text('State: ${snapshot.connectionState}');
          }
        },
      )
    );
  }
}