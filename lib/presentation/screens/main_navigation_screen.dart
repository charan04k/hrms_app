import 'package:flutter/material.dart';

class MainNavigationScreen extends StatefulWidget {
  

  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {

  @override
  void initState() {
    super.initState();
  
  }
  

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Container(
        child: Text("Main Screen"),
      ),
    );
  }
}
