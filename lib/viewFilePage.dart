import 'package:flutter/material.dart';
import 'package:leno_files_app/dashboard.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:flowder/flowder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; //for the File class
import 'dart:io'; //for the File class
import 'dart:math'; //for the File class
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

//My dart files
import './home.dart';
import './loginPage.dart';

class ViewFilePage extends StatefulWidget {

  int fileId; // the file id to be passed from where it is instantiated

  //const ViewFilePage({Key? key}) : super(key: key);
  ViewFilePage(this.fileId);

  @override
  State<ViewFilePage> createState() => _ViewFilePageState();
}

class _ViewFilePageState extends State<ViewFilePage> {

  late int fileId; // the file id

  String fileName = ""; // the file name

  late SharedPreferences _prefs; // to access the stored user's log in info

  late String loggedInUserToken; // to store the user's login token

  late var userDetails; // to get the details of the user from the server

  late var fileDetails; // to get the details of the file

  late bool isUserFile; // to know if the user is the one who uploaded the file or not

  late var userFiles; // the user's files

  late Future<int> _getFileInt;

  bool deletingFile = false; // to check if the file is being deleted

  // Function to get the specific file's details
  Future<int> _getFile() async {

    late int numberToReturn;

    _prefs = await SharedPreferences.getInstance();
    if (_prefs.getString("loggedInUserToken") != null) {
      loggedInUserToken = _prefs.getString("loggedInUserToken")!; // get the logged in user's tokens
      setState(() {});
    } else {
      loggedInUserToken = "";
    }

    /** The user's logged in token (saved on the app) and the headers to use */
    final response;
    final token = loggedInUserToken;
    final headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    };

