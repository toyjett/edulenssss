import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../shared/widgets/cards/app_card.dart';
import '../../shared/widgets/states/status_badge.dart';
import '../../shared/widgets/buttons/app_button.dart';
import '../../core/services/academic_service.dart';

class TeacherApprovalsScreen extends StatefulWidget {
  const TeacherApprovalsScreen({super.key});

  @override
  State<TeacherApprovalsScreen> createState() => _TeacherApprovalsScreenState();
}

class _TeacherApprovalsScreenState extends State<TeacherApprovalsScreen> {
  List<Map<String, dynamic>> _pendingTeachers = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() => _isLoading = true);
    final academicService = context.read<AcademicService>();
    final pending = await academicService.fetchPendingTeachers();
    if (mounted) {
      setState(() {
        _pendingTeachers = pending;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAction(Map<String, dynamic> teacher, String status) async {
    final name = '${teacher['first_name']} ${teacher['last_name']}';
    final id = teacher['id'] ?? '';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(status == 'active' ? 'Approve Teacher?' : 'Reject Teacher?'),
        content: Text(
          status == 'active'
              ? 'Are you sure you want to approve $name? They will be granted full instructor access.'
              : 'Are you sure you want to decline $name\'s registration application?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'active' ? AppColors.success : AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(status == 'active' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final academicService = context.read<AcademicService>();
    final success = await academicService.updateTeacherStatus(id, status, teacherName: name, email: teacher['email']);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Teacher $name ${status == 'active' ? 'approved successfully' : 'declined'}.'),
          backgroundColor: status == 'active' ? AppColors.success : AppColors.error,
        ),
      );
      _loadPending();
    }
  }

  void _showDocumentViewerDialog(Map<String, dynamic> teacher, bool isDark) {
    final name = '${teacher['first_name']} ${teacher['last_name']}';
    final email = teacher['email'] ?? 'N/A';
    final school = teacher['school'] ?? 'Filipino National High School';
    final subject = teacher['subject'] ?? 'Filipino Teacher';
    final empId = teacher['employee_id'] ?? 'N/A';
    final fileName = (teacher['verificationFile'] ?? teacher['verification_file'] ?? 'Teacher_ID_Document.pdf').toString();
    final isApproved = (teacher['status'] ?? 'pending').toString().toLowerCase() == 'active';

    Uint8List? fileBytes;
    final rawBytes = teacher['verification_bytes'] ?? teacher['verificationBytes'];
    if (rawBytes is String && rawBytes.isNotEmpty) {
      try {
        final cleanBase64 = rawBytes.contains(',') ? rawBytes.split(',').last : rawBytes;
        fileBytes = base64Decode(cleanBase64);
      } catch (e) {
        debugPrint('Base64 decode error: $e');
      }
    } else if (rawBytes is Uint8List) {
      fileBytes = rawBytes;
    }

    final isPdf = fileName.toLowerCase().endsWith('.pdf');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 650),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded, 
                        color: AppColors.primaryPurple, 
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Credential Document Viewer', style: AppTextStyles.h3.copyWith(color: isDark ? Colors.white : AppColors.deepPurple)),
                          Text(fileName, style: const TextStyle(fontSize: 12, color: AppColors.neutralGray)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 24),

              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withOpacity(0.3) : AppColors.softPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: fileBytes != null && fileBytes.isNotEmpty
                      ? (isPdf
                          ? PdfPreview(
                              build: (format) async => fileBytes!,
                              allowPrinting: true,
                              allowSharing: true,
                              canChangeOrientation: false,
                              canDebug: false,
                              initialPageFormat: PdfPageFormat.a4,
                              loadingWidget: const Center(
                                child: CircularProgressIndicator(color: AppColors.primaryPurple),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Image.memory(
                                  fileBytes,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => _buildGeneratedIdCard(name, email, school, subject, empId, isDark),
                                ),
                              ),
                            ))
                      : (isPdf
                          ? _buildPdfFallbackCard(fileName, name, school, subject, empId, isDark)
                          : _buildGeneratedIdCard(name, email, school, subject, empId, isDark)),
                  ),
                ),
              ),

              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close Viewer'),
                  ),
                  Row(
                    children: [
                      if (fileBytes != null && isPdf) ...[
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryPurple),
                          onPressed: () => Printing.layoutPdf(onLayout: (format) async => fileBytes!),
                          icon: const Icon(Icons.open_in_new_rounded, size: 16),
                          label: const Text('Open PDF'),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (!isApproved) ...[
                        AppButton(
                          text: 'Decline',
                          type: AppButtonType.outline,
                          height: 38,
                          onPressed: () {
                            Navigator.pop(ctx);
                            _handleAction(teacher, 'rejected');
                          },
                        ),
                        const SizedBox(width: 12),
                        AppButton(
                          text: 'Approve Teacher',
                          type: AppButtonType.gradient,
                          height: 38,
                          onPressed: () {
                            Navigator.pop(ctx);
                            _handleAction(teacher, 'active');
                          },
                        ),
                      ] else ...[
                        StatusBadge.success('Verified & Active'),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPdfFallbackCard(String fileName, String name, String school, String subject, String empId, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primaryPurple, size: 56),
            ),
            const SizedBox(height: 20),
            Text(fileName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : AppColors.deepPurple)),
            const SizedBox(height: 8),
            Text('Submitted PDF Document by $name • $school', style: const TextStyle(fontSize: 12, color: AppColors.neutralGray)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _launchGeneratedPdfViewer(fileName, name, school, subject, empId),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Open & View PDF Document'),
            ),
          ],
        ),
      ),
    );
  }

  void _launchGeneratedPdfViewer(String fileName, String name, String school, String subject, String empId) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Center(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(32),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.purple, width: 2),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(school.isNotEmpty ? school : 'Filipino National High School', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.purple)),
                pw.SizedBox(height: 8),
                pw.Text('OFFICIAL FACULTY VERIFICATION CREDENTIAL', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
                pw.Divider(thickness: 1.5),
                pw.SizedBox(height: 24),
                pw.Text('Document Title: $fileName', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),
                pw.Text('Applicant Name: $name', style: pw.TextStyle(fontSize: 14)),
                pw.Text('Subject Area: $subject', style: pw.TextStyle(fontSize: 14)),
                pw.Text('Employee ID: ${empId.isNotEmpty ? empId : "EMP-VERIFIED"}', style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 32),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: pw.BoxDecoration(color: PdfColors.purple50, borderRadius: pw.BorderRadius.circular(6)),
                  child: pw.Text('VERIFIED REGISTRATION ATTACHMENT • EDULENS LMS', style: pw.TextStyle(fontSize: 10, color: PdfColors.purple900, fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Widget _buildGeneratedIdCard(String name, String email, String school, String subject, String empId, bool isDark) {
    return Container(
      width: 480,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.4) : AppColors.softPurple.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_rounded, color: AppColors.primaryPurple, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      school.isNotEmpty ? school : 'Filipino National High School',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : AppColors.deepPurple),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text('OFFICIAL FACULTY IDENTIFICATION CARD', style: TextStyle(fontSize: 10, color: AppColors.primaryPurple, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ],
                ),
              ),
              StatusBadge.info('Attached Document'),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primaryPurple.withOpacity(0.15),
                child: Text(
                  name.isNotEmpty ? name[0] : 'T',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryPurple),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : AppColors.deepPurple)),
                    const SizedBox(height: 4),
                    Text('Subject: $subject', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryPurple)),
                    Text('Email: $email', style: const TextStyle(fontSize: 12, color: AppColors.neutralGray)),
                    Text('Employee ID: ${empId.isNotEmpty ? empId : "N/A"}', style: const TextStyle(fontSize: 12, color: AppColors.neutralGray)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_rounded, color: AppColors.success, size: 16),
                SizedBox(width: 8),
                Text('EDULENS FACULTY IDENTITY VERIFICATION DOCUMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryPurple)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCredentialsModal(Map<String, dynamic> teacher, bool isDark) {
    final name = '${teacher['first_name']} ${teacher['last_name']}';
    final email = teacher['email'] ?? 'N/A';
    final school = teacher['school'] ?? 'Filipino National High School';
    final subject = teacher['subject'] ?? 'Filipino';
    final empId = teacher['employee_id'] ?? 'Not Provided';
    final fileName = teacher['verificationFile'] ?? teacher['verification_file'] ?? 'Teacher_ID_Document.pdf';
    final isApproved = (teacher['status'] ?? 'pending').toString().toLowerCase() == 'active';
    final createdAt = teacher['created_at'] != null 
        ? DateFormat('MMMM dd, yyyy - hh:mm a').format(DateTime.parse(teacher['created_at']))
        : 'N/A';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user_rounded, color: AppColors.primaryPurple, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Text('Instructor Credential Verification', style: TextStyle(fontSize: 12, color: AppColors.neutralGray)),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              _modalDetailRow('Email Address', email, Icons.email_outlined),
              _modalDetailRow('School / Institution', school, Icons.business_rounded),
              _modalDetailRow('Subject(s) Taught', subject, Icons.book_outlined),
              _modalDetailRow('Employee ID', empId, Icons.badge_outlined),
              _modalDetailRow('Submission Date', createdAt, Icons.calendar_today_rounded),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Submitted Identity Document',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white : AppColors.deepPurple,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showDocumentViewerDialog(teacher, isDark);
                    },
                    icon: const Icon(Icons.visibility_rounded, size: 16, color: AppColors.primaryPurple),
                    label: const Text('Inspect Document', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryPurple)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _showDocumentViewerDialog(teacher, isDark);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryPurple.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.file_present_rounded, color: AppColors.primaryPurple, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fileName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              isApproved 
                                  ? 'Verified ID Document • Approved' 
                                  : 'Tap to inspect attached document', 
                              style: const TextStyle(fontSize: 11, color: AppColors.neutralGray),
                            ),
                          ],
                        ),
                      ),
                      isApproved 
                          ? StatusBadge.success('Verified File') 
                          : StatusBadge.warning('Pending Inspection'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _handleAction(teacher, 'active');
            },
            icon: const Icon(Icons.check_circle_rounded, size: 18),
            label: const Text('Approve Now'),
          ),
        ],
      ),
    );
  }

  Widget _modalDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.neutralGray, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = _pendingTeachers.where((t) {
      final name = '${t['first_name']} ${t['last_name']}'.toLowerCase();
      final email = (t['email'] ?? '').toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || email.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Teacher Verification & Approvals'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryPurple),
            onPressed: _loadPending,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Applications (${_pendingTeachers.length})', 
                      style: AppTextStyles.h2.copyWith(color: isDark ? Colors.white : AppColors.deepPurple),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Review instructor registrations and verify credentials before granting access.', 
                      style: TextStyle(color: AppColors.neutralGray),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search pending teachers by name or email...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.neutralGray),
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 32),

            _isLoading 
              ? const Center(child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(color: AppColors.primaryPurple),
                ))
              : filtered.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final teacher = filtered[index];
                      return _buildApprovalCard(teacher, isDark);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return AppCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(64.0),
          child: Column(
            children: [
              Icon(Icons.check_circle_outline_rounded, size: 64, color: AppColors.success.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty ? 'No Pending Teacher Approvals' : 'No matching applications found',
                style: AppTextStyles.h3.copyWith(color: isDark ? Colors.white : AppColors.deepPurple),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isEmpty 
                    ? 'All instructor registrations have been reviewed and processed.' 
                    : 'Try searching for another name or clearing the search box.',
                style: const TextStyle(color: AppColors.neutralGray),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalCard(Map<String, dynamic> teacher, bool isDark) {
    final name = '${teacher['first_name']} ${teacher['last_name']}';
    final email = teacher['email'] ?? 'N/A';
    final school = teacher['school'] ?? 'Filipino National High School';
    final subject = teacher['subject'] ?? 'Filipino Teacher';
    final empId = teacher['employee_id'] ?? 'N/A';
    
    String timeStr = 'Recently';
    if (teacher['created_at'] != null) {
      try {
        timeStr = DateFormat('MMM dd, yyyy').format(DateTime.parse(teacher['created_at']));
      } catch (_) {}
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
                child: Text(
                  name.isNotEmpty ? name[0] : 'T', 
                  style: const TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name, 
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16,
                              color: isDark ? Colors.white : AppColors.deepPurple,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StatusBadge.warning('Pending Approval'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$subject • $school', 
                      style: const TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Email: $email • Submitted: $timeStr', 
                      style: const TextStyle(color: AppColors.neutralGray, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.badge_outlined, size: 16, color: AppColors.neutralGray),
                    const SizedBox(width: 8),
                    Text('Employee ID: $empId', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                InkWell(
                  onTap: () => _showCredentialsModal(teacher, isDark),
                  child: const Row(
                    children: [
                      Icon(Icons.visibility_rounded, size: 16, color: AppColors.primaryPurple),
                      SizedBox(width: 4),
                      Text('View Credentials', style: TextStyle(fontSize: 12, color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                text: 'Decline',
                type: AppButtonType.outline,
                height: 36,
                onPressed: () => _handleAction(teacher, 'rejected'),
              ),
              const SizedBox(width: 12),
              AppButton(
                text: 'Approve Teacher', 
                type: AppButtonType.primary,
                height: 36,
                onPressed: () => _handleAction(teacher, 'active'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
