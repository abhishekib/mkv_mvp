import 'package:flutter/material.dart';

class Utils {
  static Container passwordTextField({
    required TextEditingController passwordController,
    required String hint,
    required bool obscurePassword,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: passwordController,
        obscureText: obscurePassword,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Enter your password',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white.withOpacity(0.6),
            ),
            onPressed: onToggleVisibility,
          ),
        ),
      ),
    );
  }

  static Positioned backButton(BuildContext context) {
    return Positioned(
      top: 30,
      left: 20,
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            // color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  static Expanded button(
      {required String text, required VoidCallback onPressed}) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        /* () {
           Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OtpVerificationScreen()),
          ); 
        },*/
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF7C3AED),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
