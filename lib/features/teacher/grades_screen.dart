import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../shared/widgets/cards/app_card.dart';
import '../../shared/widgets/inputs/app_search_bar.dart';
import '../../core/services/academic_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/reporting_service.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    final authService = context.read<AuthService>();
    final academicService = context.read<AcademicService>();
    
    if (authService.currentUser != null) {
      final results = await academicService.fetchGrades(authService.currentUser!.id);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    }
  }

  void _exportPdf() {
    if (_results.isEmpty) return;
    ReportingService.generateGradesPdf(
      sectionName: 'All Sections', 
      results: _results
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = _results.where((r) {
      final name = '${r['profiles']?['first_name'] ?? ''} ${r['profiles']?['last_name'] ?? ''}'.toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Grades Management'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryPurple),
            onPressed: _loadGrades,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.file_download_outlined, color: AppColors.primaryPurple),
              onPressed: _exportPdf,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: AppSearchBar(
                  hint: 'Search by student name...',
                  onChanged: (val) => setState(() => _searchQuery = val),
                )),
                const SizedBox(width: 16),
                _buildFilterButton('All Sections', isDark),
              ],
            ),
            const SizedBox(height: 32),
            _buildStatistics(filtered, isDark),
            const SizedBox(height: 32),
            Text(
              'Grade Roster', 
              style: AppTextStyles.h3.copyWith(color: isDark ? Colors.white70 : AppColors.deepPurple),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
                : filtered.isEmpty
                  ? _buildEmptyState(isDark)
                  : AppCard(
                      padding: EdgeInsets.zero,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(AppColors.primaryPurple.withOpacity(0.05)),
                            columns: [
                              DataColumn(label: Text('STUDENT NAME', style: _headerStyle(isDark))),
                              DataColumn(label: Text('SOURCE', style: _headerStyle(isDark))),
                              DataColumn(label: Text('SCORE', style: _headerStyle(isDark))),
                              DataColumn(label: Text('PERCENTAGE', style: _headerStyle(isDark))),
                              DataColumn(label: Text('STATUS', style: _headerStyle(isDark))),
                            ],
                            rows: filtered.map((res) {
                              final profile = res['profiles'] ?? {};
                              final studentName = '${profile['first_name'] ?? 'Student'} ${profile['last_name'] ?? ''}';
                              final title = res['assessments']?['title'] ?? res['activities']?['title'] ?? 'N/A';
                              final score = res['score'] ?? 0;
                              final total = res['total_possible'] ?? 100;
                              final percentage = total > 0 ? (score / total) * 100 : 0.0;

                              return DataRow(cells: [
                                DataCell(Text(studentName, style: _cellStyle(isDark, bold: true))),
                                DataCell(Text(title, style: _cellStyle(isDark))),
                                DataCell(Text('$score/$total', style: _cellStyle(isDark))),
                                DataCell(Text('${percentage.toStringAsFixed(1)}%', style: _cellStyle(isDark))),
                                DataCell(_buildGradeStatus(percentage)),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grade_outlined, size: 64, color: AppColors.neutralGray.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No records found.', style: TextStyle(color: AppColors.neutralGray, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  TextStyle _headerStyle(bool isDark) => TextStyle(
    fontSize: 12, 
    fontWeight: FontWeight.w800, 
    color: isDark ? Colors.white70 : AppColors.deepPurple.withOpacity(0.6),
    letterSpacing: 0.5,
  );

  TextStyle _cellStyle(bool isDark, {bool bold = false}) => TextStyle(
    color: isDark ? Colors.white : AppColors.deepPurple,
    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    fontSize: 13,
  );

  Widget _buildFilterButton(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Text(
            label, 
            style: const TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryPurple, size: 18),
        ],
      ),
    );
  }

  Widget _buildStatistics(List<Map<String, dynamic>> results, bool isDark) {
    double average = 0;
    double highest = 0;
    double lowest = 0;

    if (results.isNotEmpty) {
      final percentages = results.map((r) {
        final score = r['score'] ?? 0;
        final total = r['total_possible'] ?? 100;
        return total > 0 ? (score / total) * 100.0 : 0.0;
      }).toList();

      average = percentages.reduce((a, b) => a + b) / percentages.length;
      highest = percentages.reduce((a, b) => a > b ? a : b);
      lowest = percentages.reduce((a, b) => a < b ? a : b);
    }

    return Row(
      children: [
        _buildStatItem('Average', '${average.toStringAsFixed(1)}%', AppColors.primaryPurple, isDark),
        const SizedBox(width: 20),
        _buildStatItem('Highest', results.isEmpty ? 'N/A' : '${highest.toStringAsFixed(1)}%', AppColors.success, isDark),
        const SizedBox(width: 20),
        _buildStatItem('Lowest', results.isEmpty ? 'N/A' : '${lowest.toStringAsFixed(1)}%', AppColors.error, isDark),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label, 
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              value, 
              style: TextStyle(
                color: isDark ? Colors.white : color, 
                fontSize: 24, 
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeStatus(double percentage) {
    if (percentage >= 75) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
        child: const Text('Passed', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: const Text('Failed', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}
