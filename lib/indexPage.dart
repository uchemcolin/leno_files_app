import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart'; //for the File class
import 'dart:async'; //for the File class
import 'dart:io'; //for the File class

//My dart files
import './home.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {

  late SharedPreferences _prefs; // to store the logged in token of the user

  late String loggedInUserToken; // the logged in user token from the server for the FutureBuilder

  late var userDetails; // the user details gotten from the server
  
  String uploadFileStatusErrorText = ""; // message from trying to upload a file, whether good or bad

  int uploadFileIntForChecks = 0; // int to store the outcome from trying to upload a file

  bool fileCurrentlyUploading = false; // to determine if the file is currently uploading or not

  // Function to upload the file to the server
  Future<int> _uploadFile(File file) async {

    late int numberToReturn; // int to return from outcome of trying to upload the file
    
    setState(() {
      fileCurrentlyUploading = true;
    });
    
    _prefs = await SharedPreferences.getInstance(); // get the shared preferences data stored in the device
    if (_prefs.getString("loggedInUserToken") != null) {
      loggedInUserToken = _prefs.getString("loggedInUserToken")!;
      setState(() {});
    } else {
      loggedInUserToken = "";
    }

    if(loggedInUserToken == null || loggedInUserToken == "") {

      setState(() {
        fileCurrentlyUploading = false;
        uploadFileIntForChecks = 0;
      });

      return 0;
    } else {

      /** The user's logged in token (saved on the app) and the headers to use */
      final token = loggedInUserToken;
      final headers = {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      };

      var request = http.MultipartRequest("POST", Uri.parse("http://lenofiles.uchemcolin.xyz/api/users/upload_file"));

      request.headers.addAll(headers);
      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          File(file.path).readAsBytesSync(),
          filename: file.path
        )
      );

      var streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse).then((value) {
        //

        var response = value;

        var responseData = jsonDecode(response.body) as Map<String, dynamic>;

        print("file upload response data:");
        print(responseData);

        // If user is not logged in and the sent token does not exist
        // or has logged out before the expiry date and time
        // it returns "Unauthenticated." Its a laravel thing
        if(responseData["message"] == "Unauthenticated.") {

          setState(() {
            fileCurrentlyUploading = false;
            uploadFileIntForChecks = 1; //user needs to login
          });

          setState(() {
            numberToReturn = 1;
          });

        } else if(responseData["message"]["type"] == "error") {

          setState(() {
            fileCurrentlyUploading = false;
            uploadFileIntForChecks = 2;
          });

          setState(() {
            numberToReturn = 2;
          });

        } else if(responseData["message"]["type"] == "success") {

          setState(() {
            fileCurrentlyUploading = false;
            uploadFileIntForChecks = 3;
          });

          setState(() {
            numberToReturn = 3;
          });

        } else {

          setState(() {
            fileCurrentlyUploading = false;
            uploadFileIntForChecks = 0;
          });

          setState(() {
            numberToReturn = 0;
          });
        }
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
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.file_upload_outlined,
            size: 50,
            //color: Colors.green,
          ),
          Visibility(
            visible: fileCurrentlyUploading == true,
            child: const Padding(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 40, 155, 65)
              )
            )
          ),
          ElevatedButton(
            child: const Text("Upload File (2MB Max)"),
            onPressed: () async {

              FilePickerResult? result;

              result = await FilePicker.platform.pickFiles(
                allowMultiple: false,
                //type: FileType.custom
              );
              if (result == null) {
                print("No file selected");
              } else {
                setState(() {});

                var filePath = result.files.single.path;

                var filePathToString = filePath.toString();

                File file = File(filePathToString);

                /** Remember to include the max file size upload limit check 
                 * Although the server already does it
                */

                _uploadFile(file).then((value) {
                  
                    if(value == 3) {
                      setState(() {
                        uploadFileStatusErrorText = "File uploaded successfully!";
                      });

                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                uploadFileStatusErrorText,
                                style: const TextStyle(
                                  color: Colors.green
                                ),
                              )
                            ]
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {

                                setState(() {
                                  if(fileCurrentlyUploading == true) {
                                    fileCurrentlyUploading = false;
                                  }
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

                    } else if(value == 2) {
                      
                      setState(() {
                        uploadFileStatusErrorText = "There was an error. Please login again to continue";
                      });

                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                uploadFileStatusErrorText,
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
                                  if(fileCurrentlyUploading == true) {
                                    fileCurrentlyUploading = false;
                                  }
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

                    } else if (value == 1) {
                      //Unauthenticated. Needs to login/relogin
                      
                      setState(() {
                        uploadFileStatusErrorText = "Session expired! Please login again to continue";
                      });

                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                uploadFileStatusErrorText,
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
                                  if(fileCurrentlyUploading == true) {
                                    fileCurrentlyUploading = false;
                                  }
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

                    } else {
                      
                      setState(() {
                        uploadFileStatusErrorText = "There was an error. Please login again to continue";
                      });

                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                uploadFileStatusErrorText,
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
                                  if(fileCurrentlyUploading == true) {
                                    fileCurrentlyUploading = false;
                                  }
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
                  }
                ).onError((error, stackTrace) {
                  setState(() {
                    uploadFileStatusErrorText = "There was an error. Please try again.";
                  });

                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            uploadFileStatusErrorText,
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
                              if(fileCurrentlyUploading == true) {
                                fileCurrentlyUploading = false;
                              }
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

                print("uploadFileIntForChecks: " + uploadFileIntForChecks.toString());
                
              }
            }
          )
        ],
      ),
    );
  }
}