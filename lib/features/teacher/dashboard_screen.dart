import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../shared/widgets/cards/app_card.dart';
import '../../shared/widgets/charts/analytics_chart.dart';
import 'package:fl_chart/fl_chart.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 40),
            _buildStatsGrid(isDark),
            const SizedBox(height: 32),
            _buildMainGrid(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, Teacher Rosel!', 
              style: AppTextStyles.h1.copyWith(color: isDark ? Colors.white : AppColors.deepPurple),
            ),
            const SizedBox(height: 4),
            Text(
              'Here is what\'s happening in your Filipino classes today.',
              style: AppTextStyles.subtitle1.copyWith(color: isDark ? Colors.white70 : AppColors.neutralGray),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.search, color: isDark ? Colors.white70 : AppColors.neutralGray),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            _buildNotificationBadge(isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationBadge(bool isDark) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_none_rounded, 
            color: isDark ? Colors.white70 : AppColors.neutralGray,
          ),
          onPressed: () {},
        ),
        Positioned(
          right: 12,
          top: 12,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 2.2,
          children: [
            _buildStatCard('Total Students', '90', Icons.people_outline, AppColors.primaryPurple, isDark),
            _buildStatCard('Active Sections', '3', Icons.grid_view_rounded, AppColors.accentPurple, isDark),
            _buildStatCard('Today\'s Classes', '3', Icons.schedule_rounded, AppColors.success, isDark),
            _buildStatCard('Pending Grades', '15', Icons.pending_actions_rounded, AppColors.warning, isDark),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title, 
                  style: TextStyle(color: isDark ? Colors.white60 : AppColors.neutralGray, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value, 
                  style: AppTextStyles.h2.copyWith(color: isDark ? Colors.white : AppColors.deepPurple),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainGrid(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1000) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildLeftColumn(isDark)),
              const SizedBox(width: 24),
              Expanded(child: _buildRightColumn(isDark)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildLeftColumn(isDark),
              const SizedBox(height: 24),
              _buildRightColumn(isDark),
            ],
          );
        }
      },
    );
  }

  Widget _buildLeftColumn(bool isDark) {
    return Column(
      children: [
        AnalyticsChartContainer(
          title: 'Section Performance',
          subtitle: 'Average scores across your Filipino sections',
          chart: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barGroups: [
                _buildBarGroup(0, 84, AppColors.primaryPurple, isDark),
                _buildBarGroup(1, 72, AppColors.accentPurple, isDark),
                _buildBarGroup(2, 88, AppColors.primaryPurple, isDark),
              ],
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final style = TextStyle(
                        color: isDark ? Colors.white70 : AppColors.deepPurple,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      );
                      switch (value.toInt()) {
                        case 0: return Text('Section 1', style: style);
                        case 1: return Text('Section 2', style: style);
                        case 2: return Text('Section 3', style: style);
                        default: return const Text('');
                      }
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 24),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology_outlined, color: AppColors.primaryPurple),
                  const SizedBox(width: 8),
                  Text(
                    'Instructional Insights', 
                    style: AppTextStyles.h3.copyWith(color: isDark ? Colors.white : AppColors.deepPurple),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildAttentionItem(
                'Possible Learning Gap in "Pagbasa"',
                'Section 2 shows a 15% lower average than other sections.',
                AppColors.error,
                isDark,
              ),
              _buildAttentionItem(
                'Performance Trend: Missing Submissions',
                '5 students have not submitted the recent Written Work #1.',
                AppColors.warning,
                isDark,
              ),
              _buildAttentionItem(
                'Performance Trend: Improving',
                'Section 3 average score increased by 8% this week.',
                AppColors.success,
                isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color, bool isDark) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 32,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: color.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildAttentionItem(String title, String description, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    fontWeight: FontWeight.w600, 
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.deepPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description, 
                  style: TextStyle(color: isDark ? Colors.white70 : AppColors.neutralGray, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightColumn(bool isDark) {
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Classes', 
                    style: AppTextStyles.h3.copyWith(color: isDark ? Colors.white : AppColors.deepPurple),
                  ),
                  TextButton(
                    onPressed: () {}, 
                    child: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildClassItem('7:30 AM', 'Section 1', 'Filipino', 'Room 301', isDark),
              _buildClassItem('9:00 AM', 'Section 2', 'Filipino', 'Room 302', isDark),
              _buildClassItem('10:30 AM', 'Section 3', 'Filipino', 'Room 303', isDark),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AppCard(
          gradient: AppColors.purpleGradient,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
              const SizedBox(height: 16),
              const Text(
                'Instructional Support',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Let EduLens help you analyze your last assessment and generate a reinforcement plan.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryPurple,
                  elevation: 0,
                ),
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassItem(String time, String section, String subject, String room, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              time,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple, fontSize: 12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.deepPurple,
                  ),
                ),
                Text(
                  '$subject • $room', 
                  style: TextStyle(color: isDark ? Colors.white60 : AppColors.neutralGray, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
