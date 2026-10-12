class NotificationPreferenceModule {
  final String module;
  final String name;
  final String desc;
  final String icon;
  final String category;
  final String categoryDesc;
  final String audience; // 'Parents & Students', 'Teachers & Staff', 'Institute / Admin'
  bool isEnabled;
  bool whatsappEnabled;
  bool pushEnabled;
  bool emailEnabled;
  final String? whatsappTemplate;
  final String? pushTemplate;
  final String? emailTemplate;

  NotificationPreferenceModule({
    required this.module,
    required this.name,
    required this.desc,
    required this.icon,
    this.category = 'FEES',
    this.categoryDesc = '',
    this.audience = 'Parents & Students',
    this.isEnabled = true,
    this.whatsappEnabled = true,
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.whatsappTemplate,
    this.pushTemplate,
    this.emailTemplate,
  });

  bool get isAnyChannelActive =>
      isEnabled && (whatsappEnabled || pushEnabled || emailEnabled);

  factory NotificationPreferenceModule.fromJson(Map<String, dynamic> json) {
    final mod = json['module']?.toString() ?? json['code']?.toString() ?? '';

    // Look up default rule metadata if present
    NotificationPreferenceModule? fallback;
    for (final def in defaultRules) {
      if (def.module == mod) {
        fallback = def;
        break;
      }
    }

    final bool isEnabled;
    if (json['is_enabled'] != null) {
      isEnabled = json['is_enabled'] == true ||
          json['is_enabled'] == 1 ||
          json['is_enabled'].toString() == 'true';
    } else if (json['is_active'] != null) {
      isEnabled = json['is_active'] == true ||
          json['is_active'] == 1 ||
          json['is_active'].toString() == 'true';
    } else if (json['enabled'] != null) {
      isEnabled = json['enabled'] == true ||
          json['enabled'] == 1 ||
          json['enabled'].toString() == 'true';
    } else {
      isEnabled = (json['whatsapp_enabled'] == true ||
          json['whatsapp'] == true ||
          json['push_enabled'] == true ||
          json['push'] == true ||
          json['email_enabled'] == true ||
          json['email'] == true);
    }

    final bool whatsappEnabled = json['whatsapp_enabled'] != null
        ? (json['whatsapp_enabled'] == true ||
            json['whatsapp_enabled'] == 1 ||
            json['whatsapp_enabled'].toString() == 'true')
        : (json['whatsapp'] != null
            ? (json['whatsapp'] == true ||
                json['whatsapp'] == 1 ||
                json['whatsapp'].toString() == 'true')
            : (fallback?.whatsappEnabled ?? true));

    final bool pushEnabled = json['push_enabled'] != null
        ? (json['push_enabled'] == true ||
            json['push_enabled'] == 1 ||
            json['push_enabled'].toString() == 'true')
        : (json['push'] != null
            ? (json['push'] == true ||
                json['push'] == 1 ||
                json['push'].toString() == 'true')
            : (fallback?.pushEnabled ?? true));

    final bool emailEnabled = json['email_enabled'] != null
        ? (json['email_enabled'] == true ||
            json['email_enabled'] == 1 ||
            json['email_enabled'].toString() == 'true')
        : (json['email'] != null
            ? (json['email'] == true ||
                json['email'] == 1 ||
                json['email'].toString() == 'true')
            : (fallback?.emailEnabled ?? true));

    return NotificationPreferenceModule(
      module: mod,
      name: json['name']?.toString() ??
          json['title']?.toString() ??
          fallback?.name ??
          mod,
      desc: json['desc']?.toString() ??
          json['description']?.toString() ??
          fallback?.desc ??
          '',
      icon: json['icon']?.toString() ?? fallback?.icon ?? '🔔',
      category: json['category']?.toString() ??
          json['module_group']?.toString() ??
          fallback?.category ??
          'FEES',
      categoryDesc: json['category_desc']?.toString() ??
          fallback?.categoryDesc ??
          '',
      audience: json['audience']?.toString() ??
          json['target_audience']?.toString() ??
          fallback?.audience ??
          'Parents & Students',
      isEnabled: isEnabled,
      whatsappEnabled: whatsappEnabled,
      pushEnabled: pushEnabled,
      emailEnabled: emailEnabled,
      whatsappTemplate: json['whatsapp_template']?.toString() ??
          fallback?.whatsappTemplate,
      pushTemplate:
          json['push_template']?.toString() ?? fallback?.pushTemplate,
      emailTemplate:
          json['email_template']?.toString() ?? fallback?.emailTemplate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'module': module,
      'is_enabled': isEnabled,
      'is_active': isEnabled,
      'whatsapp_enabled': isEnabled && whatsappEnabled,
      'push_enabled': isEnabled && pushEnabled,
      'email_enabled': isEnabled && emailEnabled,
      'whatsapp': isEnabled && whatsappEnabled,
      'push': isEnabled && pushEnabled,
      'email': isEnabled && emailEnabled,
    };
  }

  NotificationPreferenceModule copyWith({
    String? module,
    String? name,
    String? desc,
    String? icon,
    String? category,
    String? categoryDesc,
    String? audience,
    bool? isEnabled,
    bool? whatsappEnabled,
    bool? pushEnabled,
    bool? emailEnabled,
    String? whatsappTemplate,
    String? pushTemplate,
    String? emailTemplate,
  }) {
    return NotificationPreferenceModule(
      module: module ?? this.module,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      categoryDesc: categoryDesc ?? this.categoryDesc,
      audience: audience ?? this.audience,
      isEnabled: isEnabled ?? this.isEnabled,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      whatsappTemplate: whatsappTemplate ?? this.whatsappTemplate,
      pushTemplate: pushTemplate ?? this.pushTemplate,
      emailTemplate: emailTemplate ?? this.emailTemplate,
    );
  }

  static final List<NotificationPreferenceModule> defaultRules = [
    // -------------------------------------------------------------------------
    // 1. FEES (3 Rules) - All Parents & Students
    // -------------------------------------------------------------------------
    NotificationPreferenceModule(
      module: 'fee_reminder',
      name: 'Fee Reminders & Dues',
      desc:
          'Upcoming installment reminders (2 days & 1 day before due date), due today alerts, and overdue notices.',
      icon: '💰',
      category: 'FEES',
      categoryDesc:
          'Payment collection notifications, installment reminders, and digital receipts.',
      audience: 'Parents & Students',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
      whatsappTemplate:
          'Dear Parent, This is a gentle reminder that fee installment of ₹{amount} for {student_name} is due on {due_date}. Please clear dues to ensure uninterrupted classes. Thank you, {institute_name}.',
      pushTemplate:
          'Fee Due Reminder: Installment of ₹{amount} for {student_name} is due on {due_date}.',
      emailTemplate:
          'Subject: Fee Payment Reminder - {student_name}\n\nDear Parent,\n\nThis is a reminder regarding the upcoming fee installment of ₹{amount} due on {due_date} for student {student_name}. Kindly complete the payment.\n\nWarm regards,\n{institute_name}',
    ),
    NotificationPreferenceModule(
      module: 'payment_receipt',
      name: 'Fee Payment Receipts',
      desc:
          'Instant digital payment confirmation and receipt download link when payment is recorded.',
      icon: '📄',
      category: 'FEES',
      categoryDesc:
          'Payment collection notifications, installment reminders, and digital receipts.',
      audience: 'Parents & Students',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
      whatsappTemplate:
          'Dear Parent, Fee payment of ₹{amount} for {student_name} has been received successfully. Receipt #{receipt_no}. Download your official receipt: {receipt_url}',
      pushTemplate:
          'Fee Paid: ₹{amount} received for {student_name}. Receipt #{receipt_no}.',
      emailTemplate:
          'Subject: Payment Receipt #{receipt_no} - {institute_name}\n\nDear Parent,\n\nWe have received your payment of ₹{amount} for {student_name}. You can download the official digital receipt using the attached link.\n\nThank you,\n{institute_name}',
    ),
    NotificationPreferenceModule(
      module: 'fee_promise',
      name: 'Fee Promise & Commitment Reminders',
      desc:
          'Alerts on promise-to-pay dates committed by parents during fee follow-ups.',
      icon: '🤝',
      category: 'FEES',
      categoryDesc:
          'Payment collection notifications, installment reminders, and digital receipts.',
      audience: 'Parents & Students',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
      whatsappTemplate:
          'Dear Parent, As per your previous commitment, the scheduled fee payment of ₹{amount} for {student_name} was planned for today. Kindly complete the payment. Thank you, {institute_name}.',
      pushTemplate:
          'Fee Commitment Reminder: Payment planned for today for {student_name}.',
      emailTemplate:
          'Subject: Reminder: Committed Fee Payment for {student_name}\n\nDear Parent,\n\nThis is a follow-up reminder regarding the fee payment committed for today.\n\nRegards,\n{institute_name}',
    ),

    // -------------------------------------------------------------------------
    // 2. ATTENDANCE (4 Rules) - 3 Parents & Students, 1 Teachers & Staff
    // -------------------------------------------------------------------------
    NotificationPreferenceModule(
      module: 'attendance_absent',
      name: 'Daily Absent Alerts',
      desc:
          'Instant roll-call alert sent to parents the moment a student is marked absent in class.',
      icon: '⚠️',
      category: 'ATTENDANCE',
      categoryDesc:
          'Real-time roll-call alerts informing parents regarding student presence & teacher reminders.',
      audience: 'Parents & Students',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
      whatsappTemplate:
          'Dear Parent, {student_name} was marked ABSENT today ({date}) for {batch_name}. If this was unexpected, please contact {institute_name}.',
      pushTemplate:
          'Absent Notice: {student_name} was marked absent today ({date}).',
      emailTemplate:
          'Subject: Student Absence Alert: {student_name}\n\nDear Parent,\n\nPlease note that {student_name} was marked absent for classes today ({date}). Please reach out if you have any questions.\n\nRegards,\n{institute_name}',
    ),
    NotificationPreferenceModule(
      module: 'attendance_late',
      name: 'Late Arrival Notifications',
      desc:
          'Informs parents when a student checks in after class has commenced.',
      icon: '⏰',
      category: 'ATTENDANCE',
      categoryDesc:
          'Real-time roll-call alerts informing parents regarding student presence & teacher reminders.',
      audience: 'Parents & Students',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
      whatsappTemplate:
          'Dear Parent, {student_name} arrived late to {batch_name} today at {time}.',
      pushTemplate:
          'Late Arrival: {student_name} arrived late at {time}.',
      emailTemplate:
          'Subject: Late Arrival Notice - {student_name}\n\nDear Parent,\n\n{student_name} was marked late for class today ({date}) at {time}.\n\nRegards,\n{institute_name}',
    ),
    NotificationPreferenceModule(
      module: 'attendance_summary',
      name: 'Monthly Attendance Summary',
      desc:
          'Monthly percentage report card of attendance sent at the beginning of each month.',
      icon: '✅',
      category: 'ATTENDANCE',
      categoryDesc:
          'Real-time roll-call alerts informing parents regarding student presence & teacher reminders.',
      audience: 'Parents & Students',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
      whatsappTemplate:
          'Dear Parent, Monthly attendance summary for {student_name}: {present_days}/{total_days} days present ({percentage}%). Thank you, {institute_name}.',
      pushTemplate:
          'Monthly Attendance: {student_name} attended {percentage}% of classes.',
      emailTemplate:
          'Subject: Monthly Attendance Report - {student_name}\n\nDear Parent,\n\nHere is the attendance report for {student_name} for the month: {present_days}/{total_days} days present ({percentage}%).\n\nRegards,\n{institute_name}',
    ),
    NotificationPreferenceModule(
      module: 'attendance_teacher_reminder',
      name: 'Pending Roll-Call Reminder',
      desc:
          'Reminder sent to teachers if attendance for a scheduled batch is not marked within 30 minutes.',
      icon: '⏱️',
      category: 'ATTENDANCE',
      categoryDesc:
          'Real-time roll-call alerts informing parents regarding student presence & teacher reminders.',
      audience: 'Teachers & Staff',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
      whatsappTemplate:
          'Reminder: Attendance has not been marked for batch {batch_name} yet. Please submit the roll-call.',
      pushTemplate:
          'Attendance Pending: Please mark roll-call for {batch_name}.',
      emailTemplate:
          'Subject: Pending Attendance Notice: {batch_name}\n\nPlease mark and submit attendance for {batch_name}.\n\nRegards,\n{institute_name}',
    ),

    // -------------------------------------------------------------------------
    // 3. EXAMS & ACADEMICS (4 Rules) - 3 Parents & Students, 1 Teachers & Staff
    // -------------------------------------------------------------------------
    NotificationPreferenceModule(
      module: 'exam_schedule',
      name: 'Exam Schedule & Timetable',
      desc:
          'Notice when new tests or exam schedules are finalized for student batches.',
      icon: '📅',
      category: 'EXAMS & ACADEMICS',
      categoryDesc:
          'Exam schedules, mark sheets, report cards, and daily homework notifications.',
      audience: 'Parents & Students',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
      whatsappTemplate:
          'Dear Student/Parent, The exam schedule for \'{exam_name}\' has been announced. Starting from {start_date}. Check syllabus and date sheet in app.',
      pushTemplate:
          'Exam Announced: \'{exam_name}\' starts on {start_date}. View schedule!',
      emailTemplate:
          'Subject: Exam Timetable: {exam_name}\n\nDear Parent/Student,\n\nThe timetable and syllabus for the upcoming exam \'{exam_name}\' have been published.\n\nRegards,\n{institute_name}',
    ),
    NotificationPreferenceModule(
      module: 'exam_results',
      name: 'Exam Results & Score Cards',
      desc:
          'Instant marksheet notification with score, percentage, and teacher feedback.',
      icon: '📊',
      category: 'EXAMS & ACADEMICS',
      categoryDesc:
          'Exam schedules, mark sheets, report cards, and daily homework notifications.',
      audience: 'Parents & Students',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
      whatsappTemplate:
          'Exam results for \'{exam_name}\' are out. {student_name} scored {marks}/{total_marks} ({percentage}%). View complete scorecard in app.',
      pushTemplate:
          'Results Declared: {student_name} scored {percentage}% in \'{exam_name}\'.',
      emailTemplate:
          'Subject: Result Card: {student_name} - {exam_name}\n\nDear Parent,\n\nThe results for \'{exam_name}\' are now available. Score: {marks}/{total_marks} ({percentage}%).\n\nRegards,\n{institute_name}',
    ),
    NotificationPreferenceModule(
      module: 'homework_new',
      name: 'Daily Homework & Classwork Updates',
      desc:
          'Daily assignments, lecture summaries, and homework deadlines published by teachers.',
      icon: '📚',
      category: 'EXAMS & ACADEMICS',
      categoryDesc:
          'Exam schedules, mark sheets, report cards, and daily homework notifications.',
      audience: 'Parents & Students',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
      whatsappTemplate:
          'New Homework Alert: Assigned in {subject} for {batch_name}. Due date: {due_date}. Open app to view task.',
      pushTemplate:
          'New Homework: Assigned in {subject} for {batch_name}. Due {due_date}.',
      emailTemplate:
          'Subject: New Homework Assignment: {subject}\n\nDear Student,\n\nA new assignment has been posted for {batch_name} with due date {due_date}.\n\nRegards,\n{institute_name}',
    ),
    NotificationPreferenceModule(
      module: 'exam_marks_pending',
      name: 'Marks Entry Pending Alert',
      desc:
          'Notification to teachers to submit scores for completed batch tests.',
      icon: '📝',
      category: 'EXAMS & ACADEMICS',
      categoryDesc:
          'Exam schedules, mark sheets, report cards, and daily homework notifications.',
      audience: 'Teachers & Staff',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
      whatsappTemplate:
          'Dear Teacher, Marks entry for \'{exam_name}\' for batch {batch_name} is pending. Deadline: {deadline}.',
      pushTemplate:
          'Marks Pending: Enter scores for {exam_name} ({batch_name}).',
      emailTemplate:
          'Subject: Pending Marks Entry: {exam_name}\n\nPlease submit test marks for {batch_name} before {deadline}.\n\nRegards,\n{institute_name}',
    ),

    // -------------------------------------------------------------------------
    // 4. TIMETABLE & CLASSES (2 Rules) - 1 Parents & Students, 1 Teachers & Staff
    // -------------------------------------------------------------------------
    NotificationPreferenceModule(
      module: 'class_schedule_change',
      name: 'Class Rescheduling & Cancellations',
      desc:
          'Urgent alert if class timing is shifted or if a teacher is on leave.',
      icon: '🔄',
      category: 'TIMETABLE & CLASSES',
      categoryDesc:
          'Lecture schedules, classroom allocations, and rescheduling notifications.',
      audience: 'Parents & Students',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
      whatsappTemplate:
          'Urgent Schedule Update: Class timing for {subject} ({batch_name}) has been rescheduled to {new_time}.',
      pushTemplate:
          'Schedule Update: {subject} timing rescheduled to {new_time}.',
      emailTemplate:
          'Subject: Class Schedule Update Notice - {subject}\n\nPlease note the updated timing for {batch_name}: {new_time}.\n\nRegards,\n{institute_name}',
    ),
    NotificationPreferenceModule(
      module: 'teacher_timetable',
      name: 'Daily Teaching Schedule Digest',
      desc:
          'Morning agenda detailing today\'s lectures, batches, and classroom allocations.',
      icon: '🗓️',
      category: 'TIMETABLE & CLASSES',
      categoryDesc:
          'Lecture schedules, classroom allocations, and rescheduling notifications.',
      audience: 'Teachers & Staff',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
      whatsappTemplate:
          'Good morning! You have {total_classes} lectures scheduled today ({date}). First class starts at {first_class_time}.',
      pushTemplate:
          'Teaching Schedule: First class starts at {first_class_time}.',
      emailTemplate:
          'Subject: Daily Teaching Schedule - {date}\n\nGood morning,\n\nHere is your teaching schedule for today: {total_classes} classes planned.\n\nRegards,\n{institute_name}',
    ),

    // -------------------------------------------------------------------------
    // 5. CAMPUS CIRCULARS & UPDATES (3 Rules) - 2 Parents & Students, 1 Teachers & Staff
    // -------------------------------------------------------------------------
    NotificationPreferenceModule(
      module: 'broadcast_announcement',
      name: 'General Notices & Circulars',
      desc:
          'Campus-wide emergency alerts, holiday declarations, and festive greetings.',
      icon: '📢',
      category: 'CAMPUS CIRCULARS & UPDATES',
      categoryDesc:
          'General announcements, holiday notices, birthday wishes, and staff memos.',
      audience: 'Parents & Students',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
      whatsappTemplate:
          'Notice from {institute_name}: {title}\n\n{message}',
      pushTemplate:
          '{title}: {message}',
      emailTemplate:
          'Subject: Circular: {title}\n\nDear Parent/Student,\n\n{message}\n\nRegards,\n{institute_name}',
    ),
    NotificationPreferenceModule(
      module: 'birthday_wishes',
      name: 'Student Birthday Greetings',
      desc:
          'Personalized warm wishes sent on student birthdays on behalf of the institute.',
      icon: '🎂',
      category: 'CAMPUS CIRCULARS & UPDATES',
      categoryDesc:
          'General announcements, holiday notices, birthday wishes, and staff memos.',
      audience: 'Parents & Students',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
      whatsappTemplate:
          'Happy Birthday {student_name}! 🎂 Wishing you a wonderful year ahead filled with learning and success! Warm wishes from {institute_name}.',
      pushTemplate:
          'Happy Birthday {student_name}! 🎉 Best wishes from {institute_name}.',
      emailTemplate:
          'Subject: Happy Birthday {student_name}!\n\nDear {student_name},\n\nWishing you a joyful birthday filled with success and happiness!\n\nWarm regards,\n{institute_name}',
    ),
    NotificationPreferenceModule(
      module: 'staff_announcements',
      name: 'Internal Staff Notices',
      desc:
          'Faculty meetings, academic calendar changes, and administrative memos.',
      icon: '📣',
      category: 'CAMPUS CIRCULARS & UPDATES',
      categoryDesc:
          'General announcements, holiday notices, birthday wishes, and staff memos.',
      audience: 'Teachers & Staff',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
      whatsappTemplate:
          'Internal Staff Notice: {title}\n\n{message}',
      pushTemplate:
          'Staff Notice: {title}',
      emailTemplate:
          'Subject: Staff Notice: {title}\n\nDear Faculty & Staff,\n\n{message}\n\nRegards,\n{institute_name}',
    ),

    // -------------------------------------------------------------------------
    // 6. PAYROLL & SALARY (1 Rule) - 1 Teachers & Staff
    // -------------------------------------------------------------------------
    NotificationPreferenceModule(
      module: 'salary_slip',
      name: 'Salary Slip & Payout Confirmation',
      desc:
          'Monthly payslip generation and salary credit confirmation for faculty and staff.',
      icon: '💳',
      category: 'PAYROLL & SALARY',
      categoryDesc:
          'Faculty salary processing, payslip downloads, and disbursement alerts.',
      audience: 'Teachers & Staff',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
      whatsappTemplate:
          'Dear {staff_name}, Your salary for the month of {month} has been credited (Net: ₹{net_salary}). Payslip is available in app.',
      pushTemplate:
          'Salary Credited: Payslip for {month} is now available.',
      emailTemplate:
          'Subject: Salary Credit & Payslip for {month}\n\nDear {staff_name},\n\nYour salary for {month} has been processed. Net amount: ₹{net_salary}.\n\nRegards,\n{institute_name}',
    ),

    // -------------------------------------------------------------------------
    // 7. INSTITUTE & ADMIN ALERTS (3 Rules) - 3 Institute / Admin
    // -------------------------------------------------------------------------
    NotificationPreferenceModule(
      module: 'admin_daily_digest',
      name: 'Daily Institute Summary Digest',
      desc:
          'End-of-day summary of fee collections, total present students, and inquiries logged.',
      icon: '📊',
      category: 'INSTITUTE & ADMIN ALERTS',
      categoryDesc:
          'Daily performance digests, admissions inquiries, and platform notifications.',
      audience: 'Institute / Admin',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
    ),
    NotificationPreferenceModule(
      module: 'admin_lead_alert',
      name: 'New Admission Inquiry Alert',
      desc:
          'Instant alert to admin when a prospective student submits a website inquiry form.',
      icon: '🎯',
      category: 'INSTITUTE & ADMIN ALERTS',
      categoryDesc:
          'Daily performance digests, admissions inquiries, and platform notifications.',
      audience: 'Institute / Admin',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
    ),
    NotificationPreferenceModule(
      module: 'admin_subscription',
      name: 'Subscription & Plan Expiry Warnings',
      desc:
          'Advance notices before institute platform license and SMS/WhatsApp plan renewal.',
      icon: '⚡',
      category: 'INSTITUTE & ADMIN ALERTS',
      categoryDesc:
          'Daily performance digests, admissions inquiries, and platform notifications.',
      audience: 'Institute / Admin',
      isEnabled: true,
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
    ),
  ];
}
