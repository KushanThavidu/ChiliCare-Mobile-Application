import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// Import your other pages
import 'login.dart';
import 'services/weather_service.dart';
import 'chilidetection.dart';
import 'chatbot.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;

  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic> _weatherData = {
    'temperature': 0,
    'condition': 'Loading...',
    'humidity': 0,
    'windSpeed': 0,
    'location': 'Loading...',
  };

  Future<void> _fetchWeatherData() async {
    try {
      // Default coordinates for Sri Lanka (you can replace with actual location)
      const latitude = 7.8731;
      const longitude = 80.7718;

      final weatherData = await _weatherService.getWeather(
        latitude: latitude,
        longitude: longitude,
      );

      setState(() {
        _weatherData = weatherData;
      });
    } catch (e) {
      print('Error fetching weather: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load weather data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // List of widgets for the bottom navigation bar
  final List<Widget> _widgetOptions = [
    HomeTab(),
    const ChiliDetectionScreen(),
    Container(
        color: Colors.green, child: Center(child: Text('Weed Detection'))),
    Container(color: Colors.orange, child: Center(child: Text('Quality'))),
    const ModernChatbotScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Fetch weather data when the screen loads
    _fetchWeatherData();

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatingController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Logout function with confirmation dialog
  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "LOGOUT",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.orange,
            ),
          ),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Navigate to login page and remove all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false, // This will remove all previous routes
                );
              },
              child: Text(
                "Logout",
                style: TextStyle(color: Colors.orange, fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F4C3A),
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background elements
              ...List.generate(8, (index) => _buildFloatingElement(index)),

              // Main content
              Column(
                children: [
                  // App Bar
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedBuilder(
                          animation: _floatingAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatingAnimation.value),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.3),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 15,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.eco,
                                  size: 28,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                        Text(
                          _selectedIndex == 0
                              ? "ChiliCare Home"
                              : _selectedIndex == 1
                                  ? "Disease Prediction"
                                  : _selectedIndex == 2
                                      ? "Weed Detection"
                                      : "Quality Measure",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: Offset(1, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.logout, color: Colors.white),
                          onPressed: () => _logout(context),
                        ),
                      ],
                    ),
                  ),

                  // Body content
                  Expanded(
                    child: _selectedIndex == 0
                        ? _buildHomeContent()
                        : _widgetOptions.elementAt(_selectedIndex),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 28),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.online_prediction, size: 28),
                label: 'Prediction',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.eco, size: 28),
                label: 'Weed Detection',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assessment, size: 28),
                label: 'Quality',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat, size: 28),
                label: 'Assistant',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.teal,
            unselectedItemColor: const Color.fromARGB(255, 105, 104, 104),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Weather Report Card
          _buildWeatherCard(),

          SizedBox(height: 20),

          // Quick Actions Title
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.1,
            ),
          ),

          SizedBox(height: 16),

          // Quick Actions Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildActionCard(
                icon: Icons.online_prediction,
                title: 'Disease Prediction',
                color: Colors.orange,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const ChiliDetectionScreen();
                      },
                    ),
                  );
                },
              ),
              _buildActionCard(
                icon: Icons.eco,
                title: 'Weed Detection',
                color: Colors.green,
                onTap: () => _onItemTapped(2),
              ),
              _buildActionCard(
                icon: Icons.assessment,
                title: 'Quality Measure',
                color: Colors.blue,
                onTap: () => _onItemTapped(3),
              ),
              _buildActionCard(
                icon: Icons.history,
                title: 'History',
                color: Colors.purple,
                onTap: () {
                  // Navigate to history page
                },
              ),
            ],
          ),

          SizedBox(height: 24),

          // Recent Scans Title
          Text(
            'Recent Scans',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.1,
            ),
          ),

          SizedBox(height: 16),

          // Recent Scans List
          _buildRecentScans(),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  _getWeatherIcon(_weatherData['condition']),
                  size: 50,
                  color: Colors.white,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_weatherData['temperature']}°C',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _weatherData['condition'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        _weatherData['location'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      'Humidity: ${_weatherData['humidity']}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Wind: ${_weatherData['windSpeed']} km/h',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScans() {
    // Mock recent scans data
    final List<Map<String, dynamic>> recentScans = [
      {
        'date': 'Today',
        'result': 'Healthy Chili Plant',
        'type': 'Disease Prediction'
      },
      {
        'date': 'Yesterday',
        'result': 'No Weeds Detected',
        'type': 'Weed Detection'
      },
      {
        'date': '2 days ago',
        'result': 'High Quality',
        'type': 'Quality Measure'
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: recentScans.length,
      itemBuilder: (context, index) {
        final scan = recentScans[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getScanColor(scan['type']),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getScanIcon(scan['type']),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan['result'],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${scan['type']} • ${scan['date']}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.5),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getScanColor(String type) {
    switch (type) {
      case 'Disease Prediction':
        return Colors.orange;
      case 'Weed Detection':
        return Colors.green;
      case 'Quality Measure':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }

  IconData _getScanIcon(String type) {
    switch (type) {
      case 'Disease Prediction':
        return Icons.online_prediction;
      case 'Weed Detection':
        return Icons.eco;
      case 'Quality Measure':
        return Icons.assessment;
      default:
        return Icons.history;
    }
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'cloudy':
        return Icons.cloud;
      case 'rainy':
        return Icons.beach_access;
      case 'windy':
        return Icons.air;
      default:
        return Icons.wb_sunny;
    }
  }

  Widget _buildFloatingElement(int index) {
    final random = (index * 234) % 100;
    final size = 3.0 + (random % 8);
    final left = (random * 4.2) % MediaQuery.of(context).size.width;
    final animationDelay = (random * 100) % 4000;

    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        final offset = (_floatingController.value * 150 + animationDelay) % 150;
        return Positioned(
          left: left,
          top: 100 + (offset * 4) % (MediaQuery.of(context).size.height - 300),
          child: Opacity(
            opacity: 0.05 + (offset / 150) * 0.15,
            child: Transform.rotate(
              angle: (_floatingController.value * 2 * math.pi + index) %
                  (2 * math.pi),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: size * 2,
                      spreadRadius: size,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Placeholder widgets for your other pages
class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
