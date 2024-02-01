import 'package:flutter/material.dart';

//My dart files
import './dashboard.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    //The about page. Just to display what the app is about and for and who developed it

    return Scaffold(
      appBar: AppBar(
        title: const Text("Leno Files"),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => Dashboard())
              );
            },
          )
        ] //IconButton
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            "This is the android mobile application of Leno Files cloud storage. It was developed by Colin Uchem. You can check his website at www.uchemcolin.xyz to see more about him and his works",
            style: TextStyle(
              fontSize: 20
            )
          )
        ),
      )
    );
  }
}