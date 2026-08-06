import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DialingScreen(),
  ));
}

class DialingScreen extends StatelessWidget {
  const DialingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Header
            const Text(
              'Dialing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            const Spacer(),

            // Avatar with Ripple Effect
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Circle 1
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00D2FF).withValues(alpha: 0.25),
                          const Color(0xFF3A7BD5).withValues(alpha: 0.25),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Outer Circle 2
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00D2FF).withValues(alpha: 0.25),
                          const Color(0xFF3A7BD5).withValues(alpha: 0.25),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Inner Glow Ring
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00D2FF).withValues(alpha: 0.5),
                          const Color(0xFF3A7BD5).withValues(alpha: 0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Profile Image
                  const CircleAvatar(
                    radius: 65,
                    backgroundImage: NetworkImage(
                      'https://scontent-mnl3-3.xx.fbcdn.net/v/t39.30808-6/605540413_25675381585430025_8755526582062261569_n.jpg?stp=dst-jpg_tt6&cstp=mx724x732&ctp=s724x732&_nc_cat=109&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeEIudWqxnN67sVd_o_H-IdY-DbVvB7TVhf4NtW8HtNWF_R0XF8uW41R3Q_kL89oqB7BqSUrUS-LJRwtfYQr0hrh&_nc_ohc=mrjjjvpuf-QQ7kNvwHQtcJs&_nc_oc=AdprxijPicPzQoVj--caWWg0NNSp6HGblWXD8oyym4JE1C_DvZXQKKp1mte8gOaGpYg&_nc_zt=23&_nc_ht=scontent-mnl3-3.xx&_nc_gid=-whgDwyGl8NMmZk3sxiC3w&_nc_ss=7b2a8&oh=00_AQFv9JMZFWs_ELDOnst9TNtvo_ETCGu4tY5Zpbvn0OYUdQ&oe=6A7A23A8',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Contact Info
            const Text(
              'Chastin Obeso',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '+63 962-485-8799',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),

            const Spacer(),

            // Divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
            ),

            const SizedBox(height: 24),

            // Top Control Buttons (Mute, Bluetooth, Hold)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(Icons.mic_none_outlined, 'Mute'),
                  _buildActionButton(Icons.bluetooth_outlined, 'Bluetooth'),
                  _buildActionButton(Icons.pause_circle_outline, 'Hold'),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Bottom Actions (Keypad, End Call, Speaker)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.grid_view, size: 28, color: Colors.grey),
                  ),
                  
                  // End Call Button
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00D2FF),
                            const Color(0xFF3A7BD5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Transform.rotate(
                        angle: 215 * (3.14159 / 180), // Rotates exactly 45 degrees clockwise
                        child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 32,
                      ),
                      )
                      
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.volume_up_outlined, size: 28, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: Colors.grey[700]),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}