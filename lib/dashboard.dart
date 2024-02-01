import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//My dart files
import './home.dart';
import './indexPage.dart';
import './profilePage.dart';
import './manageFilesPage.dart';
import './searchManageFilesPage.dart';
import './aboutPage.dart';

class Dashboard extends StatefulWidget {

  late int passedSelectedIndex; // the selected index for the bottom navigation tabs (if a selected tab is passed)

  Dashboard([int passedSelectedIndexInConstructor = 0]) {
    passedSelectedIndex = passedSelectedIndexInConstructor;
  }

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  late SharedPreferences _prefs; // to store the logged in token of the user

  late String loggedInUserToken; // the logged in user token from the server for the FutureBuilder

  late var userDetails; // the user details gotten from the server

  var userSearchFiles = []; // if the user searched for files, this variables stores the returned files from the server
  
  late var userSearchFilesDetails; // if the user desides to search for files, store the files returned from the server here

  int _selectedIndex = 0; // the selected index/the tab selected in the bottom navigation

  // checks to see if the user is still logged in with 
  // the stored token on the server's db
  late Future<int> _checkIfUserTokenIsLoggedUserInt;

  int userLoggedIn = 0; // stored the returned number from checking if the user is still logged in

  bool _searchBoolean = false; // once the user clicks on the search button, it shows the search text bar

  bool searching = false; // to check if the server is searching for a file with the query

