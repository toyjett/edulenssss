import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../shared/widgets/cards/app_card.dart';
import '../../shared/widgets/buttons/app_button.dart';
import '../../core/services/academic_service.dart';
import '../../core/services/auth_service.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  List<Map<String, dynamic>> _upcomingAssessments = [];
  List<Map<String, dynamic>> _performanceTrend = [];
  Map<String, dynamic> _stats = {
    'attendanceRate': 'N/A',
    'badges': 0,
    'averagePerformance': '0%',
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authService = context.read<AuthService>();
    final academicService = context.read<AcademicService>();
    
    if (authService.currentUser != null) {
      final studentId = authService.currentUser!.id;
      
      final assessments = await academicService.fetchStudentUpcomingAssessments(studentId);
      final stats = await academicService.fetchStudentDashboardStats(studentId);
      final trend = await academicService.fetchStudentPerformanceTrend(studentId);

      if (mounted) {
        setState(() {
          _upcomingAssessments = assessments;
          _stats = stats;
          _performanceTrend = trend;
          _isLoading = false;
        });
      }
    }
  }

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
    final user = context.watch<AuthService>().currentUser;
    final name = user?.firstName ?? 'Student';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Maligayang pagbabalik, $name!', 
                style: AppTextStyles.h1.copyWith(
                  color: isDark ? Colors.white : AppColors.deepPurple,
                  fontSize: 24,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Narito ang iyong pag-unlad sa linggong ito.',
                style: AppTextStyles.subtitle1.copyWith(
                  color: isDark ? Colors.white70 : AppColors.neutralGray,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.1),
          child: const Icon(Icons.person, color: AppColors.primaryPurple, size: 24),
        ),
      ],
    );
  }

  Widget _buildAchievementBanner(bool isDark) {
    return AppCard(
      gradient: AppColors.purpleGradient,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Colors.white, size: 48),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Magaling! Nakakuha ka na ng ${_stats['badges']} badges.',
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Ang iyong average performance ay ${_stats['averagePerformance']}.',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Tingnan ang Achievements',
            type: AppButtonType.primary,
            height: 40,
            onPressed: () => context.go('/student/achievements'),
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
            child: _performanceTrend.isEmpty
                ? const Center(child: Text('Walang sapat na data para sa chart.', style: TextStyle(color: AppColors.neutralGray)))
                : LineChart(
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
                            interval: 1,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              if (value < 0 || value >= _performanceTrend.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'T${value.toInt() + 1}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: isDark ? Colors.white38 : AppColors.neutralGray, fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      minX: 0,
                      maxX: (_performanceTrend.length - 1).toDouble(),
                      minY: 0,
                      maxY: 100,
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _performanceTrend.asMap().entries.map((e) {
                            final pct = (e.value['score'] / e.value['total_possible']) * 100;
                            return FlSpot(e.key.toDouble(), pct);
                          }).toList(),
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
        if (_isLoading)
          const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
        else if (_upcomingAssessments.isEmpty)
          _buildNoActivitiesState(isDark)
        else
          ..._upcomingAssessments.map((activity) => _buildActivityItem(
            activity['title'] ?? 'Gawain', 
            activity['sections']?['name'] ?? 'Filipino', 
            activity['due_date'] != null 
                ? DateFormat('MMM dd').format(DateTime.parse(activity['due_date']))
                : 'TBD', 
            AppColors.primaryPurple, 
            isDark
          )),
      ],
    );
  }

  Widget _buildNoActivitiesState(bool isDark) {
    return AppCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: AppColors.success.withOpacity(0.5), size: 40),
              const SizedBox(height: 12),
              const Text('Wala kang darating na gawain.', style: TextStyle(color: AppColors.neutralGray, fontSize: 13)),
              const Text('Magpahinga at mag-enjoy!', style: TextStyle(color: AppColors.neutralGray, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subject, String due, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        interactive: true,
        onTap: () => context.go('/student/assessments'),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
