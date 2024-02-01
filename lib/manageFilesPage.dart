import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; //for the File class
import 'dart:io'; //for the File class
import 'dart:math';

//My dart files
import './home.dart';
import './viewFilePage.dart';
import './dashboard.dart';

class ManageFilesPage extends StatefulWidget {
  
  const ManageFilesPage({Key? key}) : super(key: key);

  @override
  State<ManageFilesPage> createState() => _ManageFilesPageState();
}

class _ManageFilesPageState extends State<ManageFilesPage> {

  var userSearchFiles; // if the user searched for files, this variables stores the returned files from the server

  late SharedPreferences _prefs; // to store the logged in token of the use

  late String loggedInUserToken; // the logged in user token from the server for the FutureBuilder

  late var userDetails; // the user details gotten from the server

  late var userFiles; // the logged in user's files

  late Future<int> _getLoggedInUserFilesIntInt; // Function to get the user's files

  // Function to get the user's files
  Future<int> _getLoggedInUserFilesInt() async {

    late int numberToReturn; // the number to return from this function

    // This was meant to be for in case
    // search files are passed to this page or route
    if(userSearchFiles?.isEmpty ?? true) {
      
      //
      _prefs = await SharedPreferences.getInstance(); // get the shared preferences data stored in the device
      if (_prefs.getString("loggedInUserToken") != null) {
        loggedInUserToken = _prefs.getString("loggedInUserToken")!;
        setState(() {});
      } else {
        loggedInUserToken = "";
      }

      if(loggedInUserToken == null || loggedInUserToken =="") {

        setState(() {
          numberToReturn = 0;
        });
        
      } else {

        /** The user's logged in token (saved on the app) and the headers to use */
        final token = loggedInUserToken;
        final headers = {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        };

        String url = "http://lenofiles.uchemcolin.xyz/api/users/files";
        final response = await http.post(
          Uri.parse(url),
          headers: headers
        ).then((value) {

          var response = value;
          
          if(response.body.isEmpty) {
            userDetails = [];

            setState(() {
              numberToReturn = 1;
            });

          } else {
            var responseData = json.decode(response.body);

            userDetails = responseData;

            print("response data in manage files page:");
            print(responseData);

            // If user is not logged in and the sent token does not exist
            // or has logged out before the expiry date and time
            // it returns "Unauthenticated." Its a laravel thing
            if(userDetails.isEmpty || userDetails["message"] == "Unauthenticated.") {

              userDetails = [];

              setState(() {
                numberToReturn = 1;
              });

            } else {

              if(responseData["files"].isEmpty == true || responseData["files"] == null) {
                setState(() {
                  userFiles = [];
                });

                print("file index 0");
                print(userFiles);

                setState(() {
                  numberToReturn = 1;
                });

              } else {
                setState(() {
                  userFiles = responseData["files"];
                });

                print("file index 0");
                print(userFiles[0]["name"]);

                setState(() {
                  numberToReturn = 2;
                });
              }
            }
          }

          return numberToReturn;

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

          return numberToReturn;

        });
      }
    } else {

      // This was meant to be for in case
      // search files are passed to this page or route
      userFiles = userSearchFiles;

      // This was meant to be for in case
      // search files are passed to this page or route
      if(userFiles == [] || userFiles.isEmpty) {

        setState(() {
          numberToReturn = 1;
        });

        return numberToReturn;

      } else {
        //
        print("search file index 0");
        print(userFiles[0]["name"]);

        setState(() {
          numberToReturn = 2;
        });
      }

      return numberToReturn;
    }

    return numberToReturn;
  }

