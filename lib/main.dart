import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'screens/create_meeting.dart';
import 'screens/join_meeting.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GetMaterialApp(
    home: Home(),
  ));
}

class Home extends StatelessWidget {
  @override
  Widget build(context) => Scaffold(
      appBar: AppBar(title: Text('Pamwe Chat')),
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {
                  Get.to(CreateMeetingPage(),
                      transition: Transition.rightToLeft);
                },
                child: Text(
                  'Create Meeting',
                  style: TextStyle(color: Colors.white),
                ),
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              MaterialButton(
                onPressed: () {
                  Get.to(JoinMeetingPage(), transition: Transition.rightToLeft);
                },
                child: Text(
                  'Join Meeting',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ],
          ),
        ],
      )));
}
