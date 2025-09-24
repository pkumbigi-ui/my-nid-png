import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import 'ApplyFormPage.dart';
import 'user_track_application_page.dart';

// News Service (unchanged)
class NewsService {
  static List<String> getNewsHeadlines() {
    return [
      "PIF leaders plant special trees to mark their attendance at PNG's 50th Independence Anniversary",
      "Prime Minister welcomes Duke of Edinburgh and Global Leaders at 50th Independence Gala",
      "People's Balus touches down at Jackson's International",
      "Nation on edge, Experts warn of vicious spiral in political violence",
      "Kokote to watch NRL grand final as parting gift",
    ];
  }
}

// NEWS CARD SECTION WITH CONTINUOUS SCROLLING
class NewsCardSection extends StatefulWidget {
  const NewsCardSection({super.key});

  @override
  State<NewsCardSection> createState() => _NewsCardSectionState();
}

class _NewsCardSectionState extends State<NewsCardSection> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> newsCards = [
    {
      "title": "PIF leaders plant special trees to mark their attendance at PNG's 50th Independence Anniversary",
      "description":
      "New centers now operational in Port Moresby, Lae, and Madang to improve access.",
      "image": "assets/images/news_postcourier1.png",
      "url": "https://www.postcourier.com.pg/"
    },
    {
      "title": "Prime Minister welcomes Duke of Edinburgh and Global Leaders at 50th Independence Gala",
      "description":
      "PRIME Minister James Marape hosted a 50th Independence Gala Dinner for the Duke of Edinburgh and all the important dignitaries that came to PNG today, yesterday and a few days ago to celebrate the country's golden jubilee.",
      "image": "assets/images/news_postcourier2.png",
      "url": "https://www.postcourier.com.pg/"
    },
    {
      "title": "People's Balus touches down at Jackson's International",
      "description":
      "The People's Balus has landed at Jackson's International Airport. The plane was officially welcomed with a formal water salute.",
      "image": "assets/images/news_postcourier3.png",
      "url": "https://www.postcourier.com.pg/"
    },
    {
      "title": "Nation on edge, Experts warn of vicious spiral in political violence",
      "description":
      "WASHINGTON: The assassination of right-wing influencer Charlie Kirk marks a watershed moment in a surge of US political violence, one that some experts fear will inflame an already-fractured country and inspire more unrest.",
      "image": "assets/images/news_postcourier4.png",
      "url": "https://www.postcourier.com.pg/"
    },
    {
      "title": "Kokote to watch NRL grand final as parting gift",
      "description":
      "As just reward for his services towards delivering the Snax Lae Tigers 5th Digicel Exxon Mobil Cup premiership yesterday, franchise owner Ian Chow has gifted the journeyman with a trip to watch the 2025 NRL Grand Final.",
      "image": "assets/images/news_postcourier5.png",
      "url": "https://www.postcourier.com.pg/"
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_scrollController.hasClients && mounted) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        if (currentScroll >= maxScroll - 200) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(
            currentScroll + 200,
            duration: const Duration(milliseconds: 3000),
            curve: Curves.linear,
          );
        }
        _startAutoScroll();
      }
    });
  }

  Future<void> _launchURL(String url) async {
    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open website")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.campaign, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text(
              "Latest News from Post-Courier",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: newsCards.length * 2,
            itemBuilder: (context, index) {
              final cardIndex = index % newsCards.length;
              final card = newsCards[cardIndex];
              return GestureDetector(
                onTap: () => _launchURL(card["url"]!),
                child: Container(
                  width: 190,
                  margin: const EdgeInsets.only(right: 8),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(card["image"]!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card["title"]!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                card["description"]!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: const Center(child: Text('Contact Information')),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About MyNID PNG')),
      body: const Center(child: Text('About MyNID PNG Content')),
    );
  }
}

// Sub-pages for dropdown items (unchanged)
class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Frequently Asked Questions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text('How do I apply for an NID?'),
            subtitle: Text('You can apply online through the MyNID portal or visit your nearest NID office.'),
          ),
          ListTile(
            title: Text('What documents do I need?'),
            subtitle: Text('Birth certificate, proof of residence, and supporting identification documents.'),
          ),
          ListTile(
            title: Text('How long does it take to get my NID?'),
            subtitle: Text('Processing typically takes 2-4 weeks after application submission.'),
          ),
        ],
      ),
    );
  }
}

