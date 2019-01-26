import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  List quakeList = [];
  var format = new DateFormat.yMMMMd('en_US').add_jm();
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quake App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Text('Recent Quakes'),
            centerTitle: true,
          ),
          body: RefreshIndicator(
            onRefresh: () => _refresh(),
            child: ListView.builder(
              itemCount: quakeList.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: CircleAvatar(
                          child: Text(quakeList[index]['properties']['mag']
                              .toStringAsFixed(2)),
                        ),
                        title: Text(format.format(
                            DateTime.fromMillisecondsSinceEpoch(
                                quakeList[index]['properties']['time']))),
                        subtitle: Text(quakeList[index]['properties']['place']),
                      ),
                      ButtonTheme.bar(
                        child: ButtonBar(
                          children: <Widget>[
                            FlatButton(
                              child: Text('More info'),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      showMore(context, index),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )),
    );
  }

  Future<Map> getQuakes() async {
    String apiURL =
        'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson';
    http.Response response = await http.get(apiURL);
    return jsonDecode(response.body);
  }

  Future<void> _refresh() async {
    getQuakes().then((response) {
      setState(() {
        quakeList = response['features'];
      });
    });
  }

  Widget showMore(BuildContext context, int index) {
    return AlertDialog(
      title: Text(
        'Quake',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        'M ${quakeList[index]['properties']['mag']} ${quakeList[index]['properties']['place']}',
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Dismiss'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
