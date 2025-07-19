import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myfliq_app/view/phone_number_login.dart';

class DatingLoginPage extends StatelessWidget {
  const DatingLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/image-2.png', // Replace with your image
              fit: BoxFit.cover,
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 40.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  CircleAvatar(
                    backgroundColor: Colors.pink,
                    radius: 30,
                    child: Image.asset('assets/images/Group 1435.png'),
                  ),
                  const SizedBox(height: 20),

                  // Tagline
                  Text(
                    'Connect. Meet. Love.\nWith Fliq Dating',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  Spacer(),

                  // Google button
                  LoginButton(
                    color: Colors.white,
                    textColor: Colors.black87,
                    imageAsset:
                        'assets/images/Google.png', // <- image for Google
                    text: 'Sign in with Google',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  LoginButton(
                    color: Color(0xFF1877F2),
                    textColor: Colors.white,
                    icon: Icons.facebook_outlined, // <- use icon for Facebook
                    text: 'Sign in with Facebook',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  LoginButton(
                    color: Colors.pinkAccent,
                    textColor: Colors.white,
                    icon: Icons.phone, // <- use icon for Phone
                    text: 'Sign in with phone number',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PhoneNumberInputPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Terms & Privacy
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      children: [
                        const TextSpan(
                          text: 'By signing up, you agree to our ',
                        ),
                        TextSpan(
                          text: 'Terms',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Navigate to terms
                            },
                        ),
                        const TextSpan(
                          text: '. See how we use your data in our ',
                        ),
                        TextSpan(
                          text: 'Privacy Policy.',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),

                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Navigate to privacy
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final Color color;
  final Color textColor;
  final String text;
  final VoidCallback onTap;
  final IconData? icon;
  final String? imageAsset;

  const LoginButton({
    super.key,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.icon,
    this.imageAsset,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: imageAsset != null
          ? Image.asset(imageAsset!, width: 24, height: 24)
          : Icon(icon, color: textColor),
      label: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 3,
      ),
    );
  }
}
