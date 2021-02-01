import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ion_flutter_example/views/call_room.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JoinMeetingPage extends StatefulWidget {
  JoinMeetingPage({Key key}) : super(key: key);

  @override
  _JoinMeetingPageState createState() => _JoinMeetingPageState();
}

class _JoinMeetingPageState extends State<JoinMeetingPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String name;
  String meetingRoom;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController meetingRoomController = TextEditingController();

  setRoomSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('room', meetingRoomController.text);
    await prefs.setString('name', nameController.text);
    print(prefs.getString('room'));
    print(prefs.getString('name'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Meeting'),
      ),
      body: SafeArea(
          top: false,
          bottom: false,
          child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  SizedBox(
                    height: 130.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: TextFormField(
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      controller: nameController,
                      onChanged: (value) {},
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.person),
                          labelText: 'Full name',
                          hintText: 'Full name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: TextFormField(
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter Meeting id';
                        }
                        return null;
                      },
                      controller: meetingRoomController,
                      onChanged: (value) {},
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.meeting_room),
                          labelText: 'Meeting room id',
                          hintText: 'Meeting room id',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 3 / 5,
                    child: MaterialButton(
                        child: Text('Proceed'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: EdgeInsets.all(15.0),
                        color: Colors.blue,
                        textColor: Colors.white,
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            // validation that id is correct
                            if (meetingRoomController.text.length < 6) {
                              return;
                            }
                            setRoomSettings();
                            //Create a Meeting room
                            Get.to(CallRoomView(),
                      transition: Transition.rightToLeft);
                            // print('Joined');
                            // print(nameController.text);
                            // print(meetingRoomController.text);
                          }
                        }),
                  )
                ],
              ))),
    );
  }
}
