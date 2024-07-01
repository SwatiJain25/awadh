import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Add this import for formatting timestamps
import 'package:google_fonts/google_fonts.dart';
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
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather Data',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/cloud9.pg',
              width: 500,
              height: 200,
            ),
            Card(
              elevation: 5,
              child: Container(
                width: screenSize.width * 0.8,
                height: screenSize.height * 0.6,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          textStyle: TextStyle(fontSize: 18),
                          
                          side: BorderSide(color: Colors.blue, width: 2.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class SecondPage extends StatelessWidget {
  final List<Map<String, dynamic>> sensorData;

  SecondPage({required this.sensorData});

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
      return 'assets/images/sun.png';
    }
  }

  String _getImageForTime(String humanTime, String lightIntensity) {
    DateTime dateTime = DateFormat('yyyy-MM-dd hh:mm a').parse(humanTime);
    int intensityValue = int.tryParse(lightIntensity) ?? 0;

    // Check if the time is between 8:00 PM and 5:00 AM
    if (dateTime.hour >= 20 || dateTime.hour < 5) {
      return 'assets/images/moon.png';
    } else {
      if (intensityValue >= 0 && intensityValue <= 2000) {
        return 'assets/images/cloud.png';
      } else if (intensityValue > 2000 && intensityValue <= 4000) {
        return 'assets/images/partially_sunny.png';
      } else {
        return 'assets/images/sunny.png';
      }
    }
  }
@override
  Widget build(BuildContext context) {
    sensorData.sort((a, b) => b["timestamp"].compareTo(a["timestamp"]));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fetched Data',
          style: GoogleFonts.radioCanada(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/cloud.gif', // Path to your background image
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6), // Optional: adds a black overlay with opacity
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Retrieved',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: sensorData.length,
                    itemBuilder: (context, index) {
                      String timeImage = _getImageForTime(
                        sensorData[index]["human_time"],
                        sensorData[index]["light_intensity"]
                      );

                      return Card(
  elevation: 5,
  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  color: index == 0 ? Colors.greenAccent.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Opacity(
                opacity: 0.9, // Adjust opacity here
                child: Text(
                  'Humidity: ${sensorData[index]["humidity"]}%',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 8),
              Opacity(
                opacity: 0.9, // Adjust opacity here
                child: Text(
                  'Light Intensity: ${sensorData[index]["light_intensity"]}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 8),
              Opacity(
                opacity: 0.9, // Adjust opacity here
                child: Text(
                  'Temperature: ${sensorData[index]["temperature"]}℃',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 8),
              Opacity(
                opacity: 0.9, // Adjust opacity here
                child: Text(
                  'Timestamp: ${_formatTimestamp(sensorData[index]["timestamp"])}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 100, // Set your desired height
          width: 100, // Set your desired width
          child: Image.asset(timeImage),
        ),
      ],
    ),
  ),
);

                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}