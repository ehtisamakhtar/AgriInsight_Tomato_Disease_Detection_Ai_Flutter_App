import 'package:agriinsight_ai/screens/weatherscreen.dart';
import 'package:flutter/material.dart';
import 'package:agriinsight_ai/screens/prediction_screen.dart';
import 'package:agriinsight_ai/screens/chatbot.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() => [
    const PredictionScreen(),
    const ChatBotAgriAi(),
    const WeatherScreen(), // Replace with your actual weather widget
  ];

  List<PersistentBottomNavBarItem> _navBarsItems() => [
    PersistentBottomNavBarItem(
      icon: Icon(Icons.science_outlined),
      title: "Detect",
      activeColorPrimary: Color(0xFF2E7D32),
      activeColorSecondary: Colors.white,
      inactiveColorPrimary: Colors.grey,

    ),
    PersistentBottomNavBarItem(
      icon: Icon(Icons.chat_bubble_outline),
      title: "Chatbot",
      activeColorPrimary: Color(0xFF2E7D32),
      activeColorSecondary: Colors.white, // <-- White title
      inactiveColorPrimary: Colors.grey,
    ),
    PersistentBottomNavBarItem(
      icon: Icon(Icons.cloud_outlined),
      title: "Weather",
      activeColorPrimary: Color(0xFF2E7D32),
      activeColorSecondary: Colors.white, // <-- White title
      inactiveColorPrimary: Colors.grey,
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      navBarStyle: NavBarStyle.style7,
      backgroundColor: Colors.white,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
    );
  }
}
