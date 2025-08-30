import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_information.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secret.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = "London";

      var response = await http.get(
        Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherSecret",
        ),
      );
      final data = jsonDecode(response.body);
      if (data["cod"] != '200') {
        throw "An unexpected error occurred.";
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();

    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          final data = snapshot.data!;

          final currentWeatherData = data["list"][0];

          final currentTemp = currentWeatherData["main"]["temp"];
          final currentSky = currentWeatherData["weather"][0]["main"];
          final currentPressure = currentWeatherData["main"]["pressure"];
          final currentWindSpeed = currentWeatherData["wind"]["speed"];
          final currentHumidity = currentWeatherData["main"]["humidity"];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                "$currentTemp K",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                currentSky == "Clouds" || currentSky == "Rain"
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(currentSky, style: TextStyle(fontSize: 20)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // weather forecast cards
                SizedBox(height: 20),
                Text(
                  "Hourly Forcast",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 8),

                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final hourlyForecast = data["list"][index + 1];
                      final hourlySky = hourlyForecast["weather"][0]["main"];
                      final hourlyTemp = hourlyForecast["main"]["temp"]
                          .toString();
                      final time = DateTime.parse(hourlyForecast["dt_txt"]);

                      return HourlyForcastItem(
                        time: DateFormat.Hm().format(time),
                        temperature: hourlyTemp,
                        icon: hourlySky == "Clouds" || hourlySky == "Rain"
                            ? Icons.cloud
                            : Icons.sunny,
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),

                // additional information
                Text(
                  "Aditional Information",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInformation(
                      icon: Icons.water_drop,
                      label: "Humidity",
                      value: currentHumidity.toString(),
                    ),
                    AdditionalInformation(
                      icon: Icons.air,
                      label: "Wind Speed",
                      value: currentWindSpeed.toString(),
                    ),
                    AdditionalInformation(
                      icon: Icons.beach_access,
                      label: "Pressure",
                      value: currentPressure.toString(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
