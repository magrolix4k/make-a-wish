import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Domain/PlaceDetailsPage.dart';
import '../Domain/PlaceListview.dart';
import '../utils/colors.dart';
import '../widgets/ReuseableText.dart';


class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isSearching = false;
  String? username;

  late String _selectedWatName;

  List<String> _watNames = ['วัด1', 'วัด2', 'วัด3'];


  @override
  void initState() {
    super.initState();
    getUsername();
    _selectedWatName = _watNames.first;
  }

  void getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    if (savedUsername != null) {
      setState(() {
        username = savedUsername;
      });
    }
  }

  void fetchData(String query) async {
    final response = await http.post(
      Uri.parse('https://makeawish.comsciproject.net/scifoxz/_searchData.php'),
      body: {'q': query},
    );

    if (response.statusCode == 200) {
      setState(() {
        searchResults = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        searchResults.clear();
      }
    });
  }

  void _navigateToPlaceDetails(
      BuildContext context, Map<String, dynamic> placeData) {
    Get.to(
      PlaceDetailsPage(placeData: placeData),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHight = MediaQuery.of(context).size.height;


    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 50),
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReusableText(
                      text: "สวัสดีคุณ $username",
                      color: AppColors.mainColor,
                      size: screenWidth * 0.06,
                      alignment: Alignment.center,
                    ),
                    Row(
                      children: [
                        DropdownButton<String>(
                          value: _selectedWatName,
                          items: _watNames.map((String watName) {
                            return DropdownMenuItem(
                              value: watName,
                              child: Text(watName),
                            );
                          }).toList(),
                          onChanged: (selectedWat) {
                            setState(() {
                              _selectedWatName = selectedWat!;
                            });
                          },
                        ),
                        SizedBox(width: 50.0),
                        DropdownButton<String>(
                          value: _selectedWatName,
                          items: _watNames.map((String watName) {
                            return DropdownMenuItem(
                              value: watName,
                              child: Text(watName),
                            );
                          }).toList(),
                          onChanged: (selectedWat) {
                            setState(() {
                              _selectedWatName = selectedWat!;
                            });
                          },
                        ),
                        SizedBox(width: 70.0),
                        DropdownButton<String>(
                          value: _selectedWatName,
                          items: _watNames.map((String watName) {
                            return DropdownMenuItem(
                              value: watName,
                              child: Text(watName),
                            );
                          }).toList(),
                          onChanged: (selectedWat) {
                            setState(() {
                              _selectedWatName = selectedWat!;
                            });
                          },
                        ),
                      ],
                    ),

                  ],
                ),
                Center(
                  child: Container(
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.1,
                    child: GestureDetector(
                      onTap: () {
                        _toggleSearch();
                      },
                      child: Icon(
                        isSearching ? Icons.clear : Icons.search,
                        color: Colors.white,
                      ),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      color: AppColors.mainColor,
                    ),
                  ),
                )
              ],
            ),
          ),
          if (isSearching) ...[
            _buildSearchBar(),
            if (searchResults.isNotEmpty) ...[
              _buildSearchResults(screenWidth),
            ],
          ] else ...[
            Expanded(
              child: SingleChildScrollView(
                child: DashboardPage(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: searchController,
        onChanged: (query) {
          fetchData(query);
        },
        decoration: InputDecoration(
          hintText: "ค้นหา...",
          suffixIcon: GestureDetector(
            onTap: () {
              searchController.clear();
            },
            child: Icon(Icons.clear),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(double screenWidth) {
    return Expanded(
      child: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          Uint8List imageBytes =
          base64Decode(searchResults[index]['place_image']);
          return GestureDetector(
            onTap: () {
              _navigateToPlaceDetails(context, searchResults[index]);
            },
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenWidth * 0.02,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      color: Colors.white38,
                    ),
                    child: Builder(
                      builder: (BuildContext context) {
                        try {
                          return Image.memory(
                            imageBytes,
                            fit: BoxFit.contain,
                          );
                        } catch (e) {
                          return Text("Image loading error");
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: screenWidth * 0.25,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: screenWidth * 0.04,
                          right: screenWidth * 0.04,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ReusableText(
                                text: searchResults[index]['place_name'],
                                size: screenWidth * 0.05,
                                alignment: Alignment.center),
                            SizedBox(height: screenWidth * 0.02),
                            ReusableText(
                                text: searchResults[index]['place_nameHoly'],
                                size: screenWidth * 0.04,
                                alignment: Alignment.center),
                            SizedBox(height: screenWidth * 0.02),
                            ReusableText(
                              text:
                              'จ.' + searchResults[index]['place_province'],
                              size: screenWidth * 0.035,
                              alignment: Alignment.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}