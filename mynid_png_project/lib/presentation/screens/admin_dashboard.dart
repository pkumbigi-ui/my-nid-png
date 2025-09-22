import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';
import 'login_screen.dart';
import 'admin_review_application.dart';
import 'admin_applications_list.dart';
import 'approved_application_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  static const String apiBase = "http://127.0.0.1:5000/api/admin";

  // For image slideshow
  final List<String> headerImages = [
    'assets/images/admin_bg.png',
    'assets/images/admin_bg2.png',
    'assets/images/admin_bg3.png',
    'assets/images/png_map.png',
    'assets/images/happy_user.png',
  ];
  int _currentImageIndex = 0;
  late PageController _pageController;
  double _navBarOpacity = 1.0;
  bool _isLoading = false;
  late Timer _autoScrollTimer;

  // Animation controller for pie chart
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentImageIndex);
    _pageController.addListener(() {
      if (_pageController.page == null) return;
      setState(() {
        _navBarOpacity = (1.0 - (_pageController.page! - _currentImageIndex).abs().clamp(0.0, 0.5) * 2).clamp(0.0, 1.0);
      });
    });

    // Initialize animation controller for pie chart
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(); // Repeats forever

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    // Start auto-scroll after initialization
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      int nextPage = (_currentImageIndex + 1) % headerImages.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ).then((_) {
        if (mounted) {
          setState(() {
            _currentImageIndex = nextPage;
          });
        }
      });
    });
  }

  void _navigateWithDelay(Widget page) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showResultDialog(context, "Navigation Error",
            "Failed to navigate: ${e.toString()}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 130,
        backgroundColor: Colors.blueGrey,
        flexibleSpace: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Image.asset(
                  'assets/images/national_emblem.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const Expanded(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone, color: Colors.white, size: 20),
                      SizedBox(width: 4),
                      Text("313 3000", style: TextStyle(color: Colors.white, fontSize: 12)),
                      SizedBox(width: 16),
                      Icon(Icons.email, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text("helpdesk@pngcir.gov.pg", style: TextStyle(color: Colors.white, fontSize: 12)),
                      SizedBox(width: 16),
                      Icon(Icons.public, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text("www.pngcir.gov.pg", style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Image.asset(
                  'assets/images/nid_logo.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: _buildAdminDrawer(context),
      body: Stack(
        children: [
          AnimatedOpacity(
            opacity: _isLoading ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: _isLoading,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // TOP NAVIGATION BAR
                    Container(
                      color: Colors.red.withOpacity(0.9 * _navBarOpacity.clamp(0.0, 1.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _navBarItem(Icons.home, "Home", []),
                          const SizedBox(width: 20),
                          _navBarItem(Icons.people, "Manage Users", [
                            "Manage Users",
                            "Edit User",
                          ]),
                          const SizedBox(width: 20),
                          _navBarItem(Icons.verified, "Verify Documents", [
                            "Verify Documents",
                            "Approve Document",
                          ]),
                          const SizedBox(width: 20),
                          _navBarItem(Icons.track_changes, "Track Registrations", [
                            "Track Registrations",
                            "Active Registrations",
                          ]),
                          const SizedBox(width: 20),
                          _navBarItem(Icons.assignment, "Reports & Logs", [
                            "Reports & Logs",
                            "Daily Logs",
                          ]),
                        ],
                      ),
                    ),
                    // HEADER SLIDESHOW
                    SizedBox(
                      width: double.infinity,
                      child: AspectRatio(
                        aspectRatio: 3.6,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: headerImages.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(headerImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                            Container(
                              width: double.infinity,
                              color: Colors.black54,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Welcome, Admin",
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Your central hub for managing NID operations and user data",
                                      style: TextStyle(color: Colors.white70),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(headerImages.length, (index) {
                                  return Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentImageIndex == index
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.5),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ADMIN DASHBOARD CONTENT - ROW LAYOUT FOR CARDS AND CHARTS
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT SIDE: SERVICE CARDS
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Button — Left-Aligned
                                InkWell(
                                  onTap: () {
                                    debugPrint("Admin Dashboard header tapped");
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xFF4CAF50),
                                          Color(0xFF2E7D32),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green[800]!.withOpacity(0.6),
                                          blurRadius: 4,
                                          offset: const Offset(0, 6),
                                          spreadRadius: 0,
                                        ),
                                        const BoxShadow(
                                          color: Color(0xFF81C784),
                                          blurRadius: 4,
                                          offset: Offset(0, -2),
                                          spreadRadius: 0,
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 6,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      "Admin Dashboard",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                            color: Colors.black45,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // SERVICE CARDS
                                _serviceCard(
                                  title: "Review Applications",
                                  description: "Review submitted applications and verify user data.",
                                  linkText: "Review Now",
                                  onTap: () {
                                    _navigateWithDelay(const AdminApplicationsListPage());
                                  },
                                ),
                                const SizedBox(height: 24),
                                _serviceCard(
                                  title: "Approved Applications",
                                  description: "View all approved applications with NID numbers",
                                  linkText: "View List",
                                  onTap: () {
                                    _navigateWithDelay(const ApprovedApplicationsScreen());
                                  },
                                ),
                                const SizedBox(height: 24),
                                _serviceCard(
                                  title: "Send Alerts to Users",
                                  description: "Broadcast system alerts or notifications to all users.",
                                  linkText: "Send Alert",
                                  onTap: () {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    Future.delayed(const Duration(seconds: 1), () {
                                      if (mounted) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        _fetchData(context, "/track");
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(height: 24),
                                _serviceCard(
                                  title: "Review Lost NID Requests",
                                  description: "Process reports of lost or stolen NID cards.",
                                  linkText: "Process Now",
                                  onTap: () {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    Future.delayed(const Duration(seconds: 1), () {
                                      if (mounted) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        _fetchData(context, "/reports");
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(height: 32),
                                _serviceCard(
                                  title: "Schedule Appointments",
                                  description: "Assign or reschedule appointments for users.",
                                  linkText: "Schedule",
                                  onTap: () {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    Future.delayed(const Duration(seconds: 1), () {
                                      if (mounted) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        _fetchData(context, "/schedule");
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          // SPACER BETWEEN CARDS AND CHARTS
                          const SizedBox(width: 30),
                          // RIGHT SIDE: WELCOME CARD + CHARTS
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                // ✅ WELCOME MESSAGE (No Card)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center, // Center align
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center, // Center horizontally
                                        children: [
                                          Icon(Icons.waving_hand, color: Colors.purple, size: 28),
                                          SizedBox(width: 12),
                                          Text(
                                            "Welcome to the Admin Dashboard",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black, // Black title since background is white
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        "This dashboard gives you full access to manage the National Identification (NID) system. "
                                            "From here, you can review and approve citizen applications, verify documents, and handle "
                                            "lost or duplicate requests. You can also schedule appointments, send important alerts, "
                                            "and track system-wide progress. Use the tools provided to maintain accuracy, security, "
                                            "and efficiency in delivering reliable NID services to the people of Papua New Guinea.",
                                        textAlign: TextAlign.center, // Centered text
                                        style: TextStyle(
                                          color: Colors.black87, // Dark text on white background
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),
                                // 🎯 LIVE VISUALIZATION HEADER — STYLED AS REQUESTED
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: const Text(
                                    "Live Visualization Graphs",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange, // ✅ Orange color
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 3,
                                  color: Colors.orange, // ✅ Bold underline
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                ),
                                const SizedBox(height: 20),
                                // 📈 LIVE LINE CHART: Mobilization Curve
                                Card(
                                  elevation: 4,
                                  color: Colors.grey[900],
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "NID Registration Progress (2014-2025)",
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Tracking population growth vs. registration completion",
                                          style: TextStyle(fontSize: 12, color: Colors.white70),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          height: 300,
                                          child: _buildMobilizationChart(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // 🥧 INTERACTIVE PIE CHART: Age Group Distribution (3D EFFECT)
                                Card(
                                  elevation: 4,
                                  color: Colors.grey[900],
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Age Distribution of Registered Citizens",
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Demographic breakdown of NID registrations",
                                          style: TextStyle(fontSize: 12, color: Colors.white70),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          height: 250,
                                          child: _buildAgeDistributionPieChart(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ✅ Fixed & Fully Responsive Footer (Spans Entire Screen)
                    Container(
                      width: double.infinity,
                      color: Colors.grey[850], // dark background
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 60),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ABOUT COLUMN
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.green[400],
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "G",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      "About",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "The National Identity Authority (NIA) manages the National ID system in Papua New Guinea, providing secure and verifiable identification for citizens and residents.",
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // CONTACT COLUMN
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Contact",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "National Identity Authority\n"
                                      "PO Box 483, Madang\n"
                                      "Papua New Guinea\n"
                                      "Phone: +675 422 9937\n"
                                      "Email: helpdesk@nid.gov.pg\n"
                                      "Website: www.nid.gov.pg",
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // SUPPORT COLUMN
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Support",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Copyright © 2025 National Identity Authority\nAll Rights Reserved",
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Opening support page...")),
                                    );
                                  },
                                  child: const Text(
                                    "Support",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 13,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
                      SizedBox(height: 12),
                      Text("Loading...", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _navBarItem(IconData icon, String label, List<String> dropdownItems) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Theme(
        data: Theme.of(context).copyWith(
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: PopupMenuButton<String>(
          offset: const Offset(0, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          itemBuilder: (context) {
            return dropdownItems.map((item) {
              return PopupMenuItem<String>(
                value: item,
                height: 40,
                child: Text(item, style: const TextStyle(fontSize: 14)),
              );
            }).toList();
          },
          onSelected: (value) {
            switch (value) {
              case "Manage Users":
                _fetchData(context, "/users");
                break;
              case "Edit User":
                _fetchData(context, "/user/edit");
                break;
              case "Verify Documents":
                _fetchData(context, "/verify");
                break;
              case "Approve Document":
                _fetchData(context, "/document/approve");
                break;
              case "Track Registrations":
                _fetchData(context, "/track");
                break;
              case "Active Registrations":
                _fetchData(context, "/status/active");
                break;
              case "Reports & Logs":
                _fetchData(context, "/reports");
                break;
              case "Daily Logs":
                _fetchData(context, "/logs/daily");
                break;
              default:
                debugPrint("Selected: $value");
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue[900]!.withOpacity(0.6),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.red[300]!,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                if (dropdownItems.isNotEmpty)
                  const SizedBox(width: 4),
                if (dropdownItems.isNotEmpty)
                  const Icon(Icons.arrow_drop_down, size: 18, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Admin User"),
            accountEmail: const Text("admin@nid.png"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Icon(Icons.admin_panel_settings, size: 48, color: Colors.green[800]),
              ),
            ),
            decoration: const BoxDecoration(color: Colors.deepPurple),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manage Users'),
            onTap: () => _fetchData(context, "/users"),
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Applications'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminApplicationsListPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified),
            title: const Text('Document Verification'),
            onTap: () => _fetchData(context, "/verify"),
          ),
          ListTile(
            leading: const Icon(Icons.track_changes),
            title: const Text('Track Registrations'),
            onTap: () => _fetchData(context, "/track"),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Appointments'),
            onTap: () => _fetchData(context, "/appointments"),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () => _fetchData(context, "/notifications"),
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Reports'),
            onTap: () => _fetchData(context, "/reports"),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('System Settings'),
            onTap: () => _fetchData(context, "/settings"),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("Support", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help Center'),
            onTap: () => _fetchData(context, "/help"),
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Documentation'),
            onTap: () => _fetchData(context, "/docs"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
            },
          ),
        ],
      ),
    );
  }

  // ✅ IDENTICAL TO USER DASHBOARD SERVICE CARD - BUTTON COLOR CHANGED TO LIGHT GREEN
  Widget _serviceCard({
    required String title,
    required String description,
    required String linkText,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 4, color: Colors.lightBlue),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onTap,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: onTap,
                  child: Container(
                    width: 140,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade500, Colors.green.shade700],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.9),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        linkText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchData(BuildContext context, String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse("$apiBase$endpoint"),
      ).timeout(const Duration(seconds: 30)); // Added timeout
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (endpoint == "/users") {
          _showUsersDialog(context, data);
        } else if (endpoint == "/reports") {
          _showReportsDialog(context, data);
        } else {
          _showResultDialog(context, "Success", data.toString());
        }
      } else {
        _showResultDialog(context, "Error", "Failed: ${response.statusCode}");
      }
    } on TimeoutException {
      _showResultDialog(context, "Error", "Request timed out");
    } on http.ClientException catch (e) {
      _showResultDialog(context, "Connection Error", e.message);
    } catch (e) {
      _showResultDialog(context, "Error", e.toString());
    }
  }

  void _showUsersDialog(BuildContext context, Map<String, dynamic> data) {
    List<dynamic> users = [];
    if (data['status'] == 'success' && data['users'] != null) {
      users = data['users'] as List<dynamic>;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("User Management"),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Given Name", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Surname", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Role", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: users.map<DataRow>((user) {
                  return DataRow(cells: [
                    DataCell(Text(user['id']?.toString() ?? 'N/A')),
                    DataCell(Text(user['email']?.toString() ?? 'N/A')),
                    DataCell(Text(user['given_name']?.toString() ?? 'N/A')),
                    DataCell(Text(user['surname']?.toString() ?? 'N/A')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (user['role'] == 'admin') ? Colors.blue : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user['role']?.toString().toUpperCase() ?? 'N/A',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () => _editUser(user),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                            onPressed: () => _deleteUser(user['id']),
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
        actions: [
          ElevatedButton(onPressed: () => _addNewUser(), child: const Text("Add New User")),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  void _showReportsDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("System Reports"),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Metric", style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text("Value", style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                if (data['reports'] != null && data['reports'] is Map)
                  ..._buildReportRows(data['reports'] as Map<String, dynamic>),
                DataRow(cells: [
                  const DataCell(Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(
                    data['status']?.toString() ?? 'Unknown',
                    style: TextStyle(
                      color: data['status'] == 'success' ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ]),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  List<DataRow> _buildReportRows(Map<String, dynamic> reports) {
    return reports.entries.map((entry) {
      return DataRow(cells: [
        DataCell(Text(_formatKey(entry.key))),
        DataCell(Text(entry.value.toString())),
      ]);
    }).toList();
  }

  String _formatKey(String key) {
    return key.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  void _editUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit User"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(initialValue: user['email']?.toString(), decoration: const InputDecoration(labelText: "Email")),
              TextFormField(initialValue: user['given_name']?.toString(), decoration: const InputDecoration(labelText: "Given Name")),
              TextFormField(initialValue: user['surname']?.toString(), decoration: const InputDecoration(labelText: "Surname")),
              DropdownButtonFormField<String>(
                value: user['role']?.toString() ?? 'user',
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (value) {},
                decoration: const InputDecoration(labelText: "Role"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Save")),
        ],
      ),
    );
  }

  void _deleteUser(dynamic userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete User"),
        content: const Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _addNewUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New User"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(decoration: const InputDecoration(labelText: "Email")),
              TextFormField(decoration: const InputDecoration(labelText: "Given Name")),
              TextFormField(decoration: const InputDecoration(labelText: "Surname")),
              TextFormField(decoration: const InputDecoration(labelText: "Password"), obscureText: true),
              DropdownButtonFormField<String>(
                value: 'user',
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (value) {},
                decoration: const InputDecoration(labelText: "Role"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Add User")),
        ],
      ),
    );
  }

  void _showResultDialog(BuildContext context, String title, String data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(data)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  // 📈 CHART 1: Mobilization Line Chart
  Widget _buildMobilizationChart() {
    final List<ChartData> data = [
      ChartData('2014', 8226891, 14171, 8226891, 0),
      ChartData('2015', 8188440, 121711, 8188440, 0),
      ChartData('2016', 8450470, 221152, 8419651, 0),
      ChartData('2017', 8720885, 378222, 8565009, 0),
      ChartData('2018', 8959954, 770493, 8485751, 0),
      ChartData('2019', 9287952, 1444937, 8135975, 0),
      ChartData('2020', 9585167, 1947855, 7968158, 0),
      ChartData('2021', 9891892, 2491599, 7776946, 0),
      ChartData('2022', 10217172, 2855271, 7787717, 0),
      ChartData('2023', 4703712, 2855271, 4703712, 4703712),
      ChartData('2024', 863717, 2855271, 863717, 863717),
      ChartData('2025', 412178, 2855271, 412178, 412178),
    ];
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelStyle: const TextStyle(color: Colors.white),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        labelStyle: const TextStyle(color: Colors.white),
        numberFormat: NumberFormat("#,##0,000"),
        majorGridLines: const MajorGridLines(color: Colors.white24),
      ),
      legend: Legend(
        isVisible: true,
        textStyle: const TextStyle(color: Colors.white),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <LineSeries<ChartData, String>>[
        LineSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.year,
          yValueMapper: (ChartData data, _) => data.population,
          name: 'Population',
          color: Colors.blue,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
        LineSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.year,
          yValueMapper: (ChartData data, _) => data.annualRegistration,
          name: 'Annual Registration',
          color: Colors.green,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
        LineSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.year,
          yValueMapper: (ChartData data, _) => data.balance,
          name: 'Balance',
          color: Colors.purple,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
        LineSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.year,
          yValueMapper: (ChartData data, _) => data.toRegister,
          name: 'To Register',
          color: Colors.orange,
          markerSettings: const MarkerSettings(isVisible: true),
          dashArray: <double>[5, 5],
        ),
      ],
      backgroundColor: Colors.transparent,
    );
  }

  // 🥧 CHART 2: Age Group Pie Chart (3D EFFECT — EXPLODED SLICES)
  Widget _buildAgeDistributionPieChart() {
    final List<AgeGroupData> ageGroups = [
      AgeGroupData('0–18', 25, Colors.blue.shade500),
      AgeGroupData('19–35', 35, Colors.green.shade500),
      AgeGroupData('36–50', 20, Colors.orange.shade500),
      AgeGroupData('51–65', 10, Colors.purple.shade500),
      AgeGroupData('65+', 10, Colors.red.shade500),
    ];
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SfCircularChart(
          legend: Legend(
            isVisible: true,
            textStyle: const TextStyle(color: Colors.white),
            overflowMode: LegendItemOverflowMode.wrap,
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CircularSeries>[
            PieSeries<AgeGroupData, String>(
              dataSource: ageGroups,
              xValueMapper: (AgeGroupData data, _) => data.name,
              yValueMapper: (AgeGroupData data, _) => data.percentage,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(color: Colors.white),
              ),
              pointColorMapper: (AgeGroupData data, _) => data.color,

              // ✅ TRUE 3D EFFECT — USING EXPLODE (Compatible with all versions)
              explode: true,                 // Makes slices pop out
              explodeOffset: '10%',          // How far they pop out
              startAngle: 0,
              endAngle: (360 * _animation.value).toInt(), // ✅ Animated rotation + int cast
              enableTooltip: true,
              animationDuration: 2000,
            ),
          ],
          backgroundColor: Colors.transparent,
        );
      },
    );
  }
}

// 📊 DATA MODELS FOR CHARTS
class ChartData {
  final String year;
  final int population;
  final int annualRegistration;
  final int balance;
  final int toRegister;
  ChartData(this.year, this.population, this.annualRegistration, this.balance, this.toRegister);
}

class AgeGroupData {
  final String name;
  final int percentage;
  final Color color;
  AgeGroupData(this.name, this.percentage, this.color);
}