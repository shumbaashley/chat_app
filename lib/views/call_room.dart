import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_ion/flutter_ion.dart' as ion;
import 'package:ion_flutter_example/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Participant {
  Participant(this.title, this.renderer, this.stream, this.name);
  String name;
  MediaStream stream;
  String title;
  RTCVideoRenderer renderer;
}

class CallRoomController extends GetxController {
  List<Participant> plist = <Participant>[].obs;
  String room;
  String pname;
  var _inCalling = false.obs;
  final _micOn = true.obs;
  final ion.Signal _signal = ion.JsonRPCSignal('wss://pamwe.co.zw:7000/ws');
  ion.Client _client;
  ion.LocalStream _localStream;

  @override
  @mustCallSuper
  void onInit() {
    setRoom();
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  setRoom() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    room = prefs.getString('room') ?? 'testroom';
    pname = prefs.getString('name');
  }

  void makeCall() async {
    if (_inCalling == false) {
      _inCalling.toggle();
      Get.snackbar('Status', 'Calling...');
    }

    if (_client == null) {
      _client = await ion.Client.create(sid: room, signal: _signal);

      _localStream = await ion.LocalStream.getUserMedia(
          constraints: ion.Constraints.defaults..simulcast = false);

      await _client.publish(_localStream);

      _client.ontrack = (track, ion.RemoteStream remoteStream) async {
        if (track.kind == 'video') {
          print('ontrack: remote stream => ${remoteStream.id}');
          var renderer = RTCVideoRenderer();
          await renderer.initialize();
          renderer.srcObject = remoteStream.stream;
          plist
              .add(Participant('Remote', renderer, remoteStream.stream, pname));
        }
      };

      var renderer = RTCVideoRenderer();
      await renderer.initialize();
      renderer.srcObject = _localStream.stream;
      plist.add(Participant('Local', renderer, _localStream.stream, pname));
    }
  }

  void screenShare() async {
    if (_inCalling == false) {
      _inCalling.toggle();
      Get.snackbar('Status', 'Presenting...');
    }

    if (_client == null) {
      _client = await ion.Client.create(sid: room, signal: _signal);

      _localStream = await ion.LocalStream.getDisplayMedia(
          constraints: ion.Constraints.defaults..simulcast = false);

      await _client.publish(_localStream);

      _client.ontrack = (track, ion.RemoteStream remoteStream) async {
        if (track.kind == 'video') {
          print('ontrack: remote stream => ${remoteStream.id}');
          var renderer = RTCVideoRenderer();
          await renderer.initialize();
          renderer.srcObject = remoteStream.stream;
          plist
              .add(Participant('Remote', renderer, remoteStream.stream, pname));
        }
      };

      var renderer = RTCVideoRenderer();
      await renderer.initialize();
      renderer.srcObject = _localStream.stream;
      plist.add(Participant('Local', renderer, _localStream.stream, pname));
    }
  }

  confirmLeave() {
    Get.defaultDialog(
        title: 'End Call',
        middleText: 'Are you sure you want to quit call?',
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                Get.back();
              },
              child: Text('Cancel')),
          FlatButton(onPressed: hangUp, child: Text("Yes, I'm sure"))
        ]);
  }

  Future hangUp() async {
    if (_inCalling == true) {
      await _localStream.unpublish();
      _localStream.stream.getTracks().forEach((element) {
        element.stop();
      });
      await _localStream.stream.dispose();
      _localStream = null;
      _client.close();
      _client = null;
      plist.removeWhere((element) => element.name == pname);
      _inCalling.toggle();
    }
    backToHome();
    Get.snackbar('Status', 'Call Ended.');
  }

  void backToHome() {
    Get.to(Home(), transition: Transition.leftToRight);
  }

  void switchCamera() async {
    if (_localStream != null) {
      _localStream.stream.getVideoTracks()[0].switchCamera();
      Get.snackbar('Status', 'Switching Camera');
    }
  }

  showSettings() {}

  void muteMic() {
    if (_localStream != null) {
      _micOn.toggle();
      bool enabled = _localStream.stream.getAudioTracks()[0].enabled;
      _localStream.stream.getAudioTracks()[0].enabled = !enabled;
      // ignore: unrelated_type_equality_checks
      if (_micOn != true) {
        Get.snackbar('Status', 'Microphone muted');
      } else {
        Get.snackbar('Status', 'Microphone unmuted');
      }
    }
  }
}

class CallRoomView extends StatelessWidget {
  final CallRoomController c = Get.put(CallRoomController());

  Widget getItemView(Participant item) {
    return Container(
        padding: EdgeInsets.all(5.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                item.name,
                style: TextStyle(fontSize: 14, color: Colors.white54),
              ),
            ),
            Expanded(
              child: RTCVideoView(item.renderer,
                  objectFit:
                      RTCVideoViewObjectFit.RTCVideoViewObjectFitContain),
            ),
          ],
        ));
  }

  @override
  Widget build(context) {
    return WillPopScope(
        onWillPop: () {
          c.backToHome();
        },
        child: Scaffold(
            appBar: AppBar(title: Text('Meeting Room'), actions: <Widget>[
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: c.showSettings,
              )
            ]),
            body: OrientationBuilder(
              builder: (context, orientation) {
                return Center(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Container(
                        padding: EdgeInsets.all(10.0),
                        child: Obx(() => GridView.builder(
                            shrinkWrap: true,
                            itemCount: c.plist.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 1.0,
                                    crossAxisSpacing: 1.0,
                                    childAspectRatio: 1.0),
                            itemBuilder: (BuildContext context, int index) {
                              return getItemView(c.plist[index]);
                            }))),
                    decoration: BoxDecoration(color: Colors.black54),
                  ),
                );
              },
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            // ignore: unrelated_type_equality_checks
            floatingActionButton: Obx(() => c._inCalling == true
                ? SizedBox(
                    width: 200.0,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          FloatingActionButton(
                              child: const Icon(Icons.switch_camera),
                              onPressed: () {
                                c.switchCamera;
                              }),
                          FloatingActionButton(
                            onPressed: c.confirmLeave,
                            tooltip: 'Hangup',
                            child: Icon(Icons.call_end),
                            backgroundColor: Colors.pink,
                          ),
                          FloatingActionButton(
                            // ignore: unrelated_type_equality_checks
                            child: c._micOn == true
                                ? const Icon(Icons.mic_off)
                                : const Icon(Icons.mic),
                            onPressed: c.muteMic,
                          )
                        ]))
                : SizedBox(
                    width: 200.0,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          FloatingActionButton(
                              child: const Icon(Icons.videocam),
                              onPressed: c.makeCall),
                          FloatingActionButton(
                            onPressed: c.screenShare,
                            child: const Icon(Icons.screen_share),
                          ),
                        ])))));
  }
}
