import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/models/user_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/buttons/app_button.dart';
import '../../shared/widgets/cards/app_card.dart';
import '../../shared/widgets/states/status_badge.dart';
import '../../app/routes.dart';
import '../../shared/widgets/animations/animated_purple_background.dart';

class TeacherRegistrationScreen extends StatefulWidget {
  const TeacherRegistrationScreen({super.key});

  @override
  State<TeacherRegistrationScreen> createState() => _TeacherRegistrationScreenState();
}

class _TeacherRegistrationScreenState extends State<TeacherRegistrationScreen> {
  int _currentStep = 0;
  final _personalFormKey = GlobalKey<FormState>();
  final _professionalFormKey = GlobalKey<FormState>();
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _schoolController = TextEditingController();
  final _subjectController = TextEditingController();
  final _employeeIdController = TextEditingController();

  PlatformFile? _selectedFile;
  String? _fileError;
  bool _isPickingFile = false;

  Future<void> _pickVerificationFile() async {
    setState(() {
      _isPickingFile = true;
      _fileError = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        const maxSizeBytes = 5 * 1024 * 1024; // 5 MB

        if (file.size > maxSizeBytes) {
          final sizeMb = (file.size / (1024 * 1024)).toStringAsFixed(1);
          setState(() {
            _selectedFile = null;
            _fileError = 'File size exceeds 5MB limit ($sizeMb MB selected). Please choose a smaller file.';
            _isPickingFile = false;
          });
          return;
        }

        setState(() {
          _selectedFile = file;
          _fileError = null;
          _isPickingFile = false;
        });
      } else {
        setState(() => _isPickingFile = false);
      }
    } catch (e) {
      debugPrint('File picker error: $e');
      setState(() {
        _fileError = 'Unable to open file picker. Please try again.';
        _isPickingFile = false;
      });
    }
  }

