import 'package:flutter/material.dart';
import 'dart:ui'; // For blur
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentDoctorFeedPage extends StatefulWidget {
  @override
  _StudentDoctorFeedPageState createState() => _StudentDoctorFeedPageState();
}

class _StudentDoctorFeedPageState extends State<StudentDoctorFeedPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> cases = [];

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    _animationController.forward();
    fetchCases();
  }

  // ✅ Fetch cases using GET request
  Future<void> fetchCases() async {
    try {
      final url = Uri.parse('https://164.52.192.233:5000/verify_answer');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> temp = [];
        data.forEach((key, value) {
          temp.add({
            "patient_case": value["question"],
            "ai_report": value["answer"],
            "isApproved": value["verified"] == 1,
            "editedReport": null,
            "age": value['age'],
            "gender": value['gender'],
            "region": value['region'],
          });
        });

        setState(() {
          cases = temp;
        });
      } else {
        print("❌ Failed to load cases");
      }
    } catch (e) {
      print("❌ Error fetching cases: $e");
    }
  }

  // ✅ Approve a case
  void approveReport(int index) async {
    String query = cases[index]["patient_case"];
    final url = Uri.parse('https://164.52.192.233:5000/verify_answer');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "query": query,
        "flag": 1,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        cases[index]["isApproved"] = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Report Approved and Saved!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Approval failed')),
      );
    }
  }

  // ✅ Edit AI Report
  void editReportDialog(int index) {
    TextEditingController _editController =
        TextEditingController(text: cases[index]["ai_report"]);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Edit AI Report',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _editController,
          maxLines: 8,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Edit the AI diagnosis...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              final editedText = _editController.text;
              final query = cases[index]["patient_case"];

              final url =
                  Uri.parse('https://164.52.192.233:5000/verify_answer');
              final response = await http.post(
                url,
                headers: {"Content-Type": "application/json"},
                body: json.encode({
                  "query": query,
                  "flag": 1,
                  "new_answer": editedText,
                }),
              );

              if (response.statusCode == 200) {
                setState(() {
                  cases[index]["editedReport"] = editedText;
                  cases[index]["isApproved"] = true;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✏️ Edited and Saved!')),
                );
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Failed to save edit')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  // ✅ Build Case Card with filtered list
  Widget buildCaseCardFromList(List<Map<String, dynamic>> caseList, int index) {
    var caseData = caseList[index];

    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero)
            .animate(_animation),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                spreadRadius: 5,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("🩺 Patient Case:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 10),
                      Text(caseData["patient_case"],
                          style: TextStyle(fontSize: 16)),
                      Text("AGE - " + caseData["age"],
                          style: TextStyle(fontSize: 16)),
                      Text("GENDER - " + caseData["gender"],
                          style: TextStyle(fontSize: 16)),
                      Text("REGION - " + caseData["region"],
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 20),
                      Text("🤖 AI Diagnosis Report:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 10),
                      Text(
                        caseData["editedReport"] ?? caseData["ai_report"],
                        style: TextStyle(
                            fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  approveReport(cases.indexOf(caseData)),
                              icon: Icon(Icons.check_circle),
                              label: Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                foregroundColor: Colors.black,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  editReportDialog(cases.indexOf(caseData)),
                              icon: Icon(Icons.edit),
                              label: Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                foregroundColor: Colors.black,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: Text('🩺 Student Doctor Feed'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: fetchCases,
        child: cases.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: cases.where((c) => !c["isApproved"]).toList().length,
                itemBuilder: (context, index) {
                  final unapprovedCases =
                      cases.where((c) => !c["isApproved"]).toList();
                  return buildCaseCardFromList(unapprovedCases, index);
                },
              ),
      ),
    );
  }
}
