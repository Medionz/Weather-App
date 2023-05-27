import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(WeatherApp());

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      home: WeatherHome(),
    );
  }
}

class WeatherHome extends StatefulWidget {
  @override
  _WeatherHomeState createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  String _city = "Miami";
  double? _temperature;
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    final response = await http.get(Uri.parse(
        'http://api.openweathermap.org/data/2.5/weather?q=$_city&appid=1a05c19d399c1aa91a7f1150ef6d6f99&units=imperial'));

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      setState(() {
        _temperature = result['main']['temp'];
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Current weather in $_city:',
            ),
            Text(
              '${_temperature != null ? _temperature!.toStringAsFixed(2) : "..."}°F',
              style: Theme.of(context).textTheme.headline4,
            ),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(labelText: "Enter city name"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _city = _cityController.text;
                  _fetchWeather();
                });
              },
              child: Text("Get Weather"),
            )
          ],
        ),
      ),
    );
  }
}
