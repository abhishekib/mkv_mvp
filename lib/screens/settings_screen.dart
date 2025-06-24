import 'package:flutter/material.dart';
import 'package:goodchannel/widgets/utils.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: Utils.getScreenGradient(),
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
                child: Column(
                  children: [
                    //logo
                    Utils.getLogo(),
                    const SizedBox(height: 40),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildOptionCard(Icons.receipt_long, 'EPG'),
                        _buildOptionCard(Icons.star_rate, 'Rate Us'),
                        _buildOptionCard(Icons.access_time, 'Time Format'),
                        _buildOptionCard(Icons.subscriptions, 'Subscription'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Back Button
          Utils.backButton(context),
        ],
      ),
    );
  }

  Widget _buildOptionCard(IconData icon, String label) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
}