class UserGuidePage extends StatelessWidget {
  const UserGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Guide')),
      body: const Center(child: Text('Step-by-step guide to using MyNID services')),
    );
  }
}

class TechnicalSupportPage extends StatelessWidget {
  const TechnicalSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Technical Support')),
      body: const Center(child: Text('Technical assistance for system issues')),
    );
  }
}

class OfficeLocationsPage extends StatelessWidget {
  const OfficeLocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Office Locations')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Port Moresby Office'),
            subtitle: Text('Waigani Drive, Port Moresby, NCD'),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Lae Office'),
            subtitle: Text('Second Street, Lae, Morobe Province'),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Madang Office'),
            subtitle: Text('Coastwatchers Avenue, Madang'),
          ),
        ],
      ),
    );
  }
}

class MissionPage extends StatelessWidget {
  const MissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Our Mission')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'To provide all citizens of Papua New Guinea with a secure, verifiable digital identity that enables access to services and participation in the digital economy.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// MAIN DASHBOARD — FULLY UPDATED
class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final List<String> headerImages = [
    'assets/images/welcome_bg.png',
    'assets/images/nid_card_sample.png',
    'assets/images/highlands_area.png',
    'assets/images/nid_office.png',
    'assets/images/coastal_areas.png',
    'assets/images/png_map2.png',
  ];

  // PNGCIR Project Cards Data (unchanged)
  final List<Map<String, String>> projectCards = [
    {
      "title": "2019 PNGCIR Report",
      "button": "2019 PNGCIR Information",
      "image": "assets/images/2019 PNGCIR REPORT.png",
      "link": "https://pngcir.gov.pg/2019-report"
    },
    {
      "title": "MOU/MOA/MOP for NID PROJECT Rollout",
      "button": "MOU/MOA/MOP Register",
      "image": "assets/images/NID PROJECT Rollout.png",
      "link": "https://pngcir.gov.pg/mou-register"
    },
    {
      "title": "Partnerships for Rollout in Private Sector",
      "button": "Rollout Sponsorship",
      "image": "assets/images/Partnership for Rollout in Private Sector.png",
      "link": "https://pngcir.gov.pg/partnership"
    },
    {
      "title": "Our Vision for the Project",
      "button": "Our Vision",
      "image": "assets/images/Our Vision for the Project.png",
      "link": "https://pngcir.gov.pg/vision"
    },
  ];

