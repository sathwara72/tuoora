import 'package:get/get.dart';

import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/data/repositories/auth_repository.dart';
import 'package:tuoora/data/repositories/teacher_attendance_repository.dart';
import 'package:tuoora/data/repositories/teacher_batch_repository.dart';
import 'package:tuoora/data/repositories/teacher_profile_repository.dart';
import 'package:tuoora/data/repositories/teacher_exam_repository.dart';
import 'package:tuoora/data/repositories/teacher_fee_repository.dart';
import 'package:tuoora/data/repositories/teacher_homework_repository.dart';
import 'package:tuoora/data/repositories/teacher_resource_repository.dart';
import 'package:tuoora/data/repositories/teacher_salary_repository.dart';
import 'package:tuoora/data/repositories/teacher_timetable_repository.dart';
import 'package:tuoora/data/repositories_impl/teacher_attendance_repository_impl.dart';
import 'package:tuoora/data/repositories_impl/teacher_batch_repository_impl.dart';
import 'package:tuoora/data/repositories_impl/teacher_exam_repository_impl.dart';
import 'package:tuoora/data/repositories_impl/teacher_fee_repository_impl.dart';
import 'package:tuoora/data/repositories_impl/teacher_homework_repository_impl.dart';
import 'package:tuoora/data/repositories_impl/teacher_profile_repository_impl.dart';
import 'package:tuoora/data/repositories_impl/teacher_resource_repository_impl.dart';
import 'package:tuoora/data/repositories_impl/teacher_salary_repository_impl.dart';
import 'package:tuoora/data/repositories_impl/teacher_timetable_repository_impl.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_add_exam_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_add_homework_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_add_timetable_slot_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_assign_students_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_batch_details_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_batch_resources_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_batch_students_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_batch_exams_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_batch_homework_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_batch_timetable_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_batches_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_change_password_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_exam_marks_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_fees_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_homework_grading_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_mark_attendance_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_profile_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_salary_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_self_attendance_controller.dart';

class TeacherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient());
    Get.lazyPut(() => AuthRepository(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut<TeacherBatchRepositoryImpl>(
      () => TeacherBatchRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<TeacherProfileRepositoryImpl>(
      () => TeacherProfileRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<TeacherAttendanceRepositoryImpl>(
      () => TeacherAttendanceRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<TeacherHomeworkRepositoryImpl>(
      () => TeacherHomeworkRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<TeacherExamRepositoryImpl>(
      () => TeacherExamRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<TeacherTimetableRepositoryImpl>(
      () => TeacherTimetableRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<TeacherFeeRepositoryImpl>(
      () => TeacherFeeRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<TeacherSalaryRepositoryImpl>(
      () => TeacherSalaryRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<TeacherResourceRepositoryImpl>(
      () => TeacherResourceRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(() => TeacherChangePasswordController());
    Get.lazyPut(
      () => TeacherBatchesController(Get.find<TeacherBatchRepositoryImpl>()),
    );
    Get.lazyPut(
      () => TeacherBatchDetailsController(Get.find<TeacherBatchRepositoryImpl>()),
    );
    Get.lazyPut(
      () => TeacherBatchStudentsController(Get.find<TeacherBatchRepositoryImpl>()),
    );
    Get.lazyPut(
      () => TeacherAssignStudentsController(Get.find<TeacherBatchRepositoryImpl>()),
    );
    Get.lazyPut(
      () => TeacherBatchResourcesController(
        Get.find<TeacherResourceRepositoryImpl>(),
      ),
    );
    Get.lazyPut(
      () => TeacherProfileController(Get.find<TeacherProfileRepositoryImpl>()),
    );
    Get.lazyPut(
      () => TeacherMarkAttendanceController(
        Get.find<TeacherAttendanceRepositoryImpl>(),
      ),
    );
    Get.lazyPut(
      () => TeacherSelfAttendanceController(
        Get.find<TeacherAttendanceRepositoryImpl>(),
      ),
    );
    Get.lazyPut(
      () => TeacherBatchHomeworkController(
        Get.find<TeacherHomeworkRepositoryImpl>(),
      ),
    );
    Get.lazyPut(
      () => TeacherAddHomeworkController(
        Get.find<TeacherHomeworkRepositoryImpl>(),
      ),
    );
    Get.lazyPut(
      () => TeacherHomeworkGradingController(
        Get.find<TeacherHomeworkRepositoryImpl>(),
      ),
    );
    Get.lazyPut(
      () => TeacherBatchExamsController(Get.find<TeacherExamRepositoryImpl>()),
    );
    Get.lazyPut(
      () => TeacherAddExamController(Get.find<TeacherExamRepositoryImpl>()),
    );
    Get.lazyPut(
      () => TeacherExamMarksController(Get.find<TeacherExamRepositoryImpl>()),
    );
    Get.lazyPut(
      () => TeacherBatchTimetableController(
        Get.find<TeacherTimetableRepositoryImpl>(),
      ),
    );
    Get.lazyPut(
      () => TeacherAddTimetableSlotController(
        Get.find<TeacherTimetableRepositoryImpl>(),
      ),
    );
    Get.lazyPut(
      () => TeacherFeesController(Get.find<TeacherFeeRepositoryImpl>()),
    );
    Get.lazyPut(
      () => TeacherSalaryController(Get.find<TeacherSalaryRepositoryImpl>()),
    );
  }
}
