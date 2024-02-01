import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; //for the File class
import 'dart:async'; //for the File class
import 'dart:io'; //for the File class
import 'dart:math';

//My dart files
import './home.dart';
import './viewFilePage.dart';
import './dashboard.dart';

class SearchManageFilesPage extends StatefulWidget {

  var userSearchFiles;
  
  //const SearchManageFilesPage({Key? key}) : super(key: key);
  SearchManageFilesPage(this.userSearchFiles);

  @override
  State<SearchManageFilesPage> createState() => _SearchManageFilesPageState();
}

class _SearchManageFilesPageState extends State<SearchManageFilesPage> {

  var userSearchFiles; // if the user searched for files, this variables stores the returned files from the server

  late SharedPreferences _prefs; // to store the logged in token of the use

  late String loggedInUserToken; // the logged in user token from the server for the FutureBuilder

  late var userDetails; // the user details gotten from the server

  late var userFiles; // the logged in user's files

  late Future<int> _getLoggedInUserFilesIntInt;

  Future<int> _getLoggedInUserFilesInt() async {

    if(userSearchFiles?.isEmpty ?? true) {
      
      //
      return 1;
        
    } else {

      //
      userFiles = userSearchFiles;

      if(userFiles == [] || userFiles.isEmpty) {

        return 1;

      } else {
        //
        print("search file index 0");
        print(userFiles[0]["name"]);

        return 2;
      }
    }
  }

  late Future<int> _uploadFileInt;

  @override
  initState() {
    super.initState();
    _getLoggedInUserFilesIntInt = _getLoggedInUserFilesInt();

    setState(() {
      userSearchFiles = widget.userSearchFiles;

      print("User search files:");
      print(userSearchFiles);
    });
  }

  @override
  Widget build(BuildContext context) {

    if(userSearchFiles?.isEmpty ?? true) {
      
      //
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(
              Icons.info_outline_rounded,
              color: Colors.blue,
              size: 50,
            ),
            Text(
              "No file found!",
              style: TextStyle(
                color: Colors.black
              ),
            ),
          ]
        )
      );
        
    } else {

      //
      userFiles = userSearchFiles;

      if(userFiles == [] || userFiles.isEmpty) {

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.blue,
                size: 50,
              ),
              Text(
                "No file found!",
                style: TextStyle(
                  color: Colors.black
                ),
              ),
            ]
          )
        );

      } else {
        //

        if(userFiles.length > 0) {

          return ListView.separated(
            //shrinkWrap: false,
            itemCount: userFiles.length,
            itemBuilder: (BuildContext context, int index) {

              //String otherInformation = "Type: " +  userFilesToDisplay[index]["type"] + " | Size: " +  roundDouble(userFilesToDisplay[index]["size"], 5);
              //String otherInformation = "Type: " +  userFiles[index]["type"];
              int fileId = userFiles[index]["id"];
              var fileSize = userFiles[index]["size"];
              //double fileSize_rounded = double.parse((fileSize).toStringAsFixed(5));
              //var fileSizeRoundedToString = fileSize_rounded.toString();
              //var fileSizeRoundedToString = fileSize.toStringAsFixed(5);
              var fileSizeRoundedToString = fileSize.toString();
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
                leading: const Icon(Icons.file_present),
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
          //),
          );
        } else {

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "No file(s) found",
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
      }
    }
  }
}