import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For Google icon
import 'overview_screen.dart'; // Import the OverviewScreen

// Main application entry point
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver Login UI',
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        primarySwatch: Colors.green, // You can adjust primary color
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Applying Inter font family if available
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar at the top
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // No shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Handle back button press
            // This might pop back to a previous screen if there is one
            // or do nothing if this is the root.
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Driver Login',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      // Main body of the login page, allowing scrolling
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 30), // Spacing from app bar

              // Logo and Branding Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E5C4E), // Dark green color from image
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
                child: Column(
                  children: [
                    // Placeholder for the logo image/icon
                    // You would replace this with an actual image asset or SVG
                    Image.asset(
                      'assets/placeholder_logo.png', // Replace with your logo image path
                      height: 80,
                      width: 80,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.eco, // A nature-like icon as a placeholder
                          color: Colors.white,
                          size: 80,
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'BRIUM BIRNY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'SERT BLACKAN WORK',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40), // Spacing

              // Email Text Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.black54),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54), // 'X' icon
                    onPressed: () {
                      _emailController.clear();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                ),
              ),

              const SizedBox(height: 20), // Spacing

              // Password Text Field
              TextField(
                controller: _passwordController,
                obscureText: true, // Hide password
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.lock, color: Colors.black54), // Lock icon
                    onPressed: () {
                      // Toggle password visibility (optional, not in UI but common)
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                ),
              ),

              const SizedBox(height: 10),

              // Forgot Password? button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Handle forgot password logic
                    print('Forgot Password? tapped');
                  },
                  child: const Text(
                    'Forgot Password ?',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // --- Login Logic Placeholder ---
                    print('Login button tapped');
                    print('Email: ${_emailController.text}');
                    print('Password: ${_passwordController.text}');
                    // Typically, you'd perform authentication here.
                    // If login is successful:
                    Navigator.pushReplacement( // Use pushReplacement to prevent going back to login
                      context,
                      MaterialPageRoute(builder: (context) => const OverviewScreen()),
                    );
                    // --- End Login Logic Placeholder ---
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent, // Red color from image
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                    ),
                    elevation: 5, // Shadow
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // "or" separator
              const Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                      indent: 20,
                      endIndent: 10,
                    ),
                  ),
                  Text(
                    'or',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                      indent: 10,
                      endIndent: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Continue with Google Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Handle Google login logic
                    print('Continue with Google tapped');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const FaIcon(
                    FontAwesomeIcons.google, // Google icon from Font Awesome
                    size: 24,
                    color: Colors.blueGrey, // Adjusted color
                  ),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40), // Spacing before bottom nav bar area
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed, // Ensures all items are visible
      //   selectedItemColor: const Color(0xFF2E5C4E), // Selected item color
      //   unselectedItemColor: Colors.grey, // Unselected item color
      //   backgroundColor: Colors.white,
      //   elevation: 10, // Shadow for the navigation bar
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home_outlined),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.monetization_on_outlined), // Placeholder for Earnings
      //       label: 'Earnings',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person_outline),
      //       label: 'Account',
      //     ),
      //   ],
      //   onTap: (index) {
      //     // Handle bottom navigation item taps
      //     print('Tapped on index: $index');
      //   },
      // ),
    );
  }
}
