import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'custom_app_bar.dart';
// import 'floating_search_bar.dart';

class CommunityPage extends StatelessWidget {
  // Same color theme as HomePage
  static const Color primaryPurple = Color(0xFF9C88FF);
  static const Color lightPurple = Color(0xFFE8E2FF);
  static const Color ivory = Color(0xFFFFFDF7);
  static const Color darkPurple = Color(0xFF6C5CE7);
  static const Color softGrey = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ivory,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lightPurple.withValues(alpha: .3),
                  ivory,
                  ivory,
                ],
              ),
            ),
          ),
          // Main content
          CustomScrollView(
            slivers: [
              // Custom App Bar for Community
              _buildCommunityAppBar(),
              
              // Body content
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      
                      // Search Bar
                      _buildCommunitySearchBar(),
                      
                      SizedBox(height: 25),
                      
                      // Quick Categories
                      _buildQuickCategories(),
                      
                      SizedBox(height: 30),
                      
                      // Recent Discussions
                      Text(
                        'Recent Discussions',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: darkPurple,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Discussion Posts
                      // Discussion Posts
                      DiscussionPost(
                        authorName: 'Dr. Sarah Johnson',
                        authorRole: 'Cardiologist',
                        title: 'Tips for maintaining heart health in your 40s',
                        preview: 'Regular exercise and a balanced diet are crucial. Here are some key points to consider...',
                        time: '2 hours ago',
                        initialLikes: 45,
                        replies: 12,
                        categoryColor: Colors.red,
                        categoryIcon: Icons.favorite,
                      ),

                      DiscussionPost(
                        authorName: 'Michael Chen',
                        authorRole: 'Health Enthusiast',
                        title: 'My journey with diabetes management',
                        preview: 'After being diagnosed last year, I\'ve learned so much about managing blood sugar levels...',
                        time: '5 hours ago',
                        initialLikes: 32,
                        replies: 8,
                        categoryColor: Colors.blue,
                        categoryIcon: Icons.health_and_safety,
                      ),

                      DiscussionPost(
                        authorName: 'Dr. Emily Rodriguez',
                        authorRole: 'Nutritionist',
                        title: 'Healthy meal prep ideas for busy professionals',
                        preview: 'Meal prepping doesn\'t have to be complicated. Here are some simple strategies...',
                        time: '1 day ago',
                        initialLikes: 67,
                        replies: 15,
                        categoryColor: Colors.green,
                        categoryIcon: Icons.restaurant,
                      ),
                      
                      SizedBox(height: 30),
                      
                      // Featured Groups
                      Text(
                        'Featured Groups',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: darkPurple,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      _buildFeaturedGroups(),
                      
                      SizedBox(height: 100), // Space for floating elements
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Floating Action Button for New Post
          Positioned(
            bottom: 30,
            right: 20,
            child: _buildFloatingActionButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryPurple,
                darkPurple,
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryPurple.withValues(alpha: .3),
                spreadRadius: 0,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -50,
                right: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .1),
                  ),
                ),
              ),
              // Main content
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'COMMUNITY',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black.withValues(alpha: .2),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Connect, Share, Learn Together',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: .9),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    // Community stats
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '2.4k',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
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
    );
  }

  Widget _buildCommunitySearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha: .1),
            spreadRadius: 0,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: lightPurple.withValues(alpha: .3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: lightPurple.withValues(alpha: .3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.search_rounded,
              color: darkPurple,
              size: 22,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search discussions, topics, users...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: GoogleFonts.poppins(
                color: darkPurple,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCategories() {
    final categories = [
      {'name': 'Heart Health', 'icon': Icons.favorite, 'color': Colors.red},
      {'name': 'Mental Health', 'icon': Icons.psychology, 'color': Colors.purple},
      {'name': 'Nutrition', 'icon': Icons.restaurant, 'color': Colors.green},
      {'name': 'Fitness', 'icon': Icons.fitness_center, 'color': Colors.orange},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Categories',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: darkPurple,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: categories.map((category) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: categories.indexOf(category) == categories.length - 1 ? 0 : 8),
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: (category['color'] as Color).withValues(alpha: .1),
                    spreadRadius: 0,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: (category['color'] as Color).withValues(alpha: .2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (category['color'] as Color).withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      color: category['color'] as Color,
                      size: 24,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    category['name'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: darkPurple,
                    ),
                  ),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildDiscussionPost(String authorName, String authorRole, String title, 
                            String preview, String time, int likes, int replies,
                            Color categoryColor, IconData categoryIcon) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .08),
            spreadRadius: 0,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: .1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [categoryColor.withValues(alpha: .15), categoryColor.withValues(alpha: .08)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: categoryColor.withValues(alpha: .2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  categoryIcon,
                  color: categoryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: darkPurple,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      authorRole,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: lightPurple.withValues(alpha: .3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: darkPurple,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          
          // Post content
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: darkPurple,
              height: 1.3,
            ),
          ),
          SizedBox(height: 10),
          Text(
            preview,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 18),
          
          // Interaction buttons
          Row(
            children: [
              _buildInteractionButton(Icons.favorite_outline, likes.toString(), categoryColor),
              SizedBox(width: 28),
              _buildInteractionButton(Icons.chat_bubble_outline, replies.toString(), Colors.blue),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [categoryColor.withValues(alpha: .1), categoryColor.withValues(alpha: .05)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: categoryColor.withValues(alpha: .3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Read More',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: categoryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(IconData icon, String count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          count,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

Widget _buildFeaturedGroups() {
  final groups = [
    {'name': 'Diabetes Support', 'members': '1.2k', 'color': Colors.blue},
    {'name': 'Mental Wellness', 'members': '856', 'color': Colors.purple},
    {'name': 'Fitness Journey', 'members': '2.1k', 'color': Colors.orange},
  ];

  return Container(
    height: 130, // Increased back to accommodate wrapped text
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Container(
          width: 180,
          margin: EdgeInsets.only(right: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: (group['color'] as Color).withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: (group['color'] as Color).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (group['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.group,
                      color: group['color'] as Color,
                      size: 20,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [(group['color'] as Color).withOpacity(0.15), (group['color'] as Color).withOpacity(0.08)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (group['color'] as Color).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Join',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: group['color'] as Color,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12), // Added spacing
              // Content section - allows text wrapping
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end, // Align to bottom
                  children: [
                    Text(
                      group['name'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: darkPurple,
                        height: 1.2, // Line height for better spacing
                      ),
                      maxLines: 2, // Allow up to 2 lines
                      overflow: TextOverflow.visible, // Show wrapped text
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${group['members']} members',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryPurple, darkPurple],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha: .3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Create new post'),
                backgroundColor: primaryPurple,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'New Post',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Add this new class to your community_page.dart file
class DiscussionPost extends StatefulWidget {
  final String authorName;
  final String authorRole;
  final String title;
  final String preview;
  final String time;
  final int initialLikes;
  final int replies;
  final Color categoryColor;
  final IconData categoryIcon;

  const DiscussionPost({
    Key? key,
    required this.authorName,
    required this.authorRole,
    required this.title,
    required this.preview,
    required this.time,
    required this.initialLikes,
    required this.replies,
    required this.categoryColor,
    required this.categoryIcon,
  }) : super(key: key);

  @override
  _DiscussionPostState createState() => _DiscussionPostState();
}

class _DiscussionPostState extends State<DiscussionPost> with SingleTickerProviderStateMixin {
  bool isLiked = false;
  late int likeCount;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    likeCount = widget.initialLikes;
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        likeCount++;
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      } else {
        likeCount--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.categoryColor.withOpacity(0.15), widget.categoryColor.withOpacity(0.08)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.categoryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  widget.categoryIcon,
                  color: widget.categoryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.authorName,
                      style: GoogleFonts.poppins(  // Using cool font
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CommunityPage.darkPurple,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      widget.authorRole,
                      style: GoogleFonts.poppins(  // Using cool font
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CommunityPage.lightPurple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.time,
                  style: GoogleFonts.poppins(  // Using cool font
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: CommunityPage.darkPurple,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          
          // Post content
          Text(
            widget.title,
            style: GoogleFonts.poppins(  // Using cool font
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CommunityPage.darkPurple,
              height: 1.3,
            ),
          ),
          SizedBox(height: 10),
          Text(
            widget.preview,
            style: GoogleFonts.poppins(  // Using cool font
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 18),
          
          // Interaction buttons
          Row(
            children: [
              GestureDetector(
                onTap: _toggleLike,
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_outline,
                            size: 20,
                            color: isLiked ? Colors.red : Colors.grey[600],
                          ),
                          SizedBox(width: 8),
                          Text(
                            likeCount.toString(),
                            style: GoogleFonts.poppins(  // Using cool font
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isLiked ? Colors.red : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 28),
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    widget.replies.toString(),
                    style: GoogleFonts.poppins(  // Using cool font
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.categoryColor.withOpacity(0.1), widget.categoryColor.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: widget.categoryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Read More',
                  style: GoogleFonts.poppins(  // Using cool font
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: widget.categoryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
