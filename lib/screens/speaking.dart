import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class FeatureDetailPage extends StatefulWidget {
  final String title;

  FeatureDetailPage({required this.title});

  @override
  _FeatureDetailPageState createState() => _FeatureDetailPageState();
}

class _FeatureDetailPageState extends State<FeatureDetailPage> with SingleTickerProviderStateMixin {
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _response = '';
  List<String> _savedQueries = [];
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  final FlutterTts _flutterTts = FlutterTts();
  String _detectedLanguage = '';
  bool _isLoading = false;

  String? _selectedGender;
  String? _selectedRegion;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _regions = ['Urban', 'Rural', 'Suburban'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeInAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _queryController.dispose();
    _ageController.dispose();
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          _queryController.text = val.recognizedWords;
        },
      );
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);

    final recognizedText = _queryController.text.trim();
    if (recognizedText.isNotEmpty) {
      await _detectLanguage(recognizedText);
    }
  }

  Future<void> _detectLanguage(String text) async {
    final url = Uri.parse('https://ws.detectlanguage.com/0.2/detect');
    final apiKey = '1b4f911df0297c5c0e8ed491e2a56603'; // Replace with your key

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'q': text}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final lang = data['data']['detections'][0]['language'];

      setState(() {
        _detectedLanguage = lang;
      });

      Fluttertoast.showToast(
        msg: "Detected Language: $_detectedLanguage",
        backgroundColor: Colors.teal,
        textColor: Colors.white,
      );
    } else {
      print('Failed to detect language: ${response.body}');
    }
  }

  Future<void> _submitQuery() async {
    final query = _queryController.text.trim();
    final age = _ageController.text.trim();
    final gender = _selectedGender;
    final region = _selectedRegion;

    if (query.isEmpty) return;

    setState(() {
      _savedQueries.add(query);
      _isLoading = true;
      _response = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://164.52.192.233:5000/biomed'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': query,
          'age': age,
          'gender': gender,
          'region': region,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['response'] ?? 'No response found.';

        setState(() {
          _response = result;
          _queryController.clear();
          _ageController.clear();
        });

        _animationController.forward(from: 0);
        await _flutterTts.speak(result);
      } else {
        setState(() {
          _response = "Failed to get response. Server error.";
        });
        print('Server error: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _response = "Error: Could not connect to the server.";
      });
      print('Connection error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _stopTts() async {
    await _flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.title == 'Multilingual Voice Interface') {
      return Scaffold(
        appBar: AppBar(
          title: Text('Multilingual Voice Interface'),
          backgroundColor: Colors.teal,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🗣️ How to Speak Your Query:',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    )),
                SizedBox(height: 10),
                Text(
                  '• Speak slowly and clearly.\n• Use simple phrases like "I have a fever for two days."\n• Mention symptoms and duration.\n• Specify age if needed.',
                  style: GoogleFonts.poppins(fontSize: 18),
                ),
                SizedBox(height: 30),

                // Query TextField
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.teal.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 3),
                    ],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(15),
                  child: TextField(
                    controller: _queryController,
                    decoration: InputDecoration(
                      hintText: 'Type or Speak your health query here...',
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.poppins(fontSize: 18),
                  ),
                ),

                SizedBox(height: 20),

                // Age TextField
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 20),

                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _genders.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                SizedBox(height: 20),

                // Region Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRegion,
                  decoration: InputDecoration(
                    labelText: 'Region',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _regions.map((region) {
                    return DropdownMenuItem(
                      value: region,
                      child: Text(region),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRegion = value;
                    });
                  },
                ),
                SizedBox(height: 20),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isListening ? _stopListening : _startListening,
                      icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                      label: Text(_isListening ? 'Stop Listening' : 'Start Speaking'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: _submitQuery,
                      icon: Icon(Icons.send),
                      label: Text('Submit Query'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: _stopTts,
                  icon: Icon(Icons.stop),
                  label: Text('Stop Speech'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
                SizedBox(height: 30),

                if (_detectedLanguage.isNotEmpty)
                  Center(
                    child: Text(
                      "🌍 Detected Language: $_detectedLanguage",
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.teal.shade700),
                    ),
                  ),
                SizedBox(height: 30),

                if (_isLoading)
                  Center(child: CircularProgressIndicator(color: Colors.teal)),

                if (!_isLoading && _response.isNotEmpty)
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '🩺 Response:\n\n$_response',
                        style: GoogleFonts.poppins(fontSize: 20),
                      ),
                    ),
                  ),
                SizedBox(height: 30),

                if (_savedQueries.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📝 Saved Queries:',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade800,
                          )),
                      SizedBox(height: 10),
                      ..._savedQueries.map((q) => Card(
                            color: Colors.white,
                            elevation: 3,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: Icon(Icons.history, color: Colors.teal),
                              title: Text(q, style: GoogleFonts.poppins(fontSize: 18)),
                            ),
                          )),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Details about ${widget.title} will be shown here.',
            style: GoogleFonts.poppins(fontSize: 22),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
