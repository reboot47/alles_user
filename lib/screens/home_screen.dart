import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/fortune_category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Alles',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: AllesColors.navyBlue,
            fontStyle: FontStyle.italic,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AllesColors.splashGradient,
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            // Header section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fortune-Telling',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: AllesColors.navyBlue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '占いとの出会いを、もっと美しく',
                    style: TextStyle(
                      fontSize: 16,
                      color: AllesColors.grayishLavender,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Fortune categories list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: fortuneCategories.length,
                itemBuilder: (context, index) {
                  final category = fortuneCategories[index];
                  return FortuneCard(
                    category: category,
                    isSelected: index == _selectedIndex,
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FortuneCard extends StatelessWidget {
  final FortuneCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const FortuneCard({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AllesColors.babyPink.withOpacity(0.7),
            AllesColors.lavender.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AllesColors.navyBlue.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: isSelected 
            ? AllesColors.rosePink 
            : AllesColors.rosePink.withOpacity(0.2),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Category icon
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AllesColors.milkyWhite.withOpacity(0.8),
                  child: Icon(
                    _getCategoryIcon(category.id),
                    size: 32,
                    color: AllesColors.navyBlue,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Category details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AllesColors.navyBlue,
                        ),
                      ),
                      Text(
                        category.japaneseTitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AllesColors.grayishLavender.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Star rating
                      Row(
                        children: List.generate(
                          5,
                          (starIndex) => Icon(
                            starIndex < category.stars
                                ? Icons.star
                                : Icons.star_border,
                            color: starIndex < category.stars
                                ? AllesColors.pearlGold
                                : AllesColors.grayishLavender.withOpacity(0.4),
                            size: 16,
                          ),
                        ),
                      ),
                      
                      // Description
                      Text(
                        category.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AllesColors.grayishLavender.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Arrow indicator
                Icon(
                  Icons.arrow_forward_ios,
                  color: AllesColors.navyBlue.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to get category icons
  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'card-reading':
        return Icons.style;
      case 'astrology':
        return Icons.brightness_2;
      case 'spiritual':
        return Icons.auto_awesome;
      case 'numerology':
        return Icons.tag;
      case 'dream':
        return Icons.nights_stay;
      default:
        return Icons.spa;
    }
  }
}
