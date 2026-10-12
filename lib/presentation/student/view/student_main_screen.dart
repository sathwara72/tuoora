import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/widgets/student_bottom_nav.dart';
import 'package:tuoora/presentation/student/controllers/student_controller.dart';
import 'package:tuoora/presentation/student/view/attendance_screen.dart';
import 'package:tuoora/presentation/student/view/dashboard.dart';
import 'package:tuoora/presentation/student/view/student_tasks_screen.dart';
import 'package:tuoora/presentation/student/view/student_fees_screen.dart';
import 'package:tuoora/presentation/student/view/student_profile_screen.dart';

class StudentMainScreen extends GetView<StudentController> {
  const StudentMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          StudentDashboard(showBottomNav: false),
          StudentTasksScreen(showBottomNav: false),
          StudentFeesScreen(showBottomNav: false),
          AttendanceScreen(showBottomNav: false),
          StudentProfileScreen(showBottomNav: false),
        ],
      ),
      bottomNavigationBar: Obx(
        () => StudentBottomNav(
          currentIndex: controller.currentIndex,
          onTap: controller.changePage,
        ),
      ),
    );
  }
}
