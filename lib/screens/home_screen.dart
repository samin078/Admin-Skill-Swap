import 'package:admin_skill_swap/screens/skill_screen.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MaterialButton(
            onPressed: (){
              Navigator.pushNamed(context, SkillScreen.id);
            },
            child: Text(
              "SKILLS",
            ),
          ),
          MaterialButton(
            onPressed: (){
              //Navigator.pushNamed(context, UserProfile.id);
            },
            child: Text(
              "USERS",
            ),
          ),

        ],
      ),
    );
  }
}
