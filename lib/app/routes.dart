import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/welcome_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_selection_screen.dart';
import '../features/auth/teacher_registration_screen.dart';
import '../features/auth/student_registration_screen.dart';
import '../features/auth/otp_verification_screen.dart';
import '../features/auth/pending_approval_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/teacher/teacher_main_layout.dart';
import '../features/teacher/dashboard_screen.dart';
import '../features/teacher/sections_screen.dart';
import '../features/teacher/section_details_screen.dart';
import '../features/teacher/students_screen.dart';
import '../features/teacher/lessons_screen.dart';
import '../features/teacher/materials_screen.dart';
import '../features/teacher/assessments_screen.dart';
import '../features/teacher/assessment_builder_screen.dart';
import '../features/teacher/activities_screen.dart';
import '../features/teacher/grades_screen.dart';
import '../features/teacher/attendance_screen.dart';
import '../features/teacher/rfid_attendance_screen.dart';
import '../features/teacher/learning_analytics_screen.dart';
import '../features/teacher/item_analysis_screen.dart';
import '../features/teacher/reports_screen.dart';
import '../features/teacher/lesson_plan_assistance_screen.dart';
import '../features/teacher/schedule_screen.dart';
import '../features/student/student_main_layout.dart';
import '../features/student/dashboard_screen.dart';
import '../features/student/classes_screen.dart';
import '../features/student/lessons_screen.dart';
import '../features/student/materials_screen.dart';
import '../features/student/assessments_screen.dart';
import '../features/student/activities_screen.dart';
import '../features/student/grades_screen.dart';
import '../features/student/progress_screen.dart';
import '../features/student/achievements_screen.dart';
import '../features/student/schedule_screen.dart';
import '../features/admin/admin_main_layout.dart';
import '../features/admin/dashboard_screen.dart';
import '../features/admin/teacher_approvals_screen.dart';
import '../features/admin/user_management_screen.dart';
import '../features/admin/rfid_monitoring_screen.dart';
import '../features/admin/admin_activity_screen.dart';
import '../features/admin/admin_settings_screen.dart';
import '../features/admin/scanning_monitoring_screen.dart';

