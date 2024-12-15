import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat Facts',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Random Cat Facts'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> facts = [];
  List<String> factHistory = [];
  int currentIndex = -1;

  Future<void> fetchFact() async {
    const url = 'https://catfact.ninja/fact';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          facts.add(data['fact']);
          factHistory.add(data['fact']);
          currentIndex = facts.length - 1;
        });
      } else {
        throw Exception('Failed to load fact');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void copyToClipboard() {
    if (currentIndex >= 0 && currentIndex < facts.length) {
      Clipboard.setData(ClipboardData(text: facts[currentIndex]));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fact copied to clipboard!')),
      );
    }
  }

  void showPreviousFact() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No previous facts available.')),
      );
    }
  }

  void navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage(factHistory: factHistory),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchFact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: navigateToHistory,
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: currentIndex >= 0 && currentIndex < facts.length
                      ? Text(
                    facts[currentIndex],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  )
                      : const CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: showPreviousFact,
                  child: const Text('Previous Fact'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: copyToClipboard,
                  child: const Text('Copy Fact'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: fetchFact,
                  child: const Text('New Fact'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  final List<String> factHistory;

  const HistoryPage({super.key, required this.factHistory});

  void copyFact(String fact, BuildContext context) {
    Clipboard.setData(ClipboardData(text: fact));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fact copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Fact History',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: factHistory.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              factHistory[index],
              style: const TextStyle(color: Colors.white),
            ),
            leading: const Icon(Icons.pets, color: Colors.white),
            trailing: IconButton(
              icon: const Icon(Icons.copy, color: Colors.white),
              onPressed: () => copyFact(factHistory[index], context),
            ),
            tileColor: Colors.black.withOpacity(0.5),
          );
        },
      ),
    );
  }
}
