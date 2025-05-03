import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RealTimeFeedPage extends StatefulWidget {
  @override
  _RealTimeFeedPageState createState() => _RealTimeFeedPageState();
}

class _RealTimeFeedPageState extends State<RealTimeFeedPage> {
  List<Map<String, dynamic>> approvedCases = [];

  @override
  void initState() {
    super.initState();
    fetchApprovedCases();
  }

  // ✅ Fetch approved cases from API
  Future<void> fetchApprovedCases() async {
    try {
      final url = Uri.parse('https://164.52.192.233:5000/verify_answer');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> temp = [];
        data.forEach((key, value) {
          if (value["verified"] == 1) {
            temp.add({
              "patient_case": value["question"],
              "ai_report": value["answer"],
              "isApproved": true,
              "student_name": value["student_name"], // Student's name
              "upvotes": 0,
              "downvotes": 0,
              "age": value['age'],
              "gender": value['gender'],
              "region": value['region'],
            });
          }
        });

        setState(() {
          approvedCases = temp;
        });
      } else {
        print("❌ Failed to load approved cases");
      }
    } catch (e) {
      print("❌ Error fetching approved cases: $e");
    }
  }

  // ✅ Handle upvote and downvote
  void handleVote(int index, bool isUpvote) {
    setState(() {
      if (isUpvote) {
        approvedCases[index]["upvotes"] =
            (approvedCases[index]["upvotes"] ?? 0) + 1;
      } else {
        approvedCases[index]["downvotes"] =
            (approvedCases[index]["downvotes"] ?? 0) + 1;
      }
    });
  }

  // ✅ Build Case Card for the approved feed
  Widget buildCaseCardFromList(List<Map<String, dynamic>> caseList, int index) {
    var caseData = caseList[index];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 3,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🩺 Patient Case:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            Text(caseData["patient_case"], style: TextStyle(fontSize: 16)),
            Text("AGE - " + caseData["age"], style: TextStyle(fontSize: 16)),
            Text("GENDER - " + caseData["gender"],
                style: TextStyle(fontSize: 16)),
            Text("REGION - " + caseData["region"],
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text("🤖 AI Diagnosis Report:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            Text(caseData["ai_report"],
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            SizedBox(height: 20),
            Text("👩‍⚕️ Approved by: ${caseData["student_name"]}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up, color: Colors.green),
                      onPressed: () => handleVote(index, true),
                    ),
                    Text('${caseData["upvotes"] ?? 0}'),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_down, color: Colors.red),
                      onPressed: () => handleVote(index, false),
                    ),
                    Text('${caseData["downvotes"] ?? 0}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Real-time live feed builder
  Widget buildRealTimeFeed() {
    return ListView.builder(
      itemCount: approvedCases.length,
      itemBuilder: (context, index) {
        return buildCaseCardFromList(approvedCases, index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: Text('🩺 Real-Time Feed'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: fetchApprovedCases,
        child: approvedCases.isEmpty
            ? Center(child: CircularProgressIndicator())
            : buildRealTimeFeed(),
      ),
    );
  }
}
