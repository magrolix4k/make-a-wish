import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Layer/Domain/Login.dart';
import 'Layer/Presentation/ProfilePage.dart';
import 'Layer/widgets/colors.dart';
import 'Layer/Presentation/FavoritePage.dart';
import 'Layer/Presentation/SearchPage.dart';
import 'Layer/Presentation/ActivityPage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  bool isLoggedIn = false;

  final List<Widget> _pages = [
    FirstPage(),
    FavoritesPage(),
    ActivityPage(),
    ProfilePage(),
  ];

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoggedIn ? _pages[_currentIndex] : LoginPage(),
      bottomNavigationBar: isLoggedIn
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.mainColor,
              unselectedItemColor: AppColors.mainColor,
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: _currentIndex == 0
                      ? Icon(FontAwesomeIcons.magnifyingGlassLocation,
                          color: AppColors.mainColor)
                      : Icon(FontAwesomeIcons.magnifyingGlass,
                          color: AppColors.mainColor),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: _currentIndex == 1
                      ? Icon(FontAwesomeIcons.solidHeart,
                          color: AppColors.mainColor)
                      : Icon(FontAwesomeIcons.heart,
                          color: AppColors.mainColor),
                  label: 'Favorites',
                ),
                BottomNavigationBarItem(
                  icon: _currentIndex == 2
                      ? Icon(FontAwesomeIcons.barsStaggered,
                          color: AppColors.mainColor)
                      : Icon(Icons.article_outlined,
                          color: AppColors.mainColor),
                  label: 'Activity',
                ),
                BottomNavigationBarItem(
                  icon: _currentIndex == 3
                      ? Icon(Icons.person, color: AppColors.mainColor)
                      : Icon(Icons.person_outlined, color: AppColors.mainColor),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }
}