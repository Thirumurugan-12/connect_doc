import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';

class HealthQueryPage extends StatefulWidget {
  @override
  _HealthQueryPageState createState() => _HealthQueryPageState();
}

class _HealthQueryPageState extends State<HealthQueryPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  bool isLoading = false;

  Future<void> sendMessage(String query) async {
    setState(() {
      isLoading = true;
      messages.add({"sender": "user", "message": query});
    });

    final response = await http.post(
      Uri.parse('https://164.52.192.233:5000/biomed_chat'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"query": query}),
    );

    await Future.delayed(Duration(milliseconds: 600)); // Simulated typing

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final answer =
          responseBody['response']?.toString() ?? "Sorry, I couldn't find an answer.";
      setState(() {
        messages.add({"sender": "bot", "message": answer});
        isLoading = false;
      });
    } else {
      setState(() {
        messages.add({"sender": "bot", "message": "Something went wrong. Please try again."});
        isLoading = false;
      });
    }
  }

  Widget buildMessage(String message, String sender) {
    final isUser = sender == "user";
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: isUser ? Radius.circular(20) : Radius.circular(0),
            bottomRight: isUser ? Radius.circular(0) : Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 2),
            )
          ],
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget buildChat() {
    return ListView.builder(
      itemCount: messages.length,
      reverse: false,
      physics: BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final msg = messages[index];
        return buildMessage(msg["message"] ?? "", msg["sender"] ?? "bot");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Color(0xFFF6F8FC),
      appBar: AppBar(
        title: Text("AI Health Assistant 🤖"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 3,
      ),
      body: Column(
        children: [
          Expanded(
            child: buildChat(),
          ),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Lottie.asset(
                'assets/loading.json',
                height: 100,
                width: 100,
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        sendMessage(value.trim());
                        _controller.clear();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Ask a health question...",
                      filled: true,
                      fillColor: isDark ? Colors.grey[900] : Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    if (_controller.text.trim().isNotEmpty) {
                      sendMessage(_controller.text.trim());
                      _controller.clear();
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.send, color: Colors.white),
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
