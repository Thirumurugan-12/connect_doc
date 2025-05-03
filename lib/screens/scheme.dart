import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart'; // Import Lottie

class SchemeEligibilityPage extends StatefulWidget {
  @override
  _SchemeEligibilityPageState createState() => _SchemeEligibilityPageState();
}

class _SchemeEligibilityPageState extends State<SchemeEligibilityPage>
    with TickerProviderStateMixin {
  final List<String> genders = ['male', 'female', 'other'];
  final List<String> states = ['Tamil Nadu', 'Karnataka', 'Kerala', 'Delhi', 'Maharashtra'];

  String? selectedGender;
  String? selectedState;
  int? selectedAge;
  List<Map<String, String>> schemes = [];
  String? schemesRaw;

  bool isLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: Duration(milliseconds: 700));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> fetchSchemes() async {
    if (selectedAge == null || selectedGender == null || selectedState == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill all fields.")));
      return;
    }

    setState(() {
      isLoading = true;
      schemes = [];
      schemesRaw = null;
    });

    final url = Uri.parse('https://164.52.192.233:5000/medical_schemes');
    final body = {
      "age": selectedAge,
      "gender": selectedGender,
      "state": selectedState,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final raw = data["schemes"] as String;

        schemesRaw = raw;

        final List<Map<String, String>> parsedSchemes = RegExp(r'\[(.*?)\]\((.*?)\)')
            .allMatches(raw)
            .map((match) => {
                  "name": match.group(1)!,
                  "url": match.group(2)!.replaceAll('\\', ''),
                })
            .toList();

        setState(() {
          schemes = parsedSchemes;
        });

        _fadeController.forward(from: 0);
      } else {
        print("❌ Error fetching schemes: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildDropdown<T>(String label, T? value, List<T> options, void Function(T?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          onChanged: onChanged,
          items: options
              .map((e) => DropdownMenuItem<T>(value: e, child: Text(e.toString())))
              .toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTextField(String label, int? value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        TextFormField(
          keyboardType: TextInputType.number,
          initialValue: value?.toString(),
          onChanged: (val) {
            final parsed = int.tryParse(val);
            if (parsed != null && parsed > 0 && parsed <= 120) {
              onChanged(val);
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            hintText: "Enter your age",
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('🩺 Scheme Eligibility'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: Padding(
          key: ValueKey(isLoading),
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              SizedBox(height: 10),
              buildTextField("Age", selectedAge, (val) => setState(() => selectedAge = int.tryParse(val))),
              SizedBox(height: 20),
              buildDropdown<String>('Gender', selectedGender, genders, (val) => setState(() => selectedGender = val)),
              SizedBox(height: 20),
              buildDropdown<String>('State', selectedState, states, (val) => setState(() => selectedState = val)),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: fetchSchemes,
                icon: Icon(Icons.search, size: 22),
                label: Text('Check Eligibility', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              SizedBox(height: 35),
              if (isLoading)
                Center(
                  child: Lottie.asset('assets/loading.json', width: 100, height: 100), // Add Lottie animation
                )
              else if (schemesRaw != null)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(),
                      Text("📄 Raw Scheme Response",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Linkify(
                            onOpen: (link) async {
                              final uri = Uri.parse(link.url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open URL')));
                              }
                            },
                            text: schemesRaw!,
                            style: TextStyle(fontSize: 14, fontFamily: 'Courier'),
                            linkStyle: TextStyle(color: Colors.indigo),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Text("🔗 Clickable Schemes",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      AnimatedList(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        initialItemCount: schemes.length,
                        itemBuilder: (context, index, animation) {
                          final scheme = schemes[index];
                          return SizeTransition(
                            sizeFactor: animation,
                            child: Card(
                              elevation: 3,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ListTile(
                                title: Text(
                                  scheme['name']!,
                                  style: TextStyle(
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.w600),
                                ),
                                trailing: Icon(Icons.open_in_new, color: Colors.indigo),
                                onTap: () async {
                                  final uri = Uri.parse(scheme['url']!);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open URL')));
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
