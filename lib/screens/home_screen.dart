
import 'package:agriinsight_ai/screens/prediction_screen.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'chatbot.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Agri Insight Ai",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF2E7D32),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FadeInUp(
                  duration: Duration(milliseconds: 1600),
                  child: MaterialButton(
                    onPressed: () {},
                    height: 50,
                    // margin: EdgeInsets.symmetric(horizontal: 50),
                    color: Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    // decoration: BoxDecoration(
                    // ),
                    child: Center(
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PredictionScreen()));
                        },
                        child: Text(
                          "Detect Wheat Disease with image",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  )),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FadeInUp(
                  duration: Duration(milliseconds: 1600),
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatBotAgriAi()),
                      );
                    },
                    height: 50,
                    // margin: EdgeInsets.symmetric(horizontal: 50),
                    color: Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    // decoration: BoxDecoration(
                    // ),
                    child: Center(
                      child: Text(
                        "Agri: Chatbot Ai",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  )),
            ),
          ],
        ));
  }
}
