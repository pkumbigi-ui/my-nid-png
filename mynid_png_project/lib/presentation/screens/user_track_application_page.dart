// user_track_application_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserTrackApplicationPage extends StatefulWidget {
  final int userId;

  const UserTrackApplicationPage({super.key, required this.userId});

  @override
  State<UserTrackApplicationPage> createState() => _UserTrackApplicationPageState();
}

class _UserTrackApplicationPageState extends State<UserTrackApplicationPage> {
  List<Map<String, dynamic>> applications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _loading = true;
    });

    try {
      // 🔁 Replace with your actual IP (e.g., 192.168.1.5 or localhost if using emulator)
      final url = Uri.parse('http://127.0.0.1:5000/application/my-applications?user_id=${widget.userId}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            applications = List<Map<String, dynamic>>.from(data['applications']);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No applications found.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to connect to server.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track Your NID Application",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : applications.isEmpty
          ? const Center(child: Text("You have not submitted any application yet."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final app = applications[index];
          final status = app['status']?.toString().toLowerCase() ?? 'pending';
          final reason = app['rejection_reason']?.toString().trim();

          IconData icon;
          Color color;

          if (status == 'approved') {
            icon = Icons.check_circle;
            color = Colors.green;
          } else if (status == 'rejected') {
            icon = Icons.cancel;
            color = Colors.red;
          } else {
            icon = Icons.access_time;
            color = Colors.orange;
          }

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Application #${app['id']}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(icon, color: color, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        status.capitalize(),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (status == 'rejected' && reason != null && reason.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      "Reason:",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reason,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    "Submitted on: ${_formatDate(app['created_at'])}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
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

  String _formatDate(String? isoDate) {
    if (isoDate == null) return "Unknown";
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return "Invalid Date";
    }
  }
}

// Helper extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}