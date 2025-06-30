import 'package:flutter/material.dart';
import 'package:goodchannel/provider/auth_view_model.dart';
import 'package:goodchannel/screens/settings_screen.dart';
import 'package:goodchannel/screens/video/channel_list_screen.dart';
import 'package:goodchannel/widgets/utils.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: Utils.getScreenGradient(),
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
                child: Column(
                  children: [
                    // Logo
                    SizedBox(
                      width: 200,
                      height: 100,
                      child: Image.asset(
                        'assets/text_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Feature Grid
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildFeatureButton(
                            context, Icons.wifi_tethering, 'Live', true,
                            onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ChannelListScreen()),
                          );
                        }),
                        _buildFeatureButton(
                            context, Icons.movie, 'Movies', true),
                        _buildFeatureButton(
                            context, Icons.theaters, 'Series', true),
                        _buildFeatureButton(context, Icons.playlist_add,
                            'Change Playlist', true),
                        _buildFeatureButton(
                            context, Icons.person, 'Account', false),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Bottom Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBottomButton(
                          context,
                          Icons.settings,
                          'Settings',
                          () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SettingsScreen()));
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildBottomButton(
                            context, Icons.refresh, 'Reload', () {}),
                        const SizedBox(width: 16),
                        _buildBottomButton(context, Icons.exit_to_app, 'Exit',
                            () {
                          context.read<AuthViewModel>().logout(context);
                          //Navigator.pop(context);
                        }),
                      ],
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

  Widget _buildFeatureButton(
      BuildContext context, IconData icon, String label, bool isLocked,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => LiveTvScreen())),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isLocked) ...[
              const SizedBox(height: 6),
              const Icon(Icons.lock, size: 16, color: Colors.amberAccent),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, IconData icon, String label,
      VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.08),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: Colors.white.withOpacity(0.15)),
        elevation: 0,
      ),
    );
  }
}
