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
  final TextEditingController _cityController = TextEditingController();
  List<String> _cities = [];
  Map<String, double?> _temperatures = {}; // modify this to allow null values
  String api_key = '1a05c19d399c1aa91a7f1150ef6d6f99';
  List<String> _suggestedCities = [];

  List<String> cityList = [
    'New York',
    'Los Angeles',
    'Chicago',
    'Houston',
    'Phoenix',
    'Philadelphia',
    'San Antonio',
    'San Diego',
    'Dallas',
    'San Jose',
  ];

  Future<void> _fetchWeather(String city) async {
    try {
      final response = await http.get(Uri.parse(
          'http://api.openweathermap.org/data/2.5/weather?q=$city&appid=$api_key&units=imperial'));

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        setState(() {
          _temperatures[city] = result['main']['temp'];
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      setState(() {
        _temperatures[city] = null; // Indicates that an error occurred.
      });
    }
  }

  void _updateSuggestions(String query) {
    setState(() {
      _suggestedCities = cityList
          .where((city) => city.toLowerCase().startsWith(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: _cityController,
            decoration: InputDecoration(labelText: "Enter city name"),
            onChanged: _updateSuggestions,
          ),
          ..._suggestedCities.map(
            (city) => ListTile(
              title: Text(city),
              onTap: () {
                setState(() {
                  _cities.add(city);
                  _cityController.text = city;
                  _suggestedCities.clear();
                  _fetchWeather(city);
                });
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              String city = _cityController.text;
              setState(() {
                if (!_cities.contains(city)) {
                  _cities.add(city);
                  _fetchWeather(city);
                }
                _cityController.clear();
              });
            },
            child: Text("Add City"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _cities.length,
              itemBuilder: (BuildContext context, int index) {
                String city = _cities[index];
                return ListTile(
                  title: Text(city),
                  subtitle: Text(_temperatures[city] == null
                      ? 'Could not load weather data'
                      : '${_temperatures[city]!.toStringAsFixed(2)}°F'),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
