import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'admin_review_application.dart';
import 'application_screen.dart'; // Make sure this file exists

class ApprovedApplicationsScreen extends StatefulWidget {
  const ApprovedApplicationsScreen({super.key});

  @override
  State<ApprovedApplicationsScreen> createState() => _ApprovedApplicationsScreenState();
}

class _ApprovedApplicationsScreenState extends State<ApprovedApplicationsScreen> {
  List<dynamic> applications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApprovedApplications();
  }

  Future<void> _fetchApprovedApplications() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/admin/applications?status=approved'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body); // ← Decode as Map
        final List<dynamic> applicationsList = data['applications'] as List<dynamic>;

        setState(() {
          applications = applicationsList;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load approved applications: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading applications: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approved Applications'),
        backgroundColor: Colors.green[700],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : applications.isEmpty
          ? const Center(child: Text('No approved applications yet'))
          : ListView.builder(
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final app = applications[index] as Map<String, dynamic>?;
          if (app == null) return const SizedBox.shrink();

          final String givenNames = app['given_names']?.toString() ?? 'N/A';
          final String familyName = app['family_name']?.toString() ?? 'N/A';
          final String nidNumber = app['nid_number']?.toString() ?? 'Not Assigned';
          final String approvedAt = app['approved_at']?.toString() ?? 'Unknown';
          final String officerName = app['officer_name']?.toString() ?? 'N/A';

          return Card(
            margin: const EdgeInsets.all(12), // Increased margin for better spacing
            elevation: 5, // Added elevation for card depth
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20), // Increased padding for better spacing
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NID #$nidNumber',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 12), // Increased spacing
                  Text('Name: $givenNames $familyName'),
                  const SizedBox(height: 8), // Added spacing
                  Text('Approved: $approvedAt'),
                  const SizedBox(height: 8), // Added spacing
                  Text('Officer: $officerName'),
                  const SizedBox(height: 16), // Increased spacing before button
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green[800]!.withOpacity(0.5),
                            offset: const Offset(0, 8), // Shadow position for 3D effect
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors.green[200]!,
                            offset: const Offset(0, -2), // Highlight effect
                            blurRadius: 2,
                            spreadRadius: 0.5,
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.green[500]!,
                            Colors.green[700]!,
                          ],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ApplicationDetailScreen(application: app),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}