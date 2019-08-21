import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

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
  List _buttonLabel = ['Start!', 'Stop!'];
  String _runButtonLabel = 'Start!';
  Timer _timer;
  int _startTime;
  List _bell = [0, 0, 0];
  int _bell1 = 0;
  int _bell2 = 0;
  int _bell3 = 0;
  List initialtimer = [new Duration(), new Duration(), new Duration()];
  // Duration initialtimer = new Duration();

  void alert() {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Unhappy letter'),
          content: Text('Time up'),
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

  void _incrementCounter() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _runButtonLabel = _buttonLabel[0];
        _totalCounter = _counter;
        _isRunning = false;
      });
    } else {
      setState(() {
        _runButtonLabel = _buttonLabel[1];
      });
      _startTime = new DateTime.now().millisecondsSinceEpoch;
      _timer = Timer.periodic(
          Duration(seconds: 1),
          (Timer timer) => setState(() {
                int _nowTime = new DateTime.now().millisecondsSinceEpoch;
                _counter = _nowTime - _startTime + _totalCounter;
                if (_counter ~/ 1000 == _bell[0] ~/ 1000) alert();
                if (_counter ~/ 1000 == _bell[1] ~/ 1000) alert();
                if (_counter ~/ 1000 == _bell[2] ~/ 1000) alert();
                _isRunning = true;
              }));
    }
  }

  void _resetCounter() {
    if (_isRunning) return;
    _timer?.cancel();
    setState(() {
      _counter = 0;
      _totalCounter = 0;
    });
  }

  String milliseconds2time(int ms) {
    return '${new DateTime.fromMillisecondsSinceEpoch(ms).toUtc()}'
        .substring(10, 19);
  }

  @override
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
      // child: Text(
      //   "$icon ${milliseconds2time(_bell[bellNum])}",
      //   style: TextStyle(
      //     fontSize: 24,
      //   ),
      // ),
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
                    print(_bell[bellNum]);
                  },
                ),
              );
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // Text(
            //   '$_counter',
            // ),
            Text(
              '${milliseconds2time(_counter)}',
              // style: Theme.of(context).textTheme.display1,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 36,
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
                  RaisedButton(
                    onPressed: _resetCounter,
                    child: Text('Reset!'),
                  ),
                  RaisedButton(
                    onPressed: _incrementCounter,
                    child: Text('$_runButtonLabel'),
                  ),
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