    String url = "http://lenofiles.uchemcolin.xyz/api/files/view_file/" + fileId.toString();
    response = await http.get(
      Uri.parse(url),
      headers: headers
    ).then((value) {

      var response = value;

      if(response.body.isEmpty) {
        fileDetails = [];
        isUserFile = false;

        setState(() {
          numberToReturn = 0;
        });

      } else {
        var fileResponseData = json.decode(response.body);

        fileDetails = fileResponseData;

        print("response data of file in files page:");
        print(fileResponseData);

        if(fileDetails.isEmpty) {

          fileDetails = [];

          isUserFile = false;

          setState(() {
            numberToReturn = 0;
          });

        } else {

          // If user is not logged in and the sent token does not exist
          // or has logged out before the expiry date and time
          // it returns "Unauthenticated." Its a laravel thing
          if(fileResponseData["message"] == "Unauthenticated.") {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => const Home())
            );
          }

          fileDetails = fileResponseData["file"];

          // check if it is the user that owns the file
          if(fileResponseData["message"] == "isUserFile") {
            isUserFile = true;
          } else {
            isUserFile = false;
          }

          setState(() {
            fileName = fileDetails["name"];
          });

          print("file details");
          print(fileDetails);

          setState(() {
            numberToReturn = 1;
          });
        }
      }
    }).onError((error, stackTrace) async {
      print("token expired and user should login from http error:");
      print(error);

      setState(() {
        numberToReturn = 0;
      });

      if (_prefs.getString("loggedInUserToken") != null) {
        await _prefs.clear(); //cleared the saved user login tokens on the app
        setState(() {});
      }

      // Redirect back to the home page so the user can go
      // to the login page by him or herself
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const Home())
      );
      
      //
    });

    return numberToReturn;
  }

  @override
  initState() {
    super.initState();

    setState(() {
      fileId = widget.fileId; // get the file id from where it is passed from where it is instantiated
    });

    _getFileInt = _getFile(); // get the file's details
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leno Files"),
      ),
      body: FutureBuilder<int>(
        future: _getFileInt,
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
              var snapErrToString = snapErr.toString();

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

              if(snapshot.data == 0) {

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
                        "File not found!",
                        style: TextStyle(
                          color: Colors.red
                        ),
                      ),
                      ElevatedButton(
                        child: const Text("Go Back"),
                        onPressed: () {
                          //Navigator.pop(context);

                          if(deletingFile == false) {
                            Navigator.pushReplacement(
                              context, 
                              MaterialPageRoute(builder: (context) => Dashboard(1))
                            );
                          }
                        }
                      ),
                    ]
                  )
                );

              } else if(snapshot.data == 1) {

                String fileName = fileDetails["name"];
                var fileSize = fileDetails["size"];
                String fileType = fileDetails["type"];
                
                var fileSizeRoundedToString = fileSize.toString();
                
                String otherInformation = "Type: " +  fileDetails["type"] + "\nSize: " +  fileSizeRoundedToString + "MB";

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.file_present_rounded,
                        color: Colors.black,
                        size: 50,
                      ),
                      Text(
                        "File Name: $fileName",
                        //"A",
                        style: const TextStyle(
                          fontSize: 17
                        ),
                        textAlign: TextAlign.center,
                        //softWrap: true
                      ),
                      Text(
                        "File Size: ${fileSizeRoundedToString}MB",
                        style: const TextStyle(
                          fontSize: 17
                        ),
                        textAlign: TextAlign.center
                      ),
                      Visibility(
                        visible: deletingFile,
                        child: const Padding(
                        padding: EdgeInsets.only(top: 3, bottom: 3),
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 40, 155, 65)
                          )
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.arrow_back
                          ),
                          label: const Text("Go Back"),
                          onPressed: () {

                            if(deletingFile == false) {
                              Navigator.pushReplacement(
                                context, 
                                MaterialPageRoute(builder: (context) => Dashboard(1))
                              );
                            }
                          }
                        ),
                      ),
                    ]
                  )
                );
              } else {
                
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Please re-login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.logout
                          ),
                          label: const Text("Logout"),
                          onPressed: () async {

                            if (_prefs.getString("loggedInUserToken") != null) {
                              await _prefs.clear(); //cleared the saved user login tokens on the app
                              setState(() {});
                            }

                            Navigator.pushReplacement(
                              context, 
                              MaterialPageRoute(builder: (context) => const Home())
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

                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => ViewFilePage(fileId))
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

                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => ViewFilePage(fileId))
                        );

                      }
                    ),
                  ),
                ]
              )
            );
          }
        },
      ),
      floatingActionButton: SpeedDial(
        child: const Icon(Icons.menu),
        //closedForegroundColor: Colors.black,
        closedForegroundColor: Colors.white,
        openForegroundColor: Colors.white,
        //closedBackgroundColor: Colors.white,
        closedBackgroundColor: const Color.fromARGB(255, 27, 122, 201),
        openBackgroundColor: Colors.black,
        //labelsStyle: /* Your label TextStyle goes here */,
        labelsBackgroundColor: Colors.white,
        //controller: /* Your custom animation controller goes here */,
        speedDialChildren: <SpeedDialChild>[
          
          SpeedDialChild(//first child, not meant for windows PC or macOS because the plugins do not work for them
            child: const Icon(Icons.download),
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255, 29, 90, 31),
            label: 'Download',
            onPressed: () async {
              
              //Get permission to device directory first
              var status = await Permission.storage.status;
              if (status.isDenied) {
                await Permission.storage.request();
              }

              String fileDownloadUrl = "http://lenofiles.uchemcolin.xyz/public/storage/files/" + fileName;

              print("http://lenofiles.uchemcolin.xyz/public/storage/files/" + fileName);

              //You can download a single file
              FileDownloader.downloadFile(
              //FileDownloader().downloadFile(
                url: fileDownloadUrl,
                //name: "THE FILE NAME AFTER DOWNLOADING",//(optional)
                onProgress: (String? fileName, double progress) {
                  print('FILE fileName HAS PROGRESS $progress');

                  //Show user file is downloading
                  var snackBar = SnackBar(
                    content: Text('Download Progress: ' + progress.toString()),
                  );

                  // Find the ScaffoldMessenger in the widget tree
                  // and use it to show a SnackBar.
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                onDownloadCompleted: (String path) {
                  print('FILE DOWNLOADED TO PATH: $path');

                  //Show user file is deleting
                  var snackBar = SnackBar(
                    content: Text('File downloaded to $path'),
                  );

                  // Find the ScaffoldMessenger in the widget tree
                  // and use it to show a SnackBar.
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                onDownloadError: (String error) {
                  print('DOWNLOAD ERROR: $error');

                  //Show user file is deleting
                  var snackBar = const SnackBar(
                    content: Text('There was an error downloading the file. Please try again.'),
                  );

                  // Find the ScaffoldMessenger in the widget tree
                  // and use it to show a SnackBar.
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              );
            },
            closeSpeedDialOnPressed: false,
          ),
          SpeedDialChild( //second child, not meant for windows PC or macOS because the plugins do not work for them
            child: const Icon(Icons.share),
            //foregroundColor: Colors.black,
            //backgroundColor: Colors.yellow,
            foregroundColor: Colors.white,
            backgroundColor: Color.fromARGB(255, 9, 53, 88),
            label: 'Share',
            onPressed: () async {

              String fileUrl = "http://lenofiles.uchemcolin.xyz/files/view_file/" + fileId.toString();

              await Share.share('Check out this file uploaded on Leno Files: $fileUrl');
            },
            closeSpeedDialOnPressed: false,
          ),
          SpeedDialChild( //third child
            
            child: const Icon(Icons.delete),
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
            label: 'Delete',
            onPressed: () async {
              if(isUserFile == true) {

                String textToDisplay = "Are you sure you want to delete the file (you can't undo it)?";

                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Visibility(
                          visible: deletingFile == false,
                          child: Text(
                            textToDisplay,
                            style: const TextStyle(
                              color: Colors.red
                            ),
                          )
                        ),
                        Visibility(
                          visible: deletingFile == true,
                          child: const CircularProgressIndicator(
                            color: Color.fromARGB(255, 40, 155, 65)
                          )
                        ),
                      ]
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {

                          if(deletingFile == false) {
                            Navigator.of(ctx).pop();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          child: const Text("Cancel"),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {

                          if(deletingFile == false) {
                            setState(() {
                              deletingFile = true;

                              Navigator.of(ctx).pop(); // close the box

                            });

                            //Show user file is deleting
                            const snackBar = SnackBar(
                              content: Text('File deleting...'),
                            );

                            // Find the ScaffoldMessenger in the widget tree
                            // and use it to show a SnackBar.
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);

                            setState(() {
                              textToDisplay = "File deleting...";
                            });

                            /** Delete file form the database */

                            final response;
                            final token = loggedInUserToken;
                            final headers = {
                              "Content-Type": "application/json",
                              'Authorization': 'Bearer $token',
                            };

                            String url = "http://lenofiles.uchemcolin.xyz/api/users/" + fileId.toString();

                            response = await http.delete(
                              Uri.parse(url),
                              headers: headers
                            ).then((value) {
                              //
                              var response = value;
                              
                              if(response.body.isEmpty) {
                              
                                setState(() {
                                  //
                                  deletingFile = false;
                                  textToDisplay = "An error has occured! Please try again."; //not reflecting on alert, will investigate why later on

                                });

                                //Show error in deleting file
                                const snackBar = SnackBar(
                                  content: Text('An error has occured! Please try again.'),
                                );

                                // Find the ScaffoldMessenger in the widget tree
                                // and use it to show a SnackBar.
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);

                              } else {
                                var deleteFileResponseData = json.decode(response.body);

                                var deleteFileResponseDetails = deleteFileResponseData;

                                print("response data of file delted in view files page:");
                                print(deleteFileResponseDetails);

                                if(deleteFileResponseDetails.isEmpty) {

                                  setState(() {
                                    //

                                    deletingFile = false;
                                    textToDisplay = "An error has occured! Please try again.";

                                  });

                                  //Show error in deleting file
                                  const snackBar = SnackBar(
                                    content: Text('An error has occured! Please try again.'),
                                  );

                                  // Find the ScaffoldMessenger in the widget tree
                                  // and use it to show a SnackBar.
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);

                                } else {

                                  // If user is not logged in and the sent token does not exist
                                  // or has logged out before the expiry date and time
                                  // it returns "Unauthenticated." Its a laravel thing
                                  if(deleteFileResponseDetails["message"] == "Unauthenticated.") {

                                    setState(() {
                                      deletingFile = false;
                                      textToDisplay = "";
                                    });

                                    //Go back to Login page for the person to login
                                    //since the user is not logged in or session has expired
                                    Navigator.pushReplacement(
                                      context, 
                                      //MaterialPageRoute(builder: (context) => Dashboard(1))
                                      MaterialPageRoute(builder: (context) => const LoginPage())
                                    );

                                  } else {

                                    if(deleteFileResponseDetails["message"]["type"] == "success") {

                                      //Go back to manageFiles
                                      Navigator.pushReplacement(
                                        context, 
                                        MaterialPageRoute(builder: (context) => Dashboard(1))
                                      );

                                    } else {

                                      setState(() {
                                        //
                                        deletingFile = false;
                                        textToDisplay = deleteFileResponseDetails["message"]["text"];
                                      });
                                    }
                                  }
                                }
                              }
                            }).onError((error, stackTrace) {
                              setState(() {

                                print("deleting onError");
                                print(error);
                                //
                                deletingFile = false;
                                textToDisplay = error.toString();

                                //Show error in deleting file
                                const snackBar = SnackBar(
                                  content: Text('An error has occured! Please try again.'),
                                );

                                // Find the ScaffoldMessenger in the widget tree
                                // and use it to show a SnackBar.
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              });
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          child: const Text("Yes"),
                        ),
                      ),
                    ],
                  ),
                );

              } else {
                //
                return null;
              }
            },
          ),
          //  Your other SpeedDialChildren go here.        
        ],
      ),
    );   
  }
}