  @override
  initState() {
    super.initState();

    // Get the user's files
    _getLoggedInUserFilesIntInt = _getLoggedInUserFilesInt();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<int>(
      future: _getLoggedInUserFilesIntInt,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {

          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 40, 155, 65)
            ),
          );

        } else if (snapshot.connectionState == ConnectionState.done) {

          if (snapshot.hasError) {
            print("snapshot error");
            print(snapshot.error);

            var snapErr = snapshot.error;
            var snapErrToString = snapErr.toString(); // to store the snapshot error

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    snapErrToString,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.refresh
                      ),
                      label: const Text("Reload"),
                      onPressed: () {

                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (context) => Dashboard(1))
                        );

                      }
                    ),
                  ),
                ]
              )
            );

          } else if (snapshot.hasData) {

            if(snapshot.data == 2) {

                // if the retrieval of the user's files were successful
                // show the user's files

                return ListView.separated(
                  //shrinkWrap: false,
                  itemCount: userFiles.length,
                  itemBuilder: (BuildContext context, int index) {

                    //String other_infomation = "Type: " +  userFilesToDisplay[index]["type"] + " | Size: " +  roundDouble(userFilesToDisplay[index]["size"], 5);
                    //String otherInformation = "Type: " +  userFiles[index]["type"];
                    int fileId = userFiles[index]["id"];
                    var fileSize = userFiles[index]["size"];
                    //double fileSize = userFiles[index]["size"];
                    var fileSizeRoundedToString = fileSize.toString();
                    //double fileSize_rounded = double.parse((fileSize).toStringAsFixed(5));
                    //var fileSizeRoundedToString = fileSize_rounded.toString();
                    //var fileSizeRoundedToString = fileSize_rounded.toString();
                    //var fileSizeRoundedToString = fileSize.toStringAsFixed(5);
                    //var fileSizeToString = fileSize.toString();
                    //var fileSizeRoundedToString = fileSizeToString.toStringAsFixed(5);
                    //double fileSize_rounded = double.parse(fileSize.toStringAsFixed(3)); //3 is decimal length 07034243326
                    //var fileSizeRoundedToString = fileSize.toStringAsFixed(5);
                    //String otherInformation = "Type: " +  userFiles[index]["type"] + " | Size: " +  userFiles[index]["size"];
                    //String otherInformation = "Type: " +  userFiles[index]["type"] + "\nSize: " +  fileSizeRoundedToString + "MB";
                    String otherInformation = "Size: " +  fileSizeRoundedToString + "MB";

                    return ListTile(
                      onTap: () {
                        print('Clicked on item #$index'); // Print to console

                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => ViewFilePage(fileId))
                        );
                      },
                      title: Text(
                        userFiles[index]["name"],
                        //overflow: TextOverflow.ellipsis, // ellipsis shows 3 dots if text is too long
                      ),
                      //subtitle: Text('Sample subtitle for item #$index'),
                      subtitle: Text(otherInformation),
                      /*leading: Container(
                        height: 50,
                        width: 50,
                        color: Colors.amber,
                      ),*/
                      leading: const Icon(Icons.file_present),
                      //trailing: const Icon(Icons.edit),
                      //trailing: const Icon(Icons.more_vert),
                      /*trailing: TextButton(
                        onPressed: () {
                          //
                        },
                        child: const Icon(Icons.more_vert)
                      ),*/
                      trailing: const Icon(Icons.arrow_right)
                    );
                  }, separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  },
                );
            } else {

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "You currently have no files",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.refresh
                        ),
                        label: const Text("Reload"),
                        onPressed: () {

                          // Refresh the manage files page
                          Navigator.pushReplacement(
                            context, 
                            MaterialPageRoute(builder: (context) => Dashboard(1))
                          );

                        }
                      ),
                    ),
                  ]
                )
              );
            }
          } else {

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Empty data",
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.refresh
                      ),
                      label: const Text("Reload"),
                      onPressed: () {

                        // Refresh the manage files page
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (context) => Dashboard(1))
                        );

                      }
                    ),
                  ),
                ]
              )
            );
          }
        } else {

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "State Error: ${snapshot.connectionState}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.refresh
                    ),
                    label: const Text("Reload"),
                    onPressed: () {

                      // Refresh the manage files page
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (context) => Dashboard(1))
                      );

                    }
                  ),
                ),
              ]
            )
          );
        }
      },
    );
  }
}