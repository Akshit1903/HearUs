import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class SleepTimer with ChangeNotifier {
  final sleepTimerInstance = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChange: (value) => print('onChange $value'),
    onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
    onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
  );
}
