import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../shared/widgets/cards/app_card.dart';
import '../../shared/widgets/inputs/app_search_bar.dart';
import '../../data/local/sample_data.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Grades Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: AppSearchBar(hint: 'Search by student...')),
                const SizedBox(width: 16),
                _buildFilterButton('Section 1'),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatistics(),
            const SizedBox(height: 24),
            Expanded(
              child: AppCard(
                padding: EdgeInsets.zero,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Student Name')),
                      DataColumn(label: Text('Assessment')),
                      DataColumn(label: Text('Score')),
                      DataColumn(label: Text('Percentage')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: SampleData.grades.map((grade) {
                      return DataRow(cells: [
                        DataCell(Text(grade.studentName)),
                        DataCell(Text(grade.assessmentTitle)),
                        DataCell(Text('${grade.score}/${grade.total}')),
                        DataCell(Text('${grade.percentage.toStringAsFixed(1)}%')),
                        DataCell(_buildGradeStatus(grade.percentage)),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.softPurple,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
          const Icon(Icons.arrow_drop_down, color: AppColors.primaryPurple),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Row(
      children: [
        _buildStatItem('Class Average', '85.2%', AppColors.primaryPurple),
        const SizedBox(width: 16),
        _buildStatItem('Highest Score', '10.0', AppColors.success),
        const SizedBox(width: 16),
        _buildStatItem('Lowest Score', '6.5', AppColors.error),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeStatus(double percentage) {
    if (percentage >= 75) {
      return const Text('Passed', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold));
    }
    return const Text('Failed', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold));
  }
}