  Future<void> _handleRegistration() async {
    final authService = context.read<AuthService>();
    
    // Send OTP first
    final otpSent = await authService.sendOtp(_emailController.text);
    if (!otpSent) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send verification code. Check your email.')),
        );
      }
      return;
    }

    if (mounted) {
      String? base64Bytes;
      if (_selectedFile?.bytes != null && _selectedFile!.bytes!.isNotEmpty) {
        base64Bytes = base64Encode(_selectedFile!.bytes!);
      }

      // Navigate to OTP screen and pass the registration data
      context.push(AppRoutes.otpVerification, extra: {
        'email': _emailController.text,
        'password': _passwordController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'school': _schoolController.text,
        'subject': _subjectController.text,
        'employeeId': _employeeIdController.text,
        'verificationFile': _selectedFile?.name ?? 'Teacher_ID_Document.pdf',
        'verificationBytes': base64Bytes,
        'role': 'teacher',
        'isRegistration': true,
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!(_personalFormKey.currentState?.validate() ?? false)) return;
    } else if (_currentStep == 1) {
      if (!(_professionalFormKey.currentState?.validate() ?? false)) return;
    } else if (_currentStep == 2) {
      if (_selectedFile == null) {
        setState(() {
          _fileError = 'Please select a valid Teacher ID or School ID file (PDF, JPG, or PNG under 5MB).';
        });
        return;
      }
    }
    
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _handleRegistration();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = context.watch<AuthService>().isLoading;

    return Scaffold(
      body: AnimatedPurpleBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: const Text('Teacher Registration'),
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : AppColors.deepPurple),
                  onPressed: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep--);
                    } else {
                      context.pop();
                    }
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        children: [
                          _buildStepIndicator(isDark),
                          const SizedBox(height: 48),
                          AppCard(
                            padding: const EdgeInsets.all(32),
                            child: _buildCurrentStep(isDark),
                          ),
                          const SizedBox(height: 32),
                          AppButton(
                            text: _currentStep == 2 ? 'Send Verification Code' : 'Continue',
                            type: AppButtonType.gradient,
                            width: double.infinity,
                            isLoading: isLoading,
                            onPressed: _nextStep,
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    return Row(
      children: [
        _indicatorItem(0, 'Personal', isDark),
        _indicatorLine(0),
        _indicatorItem(1, 'Professional', isDark),
        _indicatorLine(1),
        _indicatorItem(2, 'Verification', isDark),
      ],
    );
  }

  Widget _indicatorItem(int step, String label, bool isDark) {
    bool isActive = _currentStep >= step;
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryPurple : (isDark ? Colors.white10 : AppColors.softPurple),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${step + 1}',
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.neutralGray,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label, 
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.primaryPurple : AppColors.neutralGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _indicatorLine(int step) {
    bool isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.primaryPurple : AppColors.neutralGray.withOpacity(0.2),
        margin: const EdgeInsets.only(bottom: 20),
      ),
    );
  }

  Widget _buildCurrentStep(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep(isDark);
      case 1:
        return _buildProfessionalInfoStep(isDark);
      case 2:
        return _buildVerificationStep(isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalInfoStep(bool isDark) {
    return Form(
      key: _personalFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Details',
            style: AppTextStyles.h2.copyWith(color: isDark ? Colors.white : AppColors.deepPurple),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(hintText: 'First Name', prefixIcon: Icon(Icons.person_outline_rounded)),
            validator: (v) => Validators.name(v, 'First Name'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(hintText: 'Last Name', prefixIcon: Icon(Icons.person_outline_rounded)),
            validator: (v) => Validators.name(v, 'Last Name'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(hintText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(hintText: 'Password', prefixIcon: Icon(Icons.lock_outline_rounded)),
            obscureText: true,
            validator: Validators.password,
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoStep(bool isDark) {
    return Form(
      key: _professionalFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Professional Info',
            style: AppTextStyles.h2.copyWith(color: isDark ? Colors.white : AppColors.deepPurple),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _schoolController,
            decoration: const InputDecoration(hintText: 'School / Institution', prefixIcon: Icon(Icons.business_rounded)),
            validator: (v) => Validators.required(v, 'School/Institution'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _subjectController,
            decoration: const InputDecoration(hintText: 'Subject(s) Taught', prefixIcon: Icon(Icons.book_outlined)),
            validator: (v) => Validators.required(v, 'Subject'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _employeeIdController,
            decoration: const InputDecoration(hintText: 'Employee ID (Optional)', prefixIcon: Icon(Icons.badge_outlined)),
            validator: (v) => Validators.charLimit(v, 'Employee ID', max: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStep(bool isDark) {
    String fileSizeStr = '';
    if (_selectedFile != null) {
      final bytes = _selectedFile!.size;
      if (bytes < 1024 * 1024) {
        fileSizeStr = '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else {
        fileSizeStr = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    }

    final isPdf = _selectedFile?.extension?.toLowerCase() == 'pdf';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Verification', 
          style: AppTextStyles.h2.copyWith(color: isDark ? Colors.white : AppColors.deepPurple),
        ),
        const SizedBox(height: 12),
        const Text(
          'Upload a valid Teacher ID or School ID to verify your identity. Accounts are manually reviewed.',
          style: TextStyle(color: AppColors.neutralGray, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 32),

        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _pickVerificationFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _fileError != null 
                      ? AppColors.error 
                      : (_selectedFile != null ? AppColors.success : AppColors.primaryPurple.withOpacity(0.2)),
                  width: 2,
                ),
              ),
              child: _isPickingFile
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryPurple),
                      SizedBox(height: 16),
                      Text('Opening file picker...', style: TextStyle(color: AppColors.neutralGray, fontSize: 13)),
                    ],
                  )
                : _selectedFile == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.primaryPurple.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.cloud_upload_rounded, color: AppColors.primaryPurple, size: 36),
                        ),
                        const SizedBox(height: 16),
                        const Text('Drop file or tap to upload', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        const Text('PDF, JPG, or PNG (Max 5MB)', style: TextStyle(fontSize: 12, color: AppColors.neutralGray)),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded, 
                                color: AppColors.primaryPurple, 
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedFile!.name, 
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 14,
                                      color: isDark ? Colors.white : AppColors.deepPurple,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    fileSizeStr, 
                                    style: const TextStyle(fontSize: 12, color: AppColors.neutralGray),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge.success('File Attached'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: _pickVerificationFile,
                              icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: AppColors.primaryPurple),
                              label: const Text('Change File', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => setState(() => _selectedFile = null),
                              icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.error),
                              label: const Text('Remove', style: TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),

        if (_fileError != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.error),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _fileError!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
