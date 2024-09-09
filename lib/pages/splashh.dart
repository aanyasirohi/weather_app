import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';




class splash extends StatefulWidget {

  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> with SingleTickerProviderStateMixin {
  @override
  void initState(){
    super.initState();

    Timer(Duration(seconds: 2),(){
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
    });
  }

  @override
  void dispose(){
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.2),
                    bottomRight: Radius.circular(10.2),
                  ),
                  child: Image(
                    image: AssetImage('image/weather.png'),
                    height: 150.0, // Set the desired height
                    width: 150.0,  // Set the desired width
                    fit: BoxFit.contain, // Adjust how the image is fitted
                  ),
                ),
              ),
            ),

            // Padding(
            //   padding:const EdgeInsets.all(28.0),
            //   child: LinearProgressIndicator(
            //       color: Colors.teal,
            //       minHeight: 2.0,
            //       borderRadius: BorderRadius.circular(10.2)
            //   ),
            // ),
            // Text("jhjkh",style:fontschange.txtt() ,)
          ],
        ),
      ),
    );
  }
}