  bool doneSearching = false; // if the app is done searching

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
          userLoggedIn = 1;
        });

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
          await _prefs.clear(); //cleared the saved user login tokens on the app (means ost likely token has expired from the server and user should re-login)
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
          userLoggedIn = 1;
        });

        setState(() {
          numberToReturn = 1;
        });
      }

      userDetails = responseData;

      print("userDetails responseData:");
      print(userDetails);

      setState(() {
        userLoggedIn = 2;
      });

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

      // Redirect back to homepage for user to navigate to login page
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const Home())
      );

    });

    return numberToReturn;
  }

  var searchText = "";
  Widget _searchTextField() {
    return TextField(
      autofocus: true, //Display the keyboard when TextField is displayed
      cursorColor: Colors.white,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      textInputAction: TextInputAction.search, //Specify the action button on the keyboard
      decoration: const InputDecoration( //Style of TextField
        enabledBorder: UnderlineInputBorder( //Default TextField border
          borderSide: BorderSide(color: Colors.white)
        ),
        focusedBorder: UnderlineInputBorder( //Borders when a TextField is in focus
          borderSide: BorderSide(color: Colors.white)
        ),
        hintText: 'Search', //Text that is displayed when nothing is entered.
        hintStyle: TextStyle( //Style of hintText
          color: Colors.white60,
          fontSize: 20,
        ),
      ),
      onChanged: (String s) {
        setState(() {
          searchText = s;
        });
      },
      onSubmitted: (String str) async {
        setState((){

          searchText = str;

          searching = true;

          doneSearching = false;
        });

        /** The user's logged in token (saved on the app) and the headers to use */
        final token = loggedInUserToken;
        final headers = {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        };

        var formSubmission = {
          "search": searchText
        };

        String url = "http://lenofiles.uchemcolin.xyz/api/users/files";
        final response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(formSubmission)
        );

        if(response.body.isEmpty) {

          setState(() {
            userSearchFiles = [];

            searching = false;

            doneSearching = true;
          });

        } else {

          var responseData = json.decode(response.body);

          userSearchFilesDetails = responseData;

          print("response data in search manage files page/function:");
          print(responseData);

          // If user is not logged in and the sent token does not exist
          // or has logged out before the expiry date and time
          // it returns "Unauthenticated."
          if(userSearchFilesDetails.isEmpty || userSearchFilesDetails["message"] == "Unauthenticated.") {

            setState(() {
              //
              userSearchFiles = [];

              searching = false;

              doneSearching = true;

            });
            
          } else {

            setState(() {
              userSearchFiles = responseData["files"];

              searching = false;

              doneSearching = true;

            });

            print("search file index 0");
            print(userSearchFiles[0]["name"]);

          }
        }
      }
    );
  }

  @override
  initState() {
    super.initState();

    // set the selected index to the onde passed from server
    // it is zero if no one was passed
    _selectedIndex = widget.passedSelectedIndex;

    // check server for it the user is logged in
    _checkIfUserTokenIsLoggedUserInt = _checkIfUserTokenIsLoggedUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !_searchBoolean ? const Text("Leno Files") : _searchTextField(),
        actions: 
          !_searchBoolean ? 
          [
            Visibility(
              visible: _selectedIndex == 1,
              child: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _searchBoolean = true;
                  });
                }
              )
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              //tooltip: 'Refresh',
              onPressed: () {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (context) => Dashboard())
                );
              },
            ), //IconButton
            IconButton(
              icon: const Icon(Icons.info_outline),
              //tooltip: 'Info',
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const AboutPage())
                );
              },
            )
          ] 
          :
          [
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchBoolean = false;
                  searchText = "";
                });
              }
            ),
          ],
      ),
      body: FutureBuilder<int>(
        future: _checkIfUserTokenIsLoggedUserInt,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {

            // to see if you should be allowed to reload the page if there was an error
            bool reloadPage = false;

            Future.delayed(const Duration(milliseconds: 2000), () {

              // The option to reload page if after two seconds the
              // app did not return the needed results and display them

              setState(() {

                reloadPage = true;
              });

            });

            if(reloadPage == false) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 40, 155, 65)
                )
              );
            } else {
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
                          MaterialPageRoute(builder: (context) => Dashboard())
                        );
                      }
                    ),
                  ]
                )
              );
            }

            
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {

              print(snapshot.error);

              var errorText = snapshot.error.toString(); // the error text stored

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
                          MaterialPageRoute(builder: (context) => Dashboard())
                        );
                      }
                    ),
                  ]
                )
              );
            } else if (snapshot.hasData) {

              if(snapshot.data == 2) {

                if(_selectedIndex == 2) {

                  return const ProfilePage();

                } else if(_selectedIndex == 1) {
                  //

                  print("User search files:");
                  print(userSearchFiles);

                  if(_searchBoolean == true && searching == true && doneSearching == false) {
                    // if file search from server is going on
                    // but it is not completed
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 40, 155, 65)
                      )
                    );
                  } else if(_searchBoolean == true && searching == true && doneSearching == true) {
                    // if file search from server is going on
                    // but it is completed
                    return SearchManageFilesPage(userSearchFiles);
                  } else if(_searchBoolean == true && searching == false && doneSearching == true) {
                    // if file search from server is done
                    // and the user is still in search mode
                    return SearchManageFilesPage(userSearchFiles);

                  } else if(_searchBoolean == false && searching == false && doneSearching == false) {
                    // if the user is not trying to search anything
                    // load all the user's files and display them in descending order
                    return const ManageFilesPage();

                  } else {
                    // Display the user's files in descending order from the server
                    return const ManageFilesPage();
                  }
                  
                } else {

                  return const IndexPage();

                }

              } else {

                return const Center(
                  child: Text("Please login")
                );
              }

            } else {

              return Center(
                child: Column(
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
                          MaterialPageRoute(builder: (context) => Dashboard())
                        );
                      }
                    ),
                  ]
                )
              );
            }
          } else {

            return Center(
              child: Column(
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
                        MaterialPageRoute(builder: (context) => Dashboard())
                      );
                    }
                  ),
                ]
              )
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.brown,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_present_outlined),
            label: 'Manage Files',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Me',
          ),
        ],
        currentIndex: _selectedIndex, //New
        onTap: _onItemTapped,
      ),
    );
  }

  // Function that sets the selected index
  // once the bottom navigation is clicked
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}