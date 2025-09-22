import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApplicationsScreen extends StatefulWidget {
  final String userId;

  const ApplicationsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ApplicationsScreenState createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  List<dynamic> applications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  // In your AdminApplicationsListPage, modify the API call to only fetch pending applications
  Future<void> _fetchApplications() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/admin/applications'),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Add this debug line

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded data: $data'); // Add this debug line

        setState(() {
          applications = data['applications'] ?? []; // Add null check
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load applications');
      }
    } catch (e) {
      print('Error details: $e'); // Add this debug line
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My NID Applications'),
        backgroundColor: Colors.blue[700],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : applications.isEmpty
          ? Center(child: Text('No applications submitted yet'))
          : ListView.builder(
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final app = applications[index];
          return ApplicationCard(application: app);
        },
      ),
    );
  }
}

class ApplicationCard extends StatelessWidget {
  final Map<String, dynamic> application;

  const ApplicationCard({Key? key, required this.application}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Application #${application['id']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Name: ${application['given_names']} ${application['family_name']}'),
            Text('Status: ${application['status'] ?? 'Pending'}'),
            Text('Submitted: ${application['submission_date']}'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // View application details
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ApplicationDetailScreen(application: application),
                  ),
                );
              },
              child: Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }
}

class ApplicationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> application;

  const ApplicationDetailScreen({Key? key, required this.application}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Application Details')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Application Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              // Add all application fields here
            ],
          ),
        ),
      ),
    );
  }
}