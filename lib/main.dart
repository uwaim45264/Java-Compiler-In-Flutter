import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(JavaCompilerApp());
}

class JavaCompilerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Java Compiler',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: Color(0xFFECEFF1),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CompilerHomePage(),
    );
  }
}

class CompilerHomePage extends StatefulWidget {
  @override
  _CompilerHomePageState createState() => _CompilerHomePageState();
}

class _CompilerHomePageState extends State<CompilerHomePage> {
  final TextEditingController _codeController = TextEditingController();
  String _output = '';
  bool _isLoading = false;

  Future<void> _compileCode() async {
    setState(() {
      _isLoading = true;
      _output = '';
    });

    final String code = _codeController.text;
    const String apiUrl = 'https://api.jdoodle.com/v1/execute';

    final Map<String, dynamic> requestBody = {
      'clientId': '10f7a63f2653b6671de8c333927fa2d4',
      'clientSecret': 'df871fead766450b87b19259d3a7522203385c9816d641e285a46af1db3e6f98',
      'script': code,
      'language': 'java',
      'versionIndex': '4',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          _output = result['output'] ?? 'No output';
          if (result['error'] != null) {
            _output = 'Error: ${result['error']}';
          }
        });
      } else {
        setState(() {
          _output = 'Failed to compile. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _output = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Java Compiler',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.amber[300],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black87),
            onPressed: () {
              _codeController.clear();
              setState(() {
                _output = '';
              });
            },
            tooltip: 'Reset Code',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Code Here',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _codeController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(16),
                    border: InputBorder.none,
                    hintText:
                    'public class Main {\n    public static void main(String[] args) {\n        System.out.println("Hello, World!");\n    }\n}',
                    hintStyle: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: _isLoading ? null : _compileCode,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.amber[600],
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    'Run It!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Output',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: SelectableText(
                        _output.isEmpty ? 'Output will appear here...' : _output,
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 14,
                          color: _output.startsWith('Error')
                              ? Colors.red[600]
                              : Colors.green[800],
                          height: 1.4,
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
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}