import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_view_model.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/signup_page.dart';
import 'presentation/screens/user_dashboard.dart';
import 'presentation/screens/admin_dashboard.dart';



void main() {
  runApp(
      ChangeNotifierProvider(
        create: (context) => AuthViewModel(),
        child: const MyApp(),
      )

  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        return MaterialApp(
          title: 'MyNID PNG',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            scaffoldBackgroundColor: Colors.white,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: true,
              color: Colors.deepPurple,
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: _buildHome(auth),
          routes: {
            '/login': (_) => const LoginPage(),
            '/signup': (_) => const SignupPage(),
            '/user_dashboard': (_) => const UserDashboard(),
            '/admin_dashboard': (_) => const AdminDashboard(),
          },
        );
      },
    );
  }

  Widget _buildHome(AuthViewModel auth) {
    // ✅ Decide where to go at startup
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (auth.isAuthenticated) {
      if (auth.role == 'admin') {
        return const AdminDashboard();
      } else {
        return const UserDashboard();
      }
    }

    return const LoginPage();
  }
}

