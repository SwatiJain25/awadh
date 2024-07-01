import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Add this import for formatting timestamps
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:ui' as ui;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
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
  TextEditingController gatewayIdController = TextEditingController();
  TextEditingController nodeIdController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  int? _epochStartTime;
  int? _epochEndTime;

  Future<void> _selectStartDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedStartDate ?? currentDate,
        ),
      );

      if (pickedTime != null) {
        DateTime combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _selectedStartDate = combinedDateTime;
          _epochStartTime = (combinedDateTime.millisecondsSinceEpoch ~/ 1000);
          startTimeController.text =
              DateFormat('yyyy-MM-dd HH:mm').format(combinedDateTime);
        });
      }
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedEndDate ?? currentDate,
        ),
      );

      if (pickedTime != null) {
        DateTime combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _selectedEndDate = combinedDateTime;
          _epochEndTime = (combinedDateTime.millisecondsSinceEpoch ~/ 1000);
          endTimeController.text =
              DateFormat('yyyy-MM-dd HH:mm').format(combinedDateTime);
        });
      }
    }
  }

  void fetchData() async {
    String nodeId = nodeIdController.text;
    String gatewayId = gatewayIdController.text;
    String startTime = _epochStartTime?.toString() ?? '';
    String endTime = _epochEndTime?.toString() ?? '';

    String url =
        'https://gjehwqgnii.execute-api.us-east-1.amazonaws.com/latest/data?nodeId=$nodeId&gatewayId=$gatewayId&starttime=$startTime&endtime=$endTime';

    final response = await http.get(Uri.parse(url));

    print('API Response Code: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      print('Decoded JSON: $jsonResponse');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SecondPage(
            sensorData: jsonResponse.cast<Map<String, dynamic>>(),
          ),
        ),
      );
    } else {
      // Handle error
      print('Failed to load data. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Get the current time
    
 
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/cloud9.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return ErrorWidget(error);
              },
            ),
          ),
          Center(
  child: SingleChildScrollView(
    child: Opacity(
      opacity: 0.8, // Adjust the opacity value as needed
      child: Card(
        elevation: 5,
        child: Container(
          width: screenSize.width * 0.6,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  "WEATHER APP",
                  style: GoogleFonts.radioCanada(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                      
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: gatewayIdController,
                decoration: InputDecoration(labelText: 'Enter Gateway ID'),
              ),
              TextField(
                controller: nodeIdController,
                decoration: InputDecoration(labelText: 'Enter Node ID'),
              ),
              TextField(
                controller: startTimeController,
                decoration: InputDecoration(labelText: 'Enter Start Date & Time'),
                onTap: () => _selectStartDate(context),
                readOnly: true,
              ),
              TextField(
                controller: endTimeController,
                decoration: InputDecoration(labelText: 'Enter End Date & Time'),
                onTap: () => _selectEndDate(context),
                readOnly: true,
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: fetchData,
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    textStyle: TextStyle(fontSize: 20, color: Colors.black),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shadowColor: Colors.lightBlue,shape: RoundedRectangleBorder(),
                    side: BorderSide(color: Colors.black, width: 1.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
),



        ],
      ),
    );
  }
}


class SecondPage extends StatefulWidget {
  final List<Map<String, dynamic>> sensorData;

  SecondPage({required this.sensorData});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  int selectedIndex = 0; // Track the selected card index

  String _formatTimestamp(dynamic timestamp) {
    int timestampValue = timestamp is String
        ? int.tryParse(timestamp) ?? 0
        : timestamp;
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestampValue * 1000);
    String formattedTimestamp = DateFormat('h:mm a dd/MM').format(dateTime);
    return formattedTimestamp;
  }

  String _getImageForLightIntensity(String lightIntensity) {
    int intensityValue = int.tryParse(lightIntensity) ?? 0;

    if (intensityValue >= 0 && intensityValue <= 2000) {
      return 'assets/images/cloud.png';
    } else if (intensityValue > 2000 && intensityValue <= 4000) {
      return 'assets/images/partially_sunny.png';
    } else {
      return 'assets/images/sunny.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg.webp'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.4), // Adjust opacity as needed
                      ),
                    ),
                    BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(constraints.maxWidth > 600 ? 20.0 : 10.0), // Adjust padding based on screen size
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  SizedBox(height: constraints.maxWidth > 600 ? 280 : 180), // Adjust height based on screen size
                                  Center(
                                    child: Card(
                                      elevation: 0,
                                      color: Colors.transparent,
                                      margin: EdgeInsets.only(bottom: 5.0),
                                      child: Padding(
                                        padding: EdgeInsets.all(30.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              flex: 5,
                                              child: Image.asset(
                                                _getImageForLightIntensity(widget.sensorData[selectedIndex]["light_intensity"]),
                                                height: 250,
                                                width: 250,
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              flex: 5,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    _formatTimestamp(widget.sensorData[selectedIndex]["timestamp"]),
                                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                                  ),
                                                  SizedBox(height: 8),
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      '${widget.sensorData[selectedIndex]["temperature"]}℃',
                                                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white), // Increased font size
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      'Wind Speed: ${Random().nextInt(50)} m/s',
                                                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white), // Increased font size
                                                    ),
                                                  ),
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      'Light Intensity: ${widget.sensorData[selectedIndex]["light_intensity"]} ',
                                                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white), // Increased font size
                                                    ),
                                                  ),
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      'Humidity: ${widget.sensorData[selectedIndex]["humidity"]}',
                                                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white), // Increased font size
                                                    ),
                                                  ),
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      'Soil Moisture: ${Random().nextInt(100)}%',
                                                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white), // Increased font size
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(
                                  widget.sensorData.length - 1, // Exclude the first card
                                  (index) => GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = index + 1; // Update the selected card index
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: SizedBox(
                                        width: 200, // Adjust card width as needed
                                        child: Card(
                                          elevation: 0,
                                          color: Colors.transparent,
                                          margin: EdgeInsets.only(bottom: 30.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.white, // Color of the border
                                                width: 2, // Width of the border
                                              ),
                                              borderRadius: BorderRadius.circular(8), // Optional: if you want rounded corners
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Image.asset(
                                                    _getImageForLightIntensity(widget.sensorData[index + 1]["light_intensity"]),
                                                    height: 80, // Adjust image height as needed
                                                    width: 80, // Adjust image width as needed
                                                  ),
                                                  Divider(color: Colors.white,),
                                                  Text(
                                                    _formatTimestamp(widget.sensorData[index + 1]["timestamp"]),
                                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    '${widget.sensorData[index + 1]["temperature"]}℃',
                                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                                  ),
                                                  SizedBox(height: 8),
                                                  // Show other parameters for other cards when selected
                                                  if (selectedIndex == index + 1) ...[
                                                    Text(
                                                      'Wind Speed: ${Random().nextInt(50)} m/s',
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                                    ),
                                                    Text(
                                                      'Humidity: ${widget.sensorData[index + 1]["humidity"]}',
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                                    ),
                                                    Text(
                                                      'Soil Moisture: ${Random().nextInt(100)}%',
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
