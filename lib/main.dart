import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(new MaterialApp(
    home: LocationPage(),
  ));
  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  AudioPlayer advancedPlayer;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LocationPage(),
    );
  }
}

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  Duration _duration = Duration();
  Duration _pos = Duration();
  AudioCache audioCache;
  AudioPlayer advancedPlayer;
  Position _position;
  double distanceInMeters;
  StreamSubscription<Position> _positionStream;

  @override
  void initState() {
    super.initState();
    initPlayer();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    _positionStream = Geolocator()
        .getPositionStream(locationOptions)
        .listen((Position position) {
      setState(() {
        print(position);
        _position = position;
      });
    });
  }

  void initPlayer() {
    advancedPlayer = AudioPlayer();
    audioCache = AudioCache(fixedPlayer: advancedPlayer);
    advancedPlayer.durationHandler = (d) => setState(() {
          _duration = d;
        });

    @override
    void dispose() {
      super.dispose();
      _positionStream.cancel();
    }

    advancedPlayer.positionHandler = (p) => setState(() {
          _pos = p;
        });
  }

  String localFilePath;

  Widget _tab(List<Widget> children) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
              children: children
                  .map((w) => Container(
                        child: w,
                        padding: EdgeInsets.all(6.0),
                      ))
                  .toList()),
        )
      ],
    );
  }

  Widget _btn(String txt, VoidCallback onPressed) {
    return ButtonTheme(
        minWidth: 48.0,
        child: Container(
          width: 150.0,
          height: 45,
          child: RaisedButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Text(txt),
            color: Colors.pink[900],
            textColor: Colors.white,
            onPressed: onPressed,
          ),
        ));
  }

  Widget localAudio() {
    return _tab([
      _btn(
          'Play',
          () async => {
                distanceInMeters = await Geolocator().distanceBetween(
                    25.986137, -79.528919, 8.986130, -79.528919),
                print(distanceInMeters),
                if (distanceInMeters <= 2)
                  {
                    audioCache.play('the_best_alarm_ever.mp3'),
                  }
              }),
      _btn('Pause', () => advancedPlayer.pause()),
      _btn('Stop', () => advancedPlayer.stop()),
      SizedBox(width: 20.0, height: 20.0),
      Text(
          "Location ${_position?.latitude ?? '-'}, ${_position?.longitude ?? '-'}"),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(elevation: 1, title: Text("Location Manager")),
        body: TabBarView(
          children: <Widget>[
            localAudio(),
          ],
        ),
        /*body: Align(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
              "Location ${_position?.latitude ?? '-'}, ${_position?.longitude ?? '-'}"),
          FlatButton(
            onPressed: () {
              print('HI');
            },
            child: null,
          ),
        ],
      )), */
      ),
    );
  }
}
