import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ion_flutter_example/views/call_room.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';


final _chars = 'BbCcDdFfGgHhJjKkLlMmNnPpQqRrSsTtVvWwXxYyZz';
final Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

class CreateMeetingPage extends StatefulWidget {
  CreateMeetingPage({Key key}) : super(key: key);

  @override
  _CreateMeetingPageState createState() => _CreateMeetingPageState();
}

class _CreateMeetingPageState extends State<CreateMeetingPage> {
  String _meetingRoom;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    
    _meetingRoom = getRandomString(3).toLowerCase() +
        '-' +
        getRandomString(4).toLowerCase() +
        '-' +
        getRandomString(3).toLowerCase();

    
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('room', _meetingRoom);
    await prefs.setString('name', 'Admin');
    print(prefs.getString('room'));
    print(prefs.getString('name'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Create Meeting'),
        ),
        body: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Container(
                padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0.0),
                child: Text(
                  'Your meeting room ID is:',
                  style: const TextStyle(
                    fontSize: 26.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 30.0),
                child: SelectableText(
                  _meetingRoom,
                  showCursor: true,
                  toolbarOptions: ToolbarOptions(copy: true),
                  style: const TextStyle(
                    fontSize: 32.0,
                    color: Colors.red,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              MaterialButton(
                  child: Text('Proceed'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.all(15.0),
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () {
                    //Proceed to Meeting room
                  Get.to(CallRoomView(),
                      transition: Transition.rightToLeft);
                  }),
            ])));
  }
}
