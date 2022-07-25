import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import '../../services/agora.dart';
import 'package:provider/provider.dart';

class CallTimer extends StatefulWidget {
  @override
  _CallTimerState createState() => _CallTimerState();
}

class _CallTimerState extends State<CallTimer> {
  StopWatchTimer stopWatchTimer;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    stopWatchTimer = Provider.of<Agora>(context).stopWatchTimer;
  }

  @override
  void dispose() {
    super.dispose();
    //stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Start

    return Container(
      child: StreamBuilder<int>(
        stream: stopWatchTimer.rawTime,
        initialData: 0,
        builder: (ctx, snapshot) {
          //final value = StopWatchTimer.getMilliSecFromMinute(60);
          final displayTime = StopWatchTimer.getDisplayTime(snapshot.data);
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          }
          return Text(
            displayTime.substring(3, 8),
            style: TextStyle(color: Colors.white),
          );
        },
      ),
    );
  }
}