  int _currentImageIndex = 0;
  late PageController _pageController;
  double _navBarOpacity = 1.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentImageIndex);
    _startAutoScroll();

    _pageController.addListener(() {
      if (_pageController.hasClients && _pageController.page != null) {
        setState(() {
          _navBarOpacity = 1.0 -
              (_pageController.page! - _currentImageIndex).abs().clamp(
                  0.0, 0.5) * 2;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
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
            _startAutoScroll();
          }
        });
      }
    });
  }

  void _navigateWithDelay(Widget page) async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  Widget _serviceCard({
    required String title,
    required String description,
    required String linkText,
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 666),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade800),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 5, color: Colors.green),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: iconColor.withOpacity(0.3), width: 2),
                    ),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  // Text content
                  Expanded(
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
                                colors: [Colors.blue.shade700, Colors.blue.shade900],
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 130,
        backgroundColor: Colors.lightBlue,
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
                      Text("313 3000",
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                      SizedBox(width: 16),
                      Icon(Icons.email, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text("helpdesk@pngcir.gov.pg",
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                      SizedBox(width: 16),
                      Icon(Icons.public, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text("www.pngcir.gov.pg",
                          style: TextStyle(color: Colors.white, fontSize: 12)),
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
      drawer: _buildNavigationDrawer(context),
      body: Stack(
        children: [
          // Main content with reduced brightness when loading
          AnimatedOpacity(
            opacity: _isLoading ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: _isLoading,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // TOP NAVIGATION BAR WITH 3D DROPDOWN
                    Container(
                      color: Colors.red.withOpacity(0.9 * _navBarOpacity),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _navBarItem(Icons.home, "Home", []),
                          const SizedBox(width: 20),
                          _navBarItem(Icons.help, "Help", [
                            "FAQ",
                            "User Guide",
                            "Technical Support",
                            "Contact Helpdesk"
                          ]),
                          const SizedBox(width: 20),
                          _navBarItem(Icons.newspaper, "News", [
                            "Latest Updates",
                            "Announcements",
                            "Press Releases",
                            "Events Calendar"
                          ]),
                          const SizedBox(width: 20),
                          _navBarItem(Icons.contact_mail, "Contact", [
                            "Office Locations",
                            "Email Directory",
                            "Feedback Form",
                            "Emergency Contacts"
                          ]),
                          const SizedBox(width: 20),
                          _navBarItem(Icons.info, "About MyNID PNG", [
                            "Our Mission",
                            "History",
                            "Leadership",
                            "Careers",
                            "Partners"
                          ]),
                        ],
                      ),
                    ),
                    // HEADER IMAGE SLIDESHOW SECTION
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
                                  width: double.infinity,
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
                                      "Welcome to MyNID PNG",
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Your one-stop access to National ID Services, Status & Application",
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
                                children: List.generate(
                                    headerImages.length, (index) {
                                  return Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
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
                    // GET NID SECTION
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT COLUMN (Services)
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    print("Get NID button pressed!");
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
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
                                        const BoxShadow(
                                          color: Colors.green,
                                          blurRadius: 4,
                                          offset: Offset(0, 6),
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
                                      "Get Your NID Here",
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
                                _serviceCard(
                                  title: "Apply For Your NID",
                                  description:
                                  "Submit your details and documents online to start your NID application instantly.",
                                  linkText: "Apply Now",
                                  icon: Icons.app_registration,
                                  iconColor: Colors.green,
                                  onTap: () {
                                    _navigateWithDelay(const ApplyFormPage());
                                  },
                                ),
                                const SizedBox(height: 12),
                                _serviceCard(
                                  title: "Track Your Application",
                                  description:
                                  "Recently applied for NID? Check if your NID is ready or updated.",
                                  linkText: "Check Status",
                                  icon: Icons.track_changes,
                                  iconColor: Colors.blue,
                                  onTap: () {
                                    _navigateWithDelay(
                                        const UserTrackApplicationPage(userId: 123));
                                  },
                                ),
                                const SizedBox(height: 12),
                                _serviceCard(
                                  title: "Notifications",
                                  description:
                                  "View important updates and alerts from MyNID PNG.",
                                  linkText: "Tap Here",
                                  icon: Icons.notifications_active,
                                  iconColor: Colors.orange,
                                  onTap: () {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    Future.delayed(const Duration(seconds: 1), () {
                                      if (mounted) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        debugPrint("Notifications tapped");
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                _serviceCard(
                                  title: "Report Lost/Stolen",
                                  description:
                                  "If your NID card is lost or stolen, report it immediately.",
                                  linkText: "Click Here To Report",
                                  icon: Icons.report_problem,
                                  iconColor: Colors.red,
                                  onTap: () {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    Future.delayed(const Duration(seconds: 1), () {
                                      if (mounted) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        debugPrint("Report lost/stolen tapped");
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                _serviceCard(
                                  title: "Book an Appointment",
                                  description:
                                  "Please book an appointment at your nearest NID office to make any changes to your personal data.",
                                  linkText: "Book Now",
                                  icon: Icons.calendar_today,
                                  iconColor: Colors.purple,
                                  onTap: () {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    Future.delayed(const Duration(seconds: 1), () {
                                      if (mounted) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        debugPrint("Book appointment tapped");
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // RIGHT COLUMN — NOW USING THE NEW NEWS CARD SECTION + MYNID PNG CARD
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                NewsCardSection(), // ✅ Existing News Section
                                const SizedBox(height: 16),
                                // ✅ NEW MYNID PNG CARD
                                Padding( // ✅ ADDED THIS PADDING TO PUSH CARD LEFTWARD
                                  padding: const EdgeInsets.only(left: 0), // ✅ PUSHES CARD TO LEFT EDGE OF COLUMN
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.deepOrange, width: 8),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0, right: 64.0, top: 16.0, bottom: 16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.badge, color: Colors.green, size: 30),
                                              SizedBox(width: 10),
                                              Text(
                                                "MyNID PNG",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            "MyNID PNG is a centrally-supported National Identification system developed as a prototype for Papua New Guinea. "
                                                "It provides a digital platform where citizens can pre-register for NID cards, upload documents, and track the progress of their applications online.",
                                            style: TextStyle(fontSize: 14, height: 1.4),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            "The platform allows secure login for both Citizens and Administrators. "
                                                "Citizens can apply for IDs, view updates, and receive notifications, while Administrators can manage records, verify applications, and ensure accurate data collection.",
                                            style: TextStyle(fontSize: 14, height: 1.4),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            "MyNID PNG is managed by the National Identity Authority (NIA). "
                                                "Technical backend support is powered by PostgreSQL, Flask, and Flutter technologies to ensure real-time access, reliability, and security.",
                                            style: TextStyle(fontSize: 14, height: 1.4),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blueAccent,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                            ),
                                            onPressed: () {
                                              _launchURL("https://pngcir.gov.pg"); // ✅ Fixed URL (removed trailing spaces)
                                            },
                                            child: const Text(
                                              "More Information on MyNID PNG",
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ), // ✅ CLOSING PADDING
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // NEW HORIZONTAL PNGCIR PROJECT CARDS SECTION
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: const Text(
                              "Papua New Guinea National Identification Project",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "The Papua New Guinea Civil and Identity Registry (PNGCIR) is mandated and empowered by its own act: The Civil Registration Act 1963 Amended 2014 to maintain registers of Vital Events and the Papua New Guinea National Identity Project (PNG NID Project) is the project which enables a quicker way to fulfil its functions.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          SizedBox(height: 16),
                          SizedBox(
                            height: 300,
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: projectCards.map((card) {
                                return GestureDetector(
                                  onTap: () {
                                    _launchURL(card["link"]!);
                                  },
                                  child: Container(
                                    width: 250,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 6,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image: AssetImage(card["image"]!),
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withOpacity(0.35),
                                          BlendMode.darken,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            card["title"]!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.greenAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () {
                                            _launchURL(card["link"]!);
                                          },
                                          child: Text(card["button"]!),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // FOOTER SECTION
                    Container(
                      width: double.infinity,
                      color: Colors.grey[850],
                      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 180,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "About",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "The National Identity Authority (NIA) manages the National ID system in Papua New Guinea, providing secure and verifiable identification for citizens and residents.",
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 12,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 280,
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
                                const SizedBox(height: 10),
                                Text(
                                  "National Identity Authority\nPO Box 483, Madang\nPapua New Guinea\nPhone: +675 422 9937\nEmail: helpdesk@nid.gov.pg\nWebsite: www.nid.gov.pg",
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 12,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 280,
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
                                const SizedBox(height: 10),
                                Text(
                                  "Copyright © 2025 National Identity Authority\nAll Rights Reserved",
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 12,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Opening support page..."),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Support",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
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
          // Loading overlay with spinner
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
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Loading...",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
          itemBuilder: (BuildContext context) {
            return dropdownItems.map((String item) {
              return PopupMenuItem<String>(
                value: item,
                height: 40,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList();
          },
          onSelected: (String value) {
            switch (value) {
              case "FAQ":
                _navigateWithDelay(const FAQPage());
                break;
              case "User Guide":
                _navigateWithDelay(const UserGuidePage());
                break;
              case "Technical Support":
                _navigateWithDelay(const TechnicalSupportPage());
                break;
              case "Contact Helpdesk":
                _navigateWithDelay(const ContactPage());
                break;
              case "Latest Updates":
              case "Announcements":
              case "Press Releases":
              case "Events Calendar":
                _launchURL("https://www.postcourier.com.pg"); // ✅ DIRECTLY OPENS POST-COURIER
                break;
              case "Office Locations":
                _navigateWithDelay(const OfficeLocationsPage());
                break;
              case "Email Directory":
              case "Feedback Form":
              case "Emergency Contacts":
                _navigateWithDelay(const ContactPage());
                break;
              case "Our Mission":
                _navigateWithDelay(const MissionPage());
                break;
              case "History":
              case "Leadership":
              case "Careers":
              case "Partners":
                _navigateWithDelay(const AboutPage());
                break;
              default:
                print("Selected: $value");
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFF5252),
                  Color(0xFFD32F2F),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green[900]!.withOpacity(0.6),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                const BoxShadow(
                  color: Color(0xFFFFFFFF),
                  blurRadius: 4,
                  offset: Offset(0, -2),
                  spreadRadius: 0,
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
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                if (dropdownItems.isNotEmpty)
                  const SizedBox(width: 4),
                if (dropdownItems.isNotEmpty)
                  const Icon(
                      Icons.arrow_drop_down, size: 18, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("John Doe"),
            accountEmail: Text("john.doe@nid.png"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 48),
            ),
            decoration: BoxDecoration(color: Colors.deepPurple),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}