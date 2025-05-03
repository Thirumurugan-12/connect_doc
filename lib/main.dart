import 'package:connect_doc/screens/health.dart';
import 'package:connect_doc/screens/realtimefeed.dart';
import 'package:connect_doc/screens/scheme.dart';
import 'package:connect_doc/screens/speaking.dart';
import 'package:connect_doc/screens/student_doctor_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

void main() {
  runApp(VasooApp());
}

class VasooApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vasoo - Healthcare for All',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/features': (context) => FeaturesPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/feature/')) {
          final featureTitle =
              settings.name!.replaceFirst('/feature/', '').replaceAll('-', ' ');
          return MaterialPageRoute(
            builder: (context) => FeatureDetailPage(title: featureTitle),
          );
        }
        return null;
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HeroSection(),
              ProblemSection(),
              SolutionSection(),
              UsersSection(),
              CTASection(),
            ],
          ),
        ),
      ),
    );
  }
}

class HeroSection extends StatefulWidget {
  @override
  _HeroSectionState createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: Container(
        padding: EdgeInsets.all(50),
        child: Column(
          children: [
            Text('Vasoo',
                style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade900)),
            SizedBox(height: 10),
            Text('Voice-powered Rural Healthcare Assistant',
                style: TextStyle(fontSize: 22, color: Colors.teal.shade700)),
          ],
        ),
      ),
    );
  }
}

class ProblemSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          Icon(Icons.health_and_safety, size: 50, color: Colors.redAccent),
          SizedBox(height: 10),
          Text('The Problem',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(
            'Millions in rural India lack access to affordable healthcare, timely information, and government health schemes.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class SolutionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          Icon(Icons.lightbulb_outline, size: 50, color: Colors.amber),
          SizedBox(height: 10),
          Text('Our Solution',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(
            'Vasoo connects rural families, frontline health workers, and student doctors through a voice-first AI platform, bridging medical gaps with personalized care, scheme discovery, and real-time assistance.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class UsersSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          Icon(Icons.group, size: 50, color: Colors.deepPurple),
          SizedBox(height: 10),
          Text('Who We Help',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(
            'Rural families, ASHA/ANM workers, and student medical interns.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class CTASection extends StatefulWidget {
  @override
  _CTASectionState createState() => _CTASectionState();
}

class _CTASectionState extends State<CTASection> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 50),
      child: GestureDetector(
        onTap: () {
          setState(() {
            isPressed = !isPressed;
          });
          Navigator.pushNamed(context, '/features');
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isPressed ? Colors.teal.shade800 : Colors.teal.shade600,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: isPressed ? Colors.teal.shade500 : Colors.teal.shade700,
                blurRadius: 10,
                offset: Offset(0, 10),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Text(
            'View Features',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class FeaturesPage extends StatelessWidget {
  final List<Map<String, dynamic>> features = [
    {
      'title': 'Multilingual Voice Interface',
      'icon': Icons.language,
      'color': Colors.deepPurple,
    },
    {
      'title': 'AI Health Query Resolution',
      'icon': Icons.health_and_safety,
      'color': Colors.redAccent,
    },
    {
      'title': 'Student Doctor Connect',
      'icon': Icons.people_alt,
      'color': Colors.blueAccent,
    },
    {
      'title': 'Scheme Discovery & Eligibility Matching',
      'icon': Icons.assignment_turned_in,
      'color': Colors.green,
    },
    {
      'title': 'Offline IVR Support',
      'icon': Icons.phone_in_talk,
      'color': Colors.orange,
    },
    {
      'title': 'Real-Time Doctor Guidelines Feed',
      'icon': Icons.update,
      'color': Colors.teal,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Key Features'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: features.map((feature) {
              final featureTitle = feature['title'];
              final featureRouteName =
                  featureTitle.toLowerCase().replaceAll(' ', '-');

              return FeatureCard(
                title: featureTitle,
                icon: feature['icon'],
                color: feature['color'],
                onTap: () {
                  if (featureTitle == 'Multilingual Voice Interface') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FeatureDetailPage(title: featureTitle),
                      ),
                    );
                  } else if (featureTitle == 'Student Doctor Connect') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentDoctorFeedPage(),
                      ),
                    );
                  } else if (featureTitle ==
                      'Real-Time Doctor Guidelines Feed') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RealTimeFeedPage(),
                      ),
                    );
                  } else if (featureTitle ==
                      'Scheme Discovery & Eligibility Matching') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SchemeEligibilityPage(),
                      ),
                    );
                  } else if (featureTitle ==
                      'AI Health Query Resolution') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HealthQueryPage(),
                      ),
                    );
                  }
                  else {
                    Navigator.pushNamed(context, '/feature/$featureRouteName');
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const FeatureCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {},
      onExit: (_) {},
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, size: 28, color: color),
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