// Placeholder screens for navigation setup
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text('This is the $title screen')),
  );
}

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String registerTeacher = '/register/teacher';
  static const String registerStudent = '/register/student';
  static const String otpVerification = '/otp';
  static const String pendingApproval = '/pending-approval';
  static const String forgotPassword = '/forgot-password';

  static const String teacherDashboard = '/teacher';
  static const String teacherSections = '/teacher/sections';
  static String teacherSectionDetails(String id) => '/teacher/sections/$id';
  static const String teacherStudents = '/teacher/students';
  static const String teacherLessons = '/teacher/lessons';
  static const String teacherMaterials = '/teacher/materials';
  static const String teacherAssessments = '/teacher/assessments';
  static const String teacherAssessmentBuilder = '/teacher/assessments/new';
  static const String teacherActivities = '/teacher/activities';
  static const String teacherGrades = '/teacher/grades';
  static const String teacherAttendance = '/teacher/attendance';
  static const String teacherRfidAttendance = '/teacher/attendance/rfid';
  static const String teacherAnalytics = '/teacher/analytics';
  static const String teacherItemAnalysis = '/teacher/item-analysis';
  static const String teacherReports = '/teacher/reports';
  static const String teacherLessonPlan = '/teacher/lesson-plan';
  static const String teacherSchedule = '/teacher/schedule';

  static const String studentDashboard = '/student';
  static const String studentClasses = '/student/classes';
  static const String studentLessons = '/student/lessons';
  static const String studentMaterials = '/student/materials';
  static const String studentAssessments = '/student/assessments';
  static const String studentActivities = '/student/activities';
  static const String studentGrades = '/student/grades';
  static const String studentProgress = '/student/progress';
  static const String studentAchievements = '/student/achievements';
  static const String studentSchedule = '/student/schedule';

  static const String adminDashboard = '/admin';
  static const String adminApprovals = '/admin/approvals';
  static const String adminUsers = '/admin/users';
  static const String adminActivity = '/admin/activity';
  static const String adminRfid = '/admin/rfid';
  static const String adminScanning = '/admin/scanning';
  static const String adminSettings = '/admin/settings';

  static final router = GoRouter(
    initialLocation: welcome,
    routes: [
      GoRoute(
        path: welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterSelectionScreen(),
      ),
      GoRoute(
        path: registerTeacher,
        builder: (context, state) => const TeacherRegistrationScreen(),
      ),
      GoRoute(
        path: registerStudent,
        builder: (context, state) => const StudentRegistrationScreen(),
      ),
      GoRoute(
        path: otpVerification,
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: pendingApproval,
        builder: (context, state) => const PendingApprovalScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Teacher Shell Route
      ShellRoute(
        builder: (context, state, child) {
          int index = 0;
          final loc = state.matchedLocation;
          if (loc.contains('sections')) index = 1;
          else if (loc.contains('students')) index = 2;
          else if (loc.contains('lessons')) index = 3;
          else if (loc.contains('materials')) index = 4;
          else if (loc.contains('assessments')) index = 5;
          else if (loc.contains('activities')) index = 6;
          else if (loc.contains('grades')) index = 7;
          else if (loc.contains('attendance')) index = 8;
          else if (loc.contains('schedule')) index = 9;
          else if (loc.contains('analytics')) index = 10;
          else if (loc.contains('item-analysis')) index = 11;
          else if (loc.contains('reports')) index = 12;
          else if (loc.contains('lesson-plan')) index = 13;
          return TeacherMainLayout(currentIndex: index, child: child);
        },
        routes: [
          GoRoute(
            path: teacherDashboard,
            builder: (context, state) => const TeacherDashboardScreen(),
          ),
          GoRoute(
            path: teacherSections,
            builder: (context, state) => const SectionsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return SectionDetailsScreen(sectionId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: teacherStudents,
            builder: (context, state) => const StudentsScreen(),
          ),
          GoRoute(
            path: teacherLessons,
            builder: (context, state) => const LessonsScreen(),
          ),
          GoRoute(
            path: teacherMaterials,
            builder: (context, state) => const MaterialsScreen(),
          ),
          GoRoute(
            path: teacherAssessments,
            builder: (context, state) => const AssessmentsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const AssessmentBuilderScreen(),
              ),
            ],
          ),
          GoRoute(
            path: teacherActivities,
            builder: (context, state) => const ActivitiesScreen(),
          ),
          GoRoute(
            path: teacherGrades,
            builder: (context, state) => const GradesScreen(),
          ),
          GoRoute(
            path: teacherAttendance,
            builder: (context, state) => const AttendanceScreen(),
            routes: [
              GoRoute(
                path: 'rfid',
                builder: (context, state) => const RfidAttendanceScreen(),
              ),
            ],
          ),
          GoRoute(
            path: teacherSchedule,
            builder: (context, state) => const ScheduleScreen(),
          ),
          GoRoute(
            path: teacherAnalytics,
            builder: (context, state) => const LearningAnalyticsScreen(),
          ),
          GoRoute(
            path: teacherItemAnalysis,
            builder: (context, state) => const ItemAnalysisScreen(),
          ),
          GoRoute(
            path: teacherReports,
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: teacherLessonPlan,
            builder: (context, state) => const LessonPlanAssistanceScreen(),
          ),
        ],
      ),

      // Student Shell Route
      ShellRoute(
        builder: (context, state, child) {
          int index = 0;
          final loc = state.matchedLocation;
          if (loc == '/student') index = 0;
          else if (loc.contains('classes')) index = 1;
          else if (loc.contains('lessons')) index = 2;
          else if (loc.contains('materials')) index = 3;
          else if (loc.contains('assessments')) index = 4;
          else if (loc.contains('activities')) index = 5;
          else if (loc.contains('grades')) index = 6;
          else if (loc.contains('progress')) index = 7;
          else if (loc.contains('achievements')) index = 8;
          else if (loc.contains('schedule')) index = 9;
          return StudentMainLayout(currentIndex: index, child: child);
        },
        routes: [
          GoRoute(
            path: studentDashboard,
            builder: (context, state) => const StudentDashboardScreen(),
          ),
          GoRoute(
            path: studentClasses,
            builder: (context, state) => const StudentClassesScreen(),
          ),
          GoRoute(
            path: studentLessons,
            builder: (context, state) => const StudentLessonsScreen(),
          ),
          GoRoute(
            path: studentMaterials,
            builder: (context, state) => const StudentMaterialsScreen(),
          ),
          GoRoute(
            path: studentAssessments,
            builder: (context, state) => const StudentAssessmentsScreen(),
          ),
          GoRoute(
            path: studentActivities,
            builder: (context, state) => const StudentActivitiesScreen(),
          ),
          GoRoute(
            path: studentGrades,
            builder: (context, state) => const StudentGradesScreen(),
          ),
          GoRoute(
            path: studentProgress,
            builder: (context, state) => const StudentProgressScreen(),
          ),
          GoRoute(
            path: studentAchievements,
            builder: (context, state) => const StudentAchievementsScreen(),
          ),
          GoRoute(
            path: studentSchedule,
            builder: (context, state) => const StudentScheduleScreen(),
          ),
        ],
      ),

      // Admin Shell Route
      ShellRoute(
        builder: (context, state, child) {
          int index = 0;
          final loc = state.matchedLocation;
          if (loc == '/admin') index = 0;
          else if (loc.contains('approvals')) index = 1;
          else if (loc.contains('users')) index = 2;
          else if (loc.contains('activity')) index = 3;
          else if (loc.contains('rfid')) index = 4;
          else if (loc.contains('scanning')) index = 5;
          else if (loc.contains('settings')) index = 6;
          return AdminMainLayout(currentIndex: index, child: child);
        },
        routes: [
          GoRoute(
            path: adminDashboard,
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: adminApprovals,
            builder: (context, state) => const TeacherApprovalsScreen(),
          ),
          GoRoute(
            path: adminUsers,
            builder: (context, state) => const UserManagementScreen(),
          ),
          GoRoute(
            path: adminActivity,
            builder: (context, state) => const AdminActivityScreen(),
          ),
          GoRoute(
            path: adminRfid,
            builder: (context, state) => const RfidMonitoringScreen(),
          ),
          GoRoute(
            path: adminScanning,
            builder: (context, state) => const ScanningMonitoringScreen(),
          ),
          GoRoute(
            path: adminSettings,
            builder: (context, state) => const AdminSettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
