import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey =
      '60483e7bf3c664efc021dc5c0b3bd112'; // Replace with your OpenWeatherMap API key
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.get(Uri.parse(
          '$_baseUrl?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'temperature': data['main']['temp'].round(),
          'condition': data['weather'][0]['main'],
          'humidity': data['main']['humidity'],
          'windSpeed': data['wind']['speed'].round(),
          'location': data['name'],
        };
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }
}
