import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//My Dart Files
import './home.dart';
import './editProfileNamePage.dart';
import './editProfileEmailPage.dart';
import './editProfilePasswordPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  late SharedPreferences _prefs; // to store the logged in token of the user

  late String loggedInUserToken; // the logged in user token from the server for the FutureBuilder

  late var userDetails; // the user details gotten from the server

  int _selectedIndex = 0; // the selected index/the tab selected in the bottom navigation

  // checks to see if the user is still logged in with 
  // the stored token on the server's db
  late Future<int> _checkIfUserTokenIsLoggedUserInt;

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
      //if(userDetails["user"].isEmpty || userDetails["user"] == null || userDetails["user"].length < 2) {
      if(userDetails["user"]["email"].isEmpty || userDetails["user"]["email"] == null || userDetails["user"]["email"] ==  "") {

        print("token expired and user should login");

        if (_prefs.getString("loggedInUserToken") != null) {
          await _prefs.clear(); //cleared the saved user login tokens on the app
          setState(() {});
        }

        // Redirect to Homepage for the user to login
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const Home())
        );
      }

      // If user is not logged in and the sent token does not exist
      // or has logged out before the expiry date and time
      // it returns "Unauthenticated." Its a laravel thing
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

      // Redirect the user back to the home page to go to
      // the login page from there to login
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const Home())
      );

    });

    return numberToReturn;
  }

  bool loggingOut = false; // changed when and when not the user is logging out

  var logoutMessage; // message to display for logout

  // Function to logout the user
  Future logout() async {

    setState(() {
      loggingOut = true; //to show the loading circular icon
    });
    
    var url = "http://lenofiles.uchemcolin.xyz/api/logout";

    /** The user's logged in token (saved on the app) and the headers to use */
    final token = loggedInUserToken;
    print("final token editUserProfileName: " + token);
    final headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    };

    var response = await http.post(
      Uri.parse(url),
      headers: headers//, 
      //body: jsonEncode(formSubmission)
    ).then((value) async {

      print("logout value");
      print(value);

      var response = value;

      print("response inside logout()");

      print(response.body);

      if(response.body.isNotEmpty) {
        var responseData = json.decode(response.body);
        
        setState(() {
          logoutMessage = responseData["message"];
        });

        print("logout message after server request");
        print(logoutMessage);

        print("response body after logout function");
        print(response.body);

        if(responseData["message"] == "Unauthenticated.") {

          setState(() {
            loggingOut = false;
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home())
          );
        }

        if(responseData["message"]["type"] == "success") {

          if (_prefs.getString("loggedInUserToken") != null) {
            await _prefs.clear(); //cleared the saved user login tokens on the app
            setState(() {});
          }
          
          setState(() {
            loggingOut = false;
          });

          // Redirect back to the homepage so the user can go to the Login page from that route
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => const Home())
          );

        } else {
          

          setState(() {
            loggingOut = false;
          });

          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "An error occured, please try again.",
                    style: TextStyle(
                      color: Colors.red
                    ),
                  )
                ]
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {

                    Navigator.pop(context);

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
          loggingOut = false;
        });

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "An error occured, please try again.",
                  style: TextStyle(
                    color: Colors.red
                  ),
                )
              ]
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {

                  Navigator.pop(context);

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
        loggingOut = false;
      });

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "An error occured, please try again.",
                style: TextStyle(
                  color: Colors.red
                ),
              )
            ]
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {

                Navigator.pop(context);

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
  initState() {
    super.initState();
    _checkIfUserTokenIsLoggedUserInt = _checkIfUserTokenIsLoggedUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _checkIfUserTokenIsLoggedUserInt,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                CircularProgressIndicator(
                  color: Color.fromARGB(255, 40, 155, 65)
                )
              ]
            )
          );

        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error')
            );
          } else if (snapshot.hasData) {

            // If retrieving the data from the server was successful
            if(snapshot.data == 2) {

              print("profile page user's details:");
              print(userDetails);
              print("user's first name");
              print(userDetails["user"]["firstname"]);

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10
                      ),
                      child: Text(
                        "Your Account",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.center,
                      )
                    ),
                    const Icon(
                      Icons.account_circle,
                      size: 80,
                    ),
                    ListTile(
                      //leading: Icon(Icons.sim_card),
                      title: Text(
                        userDetails["user"]["firstname"] + " " + userDetails["user"]["lastname"],
                        //textScaleFactor: 1.5,
                      ),
                      trailing: const Icon(Icons.edit),
                      subtitle: const Text('Name'),
                      //selected: true,
                      onTap: () {
                        //
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const EditProfileNamePage())
                        );
                      },
                    ),
                    ListTile(
                      //leading: Icon(Icons.sim_card),
                      title: Text(
                        userDetails["user"]["email"],
                        //textScaleFactor: 1.5,
                      ),
                      //trailing: Icon(Icons.arrow_right),
                      trailing: const Icon(Icons.edit),
                      subtitle: const Text('Email'),
                      //selected: true,
                      onTap: () {
                        //
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const EditProfileEmailPage())
                        );
                      },
                    ),
                    ListTile(
                      //leading: Icon(Icons.sim_card),
                      title: const Text(
                        "Change your password",
                        //textScaleFactor: 1.5,
                      ),
                      //trailing: Icon(Icons.arrow_right),
                      trailing: const Icon(Icons.edit),
                      subtitle: const Text('Password'),
                      //selected: true,
                      onTap: () {
                        //
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const EditProfilePasswordPage())
                        );
                      },
                    ),
                    Visibility(
                      visible: loggingOut,
                      child: const Padding(
                        padding: EdgeInsets.only(top: 2, bottom: 2),
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 40, 155, 65)
                        )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: TextButton.icon(
                        onPressed: () {

                          logout();
                        },
                        icon: const Icon( // <-- Icon
                          Icons.logout,
                          size: 24.0,
                        ),
                        label: const Text('Logout'), // <-- Text
                      )
                    )
                  ]
                )
              );
            } else {

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text("Please login")
                  ]
                )
              );

            }

          } else {

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text('Empty data')
                ]
              )
            );
            
          }
        } else {

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text('State Error! Please reload or re-login')
              ]
            )
          );

        }
      },
    );    
  }
}