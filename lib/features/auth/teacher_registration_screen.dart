import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../shared/widgets/buttons/app_button.dart';
import '../../shared/widgets/cards/app_card.dart';
import '../../app/routes.dart';

class TeacherRegistrationScreen extends StatefulWidget {
  const TeacherRegistrationScreen({super.key});

  @override
  State<TeacherRegistrationScreen> createState() => _TeacherRegistrationScreenState();
}

class _TeacherRegistrationScreenState extends State<TeacherRegistrationScreen> {
  int _currentStep = 0;
  
  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      context.push(AppRoutes.otpVerification);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                _buildStepIndicator(),
                const SizedBox(height: 32),
                AppCard(
                  padding: const EdgeInsets.all(32),
                  showShadow: true,
                  child: _buildCurrentStep(),
                ),
                const SizedBox(height: 32),
                AppButton(
                  text: _currentStep == 2 ? 'Submit Application' : 'Continue',
                  type: AppButtonType.gradient,
                  width: double.infinity,
                  onPressed: _nextStep,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _indicatorItem(0, 'Personal'),
        _indicatorLine(0),
        _indicatorItem(1, 'Professional'),
        _indicatorLine(1),
        _indicatorItem(2, 'Verification'),
      ],
    );
  }

  Widget _indicatorItem(int step, String label) {
    bool isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryPurple : AppColors.softPurple,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _indicatorLine(int step) {
    bool isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.primaryPurple : AppColors.softPurple,
        margin: const EdgeInsets.only(bottom: 20),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildProfessionalInfoStep();
      case 2:
        return _buildVerificationStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Personal Information', style: AppTextStyles.h3),
        const SizedBox(height: 24),
        const TextField(decoration: InputDecoration(hintText: 'First Name')),
        const SizedBox(height: 16),
        const TextField(decoration: InputDecoration(hintText: 'Last Name')),
        const SizedBox(height: 16),
        const TextField(decoration: InputDecoration(hintText: 'Email Address')),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(hintText: 'Password'),
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildProfessionalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Professional Information', style: AppTextStyles.h3),
        const SizedBox(height: 24),
        const TextField(decoration: InputDecoration(hintText: 'School / Institution')),
        const SizedBox(height: 16),
        const TextField(decoration: InputDecoration(hintText: 'Subject(s) Taught')),
        const SizedBox(height: 16),
        const TextField(decoration: InputDecoration(hintText: 'Employee ID (Optional)')),
      ],
    );
  }

  Widget _buildVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account Verification', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        const Text(
          'Please upload a valid Teacher ID or School ID to verify your identity. Your account will be pending until admin approval.',
          style: TextStyle(color: AppColors.neutralGray),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.softPurple.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryPurple.withOpacity(0.2), style: BorderStyle.solid),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined, color: AppColors.primaryPurple, size: 40),
              SizedBox(height: 12),
              Text('Upload Document', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryPurple)),
              Text('PDF, JPG, or PNG (Max 5MB)', style: TextStyle(fontSize: 12, color: AppColors.neutralGray)),
            ],
          ),
        ),
      ],
    );
  }
}
