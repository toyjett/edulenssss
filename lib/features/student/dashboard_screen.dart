import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../shared/widgets/cards/app_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

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
            const SizedBox(height: 32),
            _buildAchievementBanner(isDark),
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
              'Maligayang pagbabalik, Maria!', 
              style: AppTextStyles.h1.copyWith(color: isDark ? Colors.white : AppColors.deepPurple),
            ),
            const SizedBox(height: 4),
            Text(
              'Narito ang iyong pag-unlad sa linggong ito.',
              style: AppTextStyles.subtitle1.copyWith(color: isDark ? Colors.white70 : AppColors.neutralGray),
            ),
          ],
        ),
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.1),
          child: const Icon(Icons.person, color: AppColors.primaryPurple, size: 32),
        ),
      ],
    );
  }

  Widget _buildAchievementBanner(bool isDark) {
    return AppCard(
      gradient: AppColors.purpleGradient,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: Colors.white, size: 48),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Magaling! Mahusay ang iyong huling pagsusulit.',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Text(
                  'Nakakuha ka ng 90% sa Filipino Panitikan. Ipagpatuloy ito!',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryPurple,
              elevation: 0,
            ),
            child: const Text('Tingnan ang Badges'),
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
              Expanded(flex: 2, child: _buildProgressColumn(isDark)),
              const SizedBox(width: 24),
              Expanded(child: _buildClassesColumn(isDark)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildProgressColumn(isDark),
              const SizedBox(height: 24),
              _buildClassesColumn(isDark),
            ],
          );
        }
      },
    );
  }

  Widget _buildProgressColumn(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pag-unlad sa Pag-aaral', 
          style: AppTextStyles.h3.copyWith(color: isDark ? Colors.white : AppColors.deepPurple),
        ),
        const SizedBox(height: 16),
        AppCard(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true, 
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: (isDark ? Colors.white : AppColors.primaryPurple).withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        'Week ${value.toInt() + 1}',
                        style: TextStyle(color: isDark ? Colors.white38 : AppColors.neutralGray, fontSize: 10),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 80),
                      const FlSpot(1, 85),
                      const FlSpot(2, 82),
                      const FlSpot(3, 90),
                    ],
                    isCurved: true,
                    color: AppColors.primaryPurple,
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true, 
                      color: AppColors.primaryPurple.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassesColumn(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mga Darating na Gawain', 
          style: AppTextStyles.h3.copyWith(color: isDark ? Colors.white : AppColors.deepPurple),
        ),
        const SizedBox(height: 16),
        _buildActivityItem('Written Work #1', 'Filipino', 'May 25', AppColors.accentPurple, isDark),
        _buildActivityItem('Pagsusulit sa Talasalitaan', 'Filipino', 'May 26', AppColors.warning, isDark),
        _buildActivityItem('Gawaing Pampanitikan', 'Filipino', 'May 30', AppColors.success, isDark),
      ],
    );
  }

  Widget _buildActivityItem(String title, String subject, String due, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 48,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.deepPurple,
                    ),
                  ),
                  Text(
                    subject, 
                    style: TextStyle(color: isDark ? Colors.white60 : AppColors.neutralGray, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Due', style: TextStyle(color: AppColors.neutralGray, fontSize: 10)),
                Text(
                  due, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 12,
                    color: isDark ? Colors.white : AppColors.deepPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
