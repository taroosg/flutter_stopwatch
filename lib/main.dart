import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countup Timer',
      theme: ThemeData(
        fontFamily: 'Copse',
        // primarySwatch: Colors.red,
        primaryColor: Color(0xffc85554),
      ),
      home: MyHomePage(title: 'Countup Timer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _totalCounter = 0;
  bool _isRunning = false;
  bool _isMario = false;
  List _buttonLabel = ['Start', 'Stop'];
  String _runButtonLabel = 'Start';
  Map _alertMessage = {
    'title': 'Unhappy letter',
    'alert': 'Invalid value.',
    'text1': 'Time soon.',
    'text2': "It's time.",
    'text3': "You died.",
  };
  Timer _timer;
  int _startTime;
  List _bell = [0, 0, 0];
  List initialtimer = [new Duration(), new Duration(), new Duration()];

  AudioCache player = AudioCache();

  // アラートを出す関数
  void alert(String title, String text) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(text),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  // 時間を管理する関数
  void _incrementCounter() {
    // この辺なんとかする
    if (((_bell[0] != 0 && _bell[1] != 0) && _bell[0] - _bell[1] >= 0) ||
        ((_bell[0] != 0 && _bell[2] != 0) && _bell[0] - _bell[2] >= 0) ||
        ((_bell[1] != 0 && _bell[2] != 0) && _bell[1] - _bell[2] >= 0)) {
      alert(_alertMessage['title'], _alertMessage['alert']);
      return;
    }

    if (_isRunning) {
      // 実行→停止
      _timer?.cancel();
      setState(() {
        _runButtonLabel = _buttonLabel[0];
        _totalCounter = _counter;
        _isRunning = false;
      });
    } else {
      // 停止→実行
      setState(() {
        _isRunning = true;
        _runButtonLabel = _buttonLabel[1];
      });
      _startTime = new DateTime.now().millisecondsSinceEpoch;
      _timer = Timer.periodic(
          Duration(seconds: 1),
          (Timer timer) => setState(() {
                int _nowTime = new DateTime.now().millisecondsSinceEpoch;
                _counter = _nowTime - _startTime + _totalCounter;
                if (_counter ~/ 1000 == _bell[0] ~/ 1000) {
                  // alert(_alertMessage['title'], _alertMessage['text1']);
                  if (_isMario) {
                    player.play('timeup.mp3');
                  } else {
                    player.play('bell_1.mp3');
                  }
                }
                if (_counter ~/ 1000 == _bell[1] ~/ 1000) {
                  // alert(_alertMessage['title'], _alertMessage['text2']);
                  player.play('bell_1.mp3');
                  int count = 0;
                  Timer bell2;
                  bell2 = Timer.periodic(Duration(milliseconds: 500),
                      (Timer timer) {
                    if (count > 0) {
                      bell2.cancel();
                    } else {
                      player.play('bell_1.mp3');
                      count++;
                    }
                  });
                }
                if (_counter ~/ 1000 == _bell[2] ~/ 1000) {
                  // alert(_alertMessage['title'], _alertMessage['text3']);
                  if (_isMario) {
                    player.play('castleclear.mp3');
                  } else {
                    player.play('bell_1.mp3');
                    int count = 0;
                    Timer bell2;
                    bell2 = Timer.periodic(Duration(milliseconds: 500),
                        (Timer timer) {
                      if (count > 1) {
                        bell2.cancel();
                      } else {
                        player.play('bell_1.mp3');
                        count++;
                      }
                    });
                  }
                }
              }));
    }
  }

  // リセットする関数
  void _resetCounter() {
    if (_isRunning) return;
    _timer?.cancel();
    setState(() {
      _counter = 0;
      _totalCounter = 0;
    });
  }

  // ミリ秒をいい感じに整形する関数
  String milliseconds2time(int ms) {
    return '${new DateTime.fromMillisecondsSinceEpoch(ms).toUtc()}'
        .substring(10, 19);
  }

  // 時間設定するwidget
  // @override
  Widget _inputDurationButton(String icon, int bellNum) {
    return MaterialButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 10.0),
            width: 100,
            child: Text(
              '$icon',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          Container(
            child: Text(
              '${milliseconds2time(_bell[bellNum])}',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      onPressed: () {
        showModalBottomSheet(
            context: context,
            builder: (BuildContext builder) {
              return Container(
                height: MediaQuery.of(context).copyWith().size.height / 3,
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hms,
                  minuteInterval: 1,
                  secondInterval: 1,
                  initialTimerDuration: initialtimer[bellNum],
                  onTimerDurationChanged: (Duration changedtimer) {
                    setState(() {
                      _bell[bellNum] = changedtimer.inMilliseconds;
                      initialtimer[bellNum] = changedtimer;
                    });
                    // print(_bell[bellNum]);
                  },
                ),
              );
            });
      },
    );
  }

  // スタート，ストップ，リセットボタンのwidget
  Widget _operationButton(String label, onPressedFunction) {
    return MaterialButton(
      color: Color(0xffc85554),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.white,
        ),
      ),
      minWidth: MediaQuery.of(context).copyWith().size.width / 2,
      height: MediaQuery.of(context).copyWith().size.height / 10,
      onPressed: onPressedFunction,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
        ),
      ),
    );
  }

  // 画面全体の制御
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 24.0,
          ),
        ),
        actions: <Widget>[
          CupertinoSwitch(
              activeColor: Color(0xff3e62ad),
              value: _isMario,
              onChanged: (bool value) {
                setState(() {
                  _isMario = value;
                });
              }),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              '${milliseconds2time(_counter)}',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: MediaQuery.of(context).copyWith().size.width / 10,
              ),
            ),
            Column(
              children: <Widget>[
                _inputDurationButton('🔔', 0),
                _inputDurationButton('🔔🔔', 1),
                _inputDurationButton('🔔🔔🔔', 2),
              ],
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _operationButton('Reset', _resetCounter),
                  _operationButton('$_runButtonLabel', _incrementCounter),
                ],
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
