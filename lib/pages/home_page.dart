import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle

import '../consts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController t1 = TextEditingController();
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  Weather? _weather;
  List<Weather>? _forecast; // List to hold 10-day forecast

  @override
  void initState() {
    super.initState();
    _fetchWeather(); // Fetch initial weather
    _fetchForecast(); // Fetch forecast
  }

  void _fetchWeather([String cityName = "Gwalior"]) {
    _wf.currentWeatherByCityName(cityName).then((w) {
      setState(() {
        _weather = w;
      });
    }).catchError((e) {
      setState(() {
        _weather = null; // Handle errors by setting _weather to null
      });
    });
  }

  void _fetchForecast([String cityName = "Gwalior"]) {
    _wf.fiveDayForecastByCityName(cityName).then((f) {
      setState(() {
        _forecast = f;
      });
    }).catchError((e) {
      setState(() {
        _forecast = null; // Handle errors by setting _forecast to null
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: _weather == null
          ? _loadingScreen() // Show loading screen when _weather is null
          : _weatherScreen(), // Show actual weather screen when data is available
    );
  }

  Widget _loadingScreen() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _weatherScreen() {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(), // Use solid color based on time
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _greetings(),
              const SizedBox(height: 20), // Reduced height
              _searchField(),
              const SizedBox(height: 15), // Reduced height
              _locationHeader(),
              const SizedBox(height: 10), // Reduced height
              _weatherIcon(),
              const SizedBox(height: 10), // Reduced height
              _currentTemp(), // Temperature now centered
              const SizedBox(height: 10), // Reduced height
              _dateTimeInfo(),
              const SizedBox(height: 15), // Reduced height
              _extraInfoBox(),
              const SizedBox(height: 15), // Reduced height
              _forecastInfo(), // Display 10-day forecast
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    // Set background color based on time
    if (hour >= 4 && hour < 19) { // 4 AM to 7 PM
      return Colors.lightBlue;
    } else { // 7 PM to 4 AM
      return Colors.black;
    }
  }

  Widget _greetings() {
    String greeting = "";
    int hour = DateTime
        .now()
        .hour;

    if (hour < 12) {
      greeting = "Good Morning!";
    } else if (hour < 18) {
      greeting = "Good Afternoon!";
    } else {
      greeting = "Good Evening!";
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 20),
      child: Text(
        greeting,
        style: const TextStyle(
          fontSize: 24, // Smaller font size
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }

  Widget _searchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: t1,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14, // Smaller font size
        ),
        decoration: InputDecoration(
          labelText: "Enter city",
          labelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14, // Smaller font size
          ),
          suffixIcon: IconButton(
            onPressed: () {
              String cityName = t1.text.trim();
              if (cityName.isNotEmpty) {
                setState(() {
                  _weather = null; // Show loading bar when new search starts
                  _forecast = null; // Also reset forecast
                });
                _fetchWeather(cityName); // Fetch weather data on search
                _fetchForecast(cityName); // Fetch forecast data on search
              }
            },
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
      ),
    );
  }

  Widget _locationHeader() {
    return Align(
      alignment: Alignment.topRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 18),
          // Smaller icon size
          const SizedBox(width: 5),
          Text(
            _weather?.areaName ?? "",
            style: const TextStyle(
              fontSize: 14, // Smaller font size
              color: Colors.white,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherIcon() {
    return Column(
      children: [
        Container(
          height: MediaQuery
              .of(context)
              .size
              .height * 0.2, // Adjusted height
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "http://openweathermap.org/img/wn/${_weather
                      ?.weatherIcon}@4x.png"),
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _weather?.weatherDescription?.toUpperCase() ?? "Loading...",
          // Weather feel
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16, // Smaller font size
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }

  Widget _currentTemp() {
    return Center(
      child: Column(
        children: [
          Text(
            "${_weather?.temperature?.celsius?.toStringAsFixed(0)}° C",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40, // Slightly smaller font size
              fontWeight: FontWeight.bold, // Keep bold here
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateTimeInfo() {
    if (_weather == null || _weather!.date == null) {
      return const Text(
        "Date not available",
        style: TextStyle(
          fontSize: 16, // Smaller font size
          color: Colors.white,
          fontFamily: 'Montserrat',
        ),
      );
    }

    DateTime now = _weather!.date!.toLocal(); // Convert to local timezone
    String formattedDate = DateFormat("d MMM yyyy").format(now);
    String formattedDay = DateFormat("EEEE").format(now);

    return Center(
      child: Text(
        "$formattedDay, $formattedDate",
        style: const TextStyle(
          fontSize: 16, // Smaller font size
          color: Colors.white,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }

  Widget _extraInfoBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // More transparent background
        borderRadius: BorderRadius.circular(15), // Smaller radius
      ),
      padding: const EdgeInsets.all(10), // Smaller padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _infoRow(Icons.wb_sunny, "Sunrise", _weather?.sunrise),
              const SizedBox(width: 15), // Reduced spacing
              _infoRow(Icons.nights_stay, "Sunset", _weather?.sunset),
            ],
          ),
          const SizedBox(height: 10), // Reduced spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _infoRowTemp(
                  Icons.thermostat, "Max Temp", _weather?.tempMax?.celsius),
              const SizedBox(width: 15), // Reduced spacing
              _infoRowTemp(Icons.thermostat_outlined, "Min Temp",
                  _weather?.tempMin?.celsius),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, DateTime? time) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 18), // Adjusted icon size
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12, // Further reduced font size
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          time != null ? DateFormat.jm().format(time.toLocal()) : "Loading...",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12, // Further reduced font size
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }

  Widget _infoRowTemp(IconData icon, String label, double? temp) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 18), // Adjusted icon size
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12, // Further reduced font size
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          temp != null ? "${temp.toStringAsFixed(0)}° C" : "Loading...",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12, // Further reduced font size
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }

  Widget _forecastInfo() {
    if (_forecast == null || _forecast!.isEmpty) {
      return const Center(
        child: Text(
          "Forecast data not available",
          style: TextStyle(
            fontSize: 14, // Smaller font size
            color: Colors.white,
            fontFamily: 'Montserrat',
          ),
        ),
      );
    }

    // Create a map to store unique forecasts based on date
    Map<DateTime, Weather> uniqueForecasts = {};

    // Process the forecast data
    for (var weather in _forecast!) {
      if (weather.date != null) {
        DateTime date = weather.date!.toLocal();
        // Store the latest forecast for each date
        uniqueForecasts[DateTime(date.year, date.month, date.day)] = weather;
      }
    }

    // Convert the map to a list and sort by date
    List<Weather> sortedForecast = uniqueForecasts.values.toList();
    sortedForecast.sort((a, b) => a.date!.compareTo(b.date!));

    // Limit to 7 days forecast
    if (sortedForecast.length > 7) {
      sortedForecast = sortedForecast.sublist(0, 7);
    }

    return SizedBox(
      height: 100, // Keep box small
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sortedForecast.length,
        itemBuilder: (context, index) {
          Weather weather = sortedForecast[index];
          DateTime date = weather.date!.toLocal();
          String formattedDate = DateFormat("d MMM").format(date);

          return Container(
            width: 70, // Keep box small
            margin: const EdgeInsets.only(right: 5), // Reduced margin
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              // More transparent background
              borderRadius: BorderRadius.circular(8), // Smaller radius
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12, // Increased font size
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(
                  height: 30, // Adjust height for smaller icon
                  child: Image.network(
                    "http://openweathermap.org/img/wn/${weather
                        .weatherIcon}@2x.png",
                    fit: BoxFit.contain,
                  ),
                ),
                Text(
                  "${weather.temperature?.celsius?.toStringAsFixed(0)}° C",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12, // Increased font size
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}