import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../shared/widgets/cards/app_card.dart';
import '../../shared/widgets/charts/analytics_chart.dart';
import '../../shared/widgets/buttons/app_button.dart';
import '../../app/routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/academic_service.dart';
import '../../core/models/section_model.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  List<SectionModel> _recentSections = [];
  bool _isLoadingData = true;
  int _totalStudents = 0;
  int _activeSectionsCount = 0;
  int _pendingResultsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final authService = context.read<AuthService>();
    final academicService = context.read<AcademicService>();
    
    if (authService.currentUser != null) {
      final teacherId = authService.currentUser!.id;
      
      // Fetch data in parallel
      final results = await Future.wait([
        academicService.fetchRecentSections(teacherId),
        academicService.fetchTeacherDashboardStats(teacherId),
      ]);

      if (mounted) {
        setState(() {
          _recentSections = results[0] as List<SectionModel>;
          final stats = results[1] as Map<String, dynamic>;
          _totalStudents = stats['students'] as int;
          _activeSectionsCount = stats['sections'] as int;
          _pendingResultsCount = stats['pending'] as int;
          _isLoadingData = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 600 ? 16.0 : 32.0;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 32),
                if (!kIsWeb) _buildQuickActions(context, isDark),
                const SizedBox(height: 40),
                Text(
                  'Today\'s Classes', 
                  style: AppTextStyles.h2.copyWith(color: isDark ? Colors.white : AppColors.deepPurple),
                ),
                const SizedBox(height: 16),
                if (_isLoadingData)
                  const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
                else if (_recentSections.isEmpty)
                  _buildNoClassesState(isDark)
                else
                  ..._recentSections.map((section) => _buildClassItem(
                    section.schedule,
                    section.name, 
                    section.subject, 
                    section.room, 
                    isDark, 
                    context,
                    section.id
                  )),
                if (kIsWeb) ...[
                  const SizedBox(height: 40),
                  _buildStatsGrid(isDark),
                  const SizedBox(height: 32),
                  _buildMainGrid(isDark),
                ] else ...[
                  const SizedBox(height: 40),
                  _buildUpcomingAssessments(context, isDark),
                  const SizedBox(height: 40),
                  _buildQuickAnalyticsPreview(isDark),
                ],
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildNoClassesState(bool isDark) {
    return AppCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              const Icon(Icons.calendar_today_outlined, color: AppColors.neutralGray, size: 32),
              const SizedBox(height: 12),
              const Text('No classes scheduled for today.', style: TextStyle(color: AppColors.neutralGray)),
              TextButton(
                onPressed: () => context.go(AppRoutes.teacherSections),
                child: const Text('Go to My Sections'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final firstName = authService.currentUser?.firstName ?? 'Teacher';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mabuhay, $firstName!',
                    style: AppTextStyles.h1.copyWith(
                      color: isDark ? Colors.white : AppColors.deepPurple,
                      fontSize: firstName.length > 10 ? 24 : 32,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kIsWeb ? 'Overview of your classroom performance' : 'Your Classroom Companion',
                    style: AppTextStyles.subtitle1.copyWith(color: isDark ? Colors.white70 : AppColors.neutralGray),
                  ),
                ],
              ),
            ),
            if (kIsWeb) ...[
              const SizedBox(width: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
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
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 24) / 3;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionCard(
              'Attendance', 
              Icons.how_to_reg_rounded, 
              () => context.go(AppRoutes.teacherAttendance),
              isDark,
              cardWidth,
            ),
            _buildActionCard(
              'Scan Quiz', 
              Icons.qr_code_scanner_rounded, 
              () => context.push(AppRoutes.teacherScanner), 
              isDark,
              cardWidth,
            ),
            _buildActionCard(
              'Analytics', 
              Icons.analytics_rounded, 
              () => context.push(AppRoutes.teacherAnalytics),
              isDark,
              cardWidth,
            ),
          ],
        );
      }
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap, bool isDark, double width) {
    return AppCard(
      interactive: true,
      onTap: onTap,
      width: width,
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryPurple, size: 24),
          const SizedBox(height: 8),
          Text(
            title, 
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.visible,
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 10, 
              color: AppColors.primaryPurple,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassItem(String time, String section, String subject, String room, bool isDark, BuildContext context, String sectionId) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        interactive: true,
        onTap: () => context.push(AppRoutes.teacherSectionDetails(sectionId)),
        child: Row(
          children: [
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                time,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple, fontSize: 11),
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
            const Icon(Icons.chevron_right, color: AppColors.neutralGray, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAssessments(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Upcoming Assessments', 
                style: AppTextStyles.h2.copyWith(color: isDark ? Colors.white : AppColors.deepPurple),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => context.go(AppRoutes.teacherAssessments),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAssessmentSummaryCard(context, 'Real-time Check', 'All Sections', 'Syncing...', isDark),
      ],
    );
  }

  Widget _buildAssessmentSummaryCard(BuildContext context, String title, String section, String time, bool isDark) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.timer_outlined, size: 16, color: AppColors.warning),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$section • $time', 
            style: const TextStyle(color: AppColors.neutralGray, fontSize: 13),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, btnConstraints) {
              return Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Details',
                      type: AppButtonType.primary,
                      height: 36,
                      onPressed: () => context.go(AppRoutes.teacherAssessments),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppButton(
                      text: 'Scanner',
                      type: AppButtonType.outline,
                      height: 36,
                      onPressed: () => context.push(AppRoutes.teacherScanner),
                    ),
                  ),
                ],
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAnalyticsPreview(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Analytics', 
          style: AppTextStyles.h2.copyWith(color: isDark ? Colors.white : AppColors.deepPurple),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology_outlined, color: AppColors.primaryPurple, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Performance Insights', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Monitor real-time progress and identify students needing support based on live data.',
                style: TextStyle(color: AppColors.neutralGray, fontSize: 13),
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: 0.85,
                backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
              ),
            ],
          ),
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
            _buildStatCard('Total Students', '$_totalStudents', Icons.people_outline_rounded, AppColors.primaryPurple, isDark),
            _buildStatCard('Active Sections', '$_activeSectionsCount', Icons.grid_view_rounded, AppColors.accentPurple, isDark),
            _buildStatCard('Today\'s Classes', '${_recentSections.length}', Icons.schedule_rounded, AppColors.success, isDark),
            _buildStatCard('Pending Results', '$_pendingResultsCount', Icons.pending_actions_rounded, AppColors.warning, isDark),
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
          subtitle: 'Average scores across your active sections',
          chart: _recentSections.isEmpty 
            ? const Center(child: Text('No performance data available.', style: TextStyle(color: AppColors.neutralGray)))
            : BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barGroups: _recentSections.asMap().entries.map((e) {
                    return _buildBarGroup(e.key, e.value.averagePerformance > 0 ? e.value.averagePerformance : 75, AppColors.primaryPurple, isDark);
                  }).toList(),
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
                          final index = value.toInt();
                          if (index < 0 || index >= _recentSections.length) return const Text('');
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(_recentSections[index].name, style: style, overflow: TextOverflow.ellipsis),
                          );
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
                  Expanded(
                    child: Text(
                      'Live Performance Alerts',
                      style: AppTextStyles.h3.copyWith(color: isDark ? Colors.white : AppColors.deepPurple),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildAttentionItem(
                'Data Sync Complete',
                'All sections are currently performing within expected parameters.',
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
          width: 24, 
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
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
                    'Active Groups',
                    style: AppTextStyles.h3.copyWith(color: isDark ? Colors.white : AppColors.deepPurple),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.teacherSections),
                    child: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_recentSections.isEmpty)
                const Text('No active sections found.', style: TextStyle(color: AppColors.neutralGray, fontSize: 12))
              else
                ..._recentSections.take(2).map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    dense: true,
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(s.subject),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                    onTap: () => context.push(AppRoutes.teacherSectionDetails(s.id)),
                  ),
                )),
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
                onPressed: () => context.push(AppRoutes.teacherLessonPlan),
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
}
