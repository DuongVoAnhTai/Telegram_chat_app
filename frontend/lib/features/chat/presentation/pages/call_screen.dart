import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class CallScreen extends StatefulWidget {
  final Call call;
  final VoidCallback onCallEnded;

  const CallScreen({Key? key, required this.call, required this.onCallEnded})
    : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  void initState() {
    super.initState();
    // Join the call when the screen is opened
    widget.call.join();
  }

  @override
  void dispose() {
    // Leave the call when the screen is closed
    widget.call.leave();
    widget.onCallEnded();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: StreamCallContainer(call: widget.call));
  }
}
