import 'package:flutter/material.dart';

class HeroBannerWidget extends StatelessWidget {
  final double? height;
  final String title;
  final String subtitle;
  final String imagePath;

  const HeroBannerWidget({
    super.key,
    this.height,
    this.title = 'LATEST RELEASES',
    this.subtitle = 'Pickleball Gear Endorsed by Hayden Patriquin',
    this.imagePath = 'assets/photo1.jpg',
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final responsiveHeight = height ?? (screenHeight * 0.30).clamp(200.0, 450.0);

    return Container(
      height: responsiveHeight,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 2),
                              blurRadius: 4.0,
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}