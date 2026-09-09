enum NotificationKind {
  homework('homework'),
  homeworkReminder('homework_reminder'),
  homeworkGraded('homework_graded'),
  attendance('attendance'),
  resource('resource'),
  dailyUpdate('daily_update'),
  batchAssignment('batch_assignment'),
  batchRemoval('batch_removal'),
  eventsHolidays('events_holidays'),
  feeReminders('fee_reminder'),
  unknown('');

  final String value;
  const NotificationKind(this.value);

  static NotificationKind fromString(String? raw) {
    if (raw == null) return NotificationKind.unknown;
    final normalized = raw.trim().toLowerCase();
    for (final k in NotificationKind.values) {
      if (k.value == normalized) return k;
    }
    // Handle backend type variations
    if (normalized == 'batch_updated' ||
        normalized == 'batch_update' ||
        normalized == 'batch') {
      return NotificationKind.batchAssignment;
    }
    if (normalized == 'fee_reminders' ||
        normalized == 'fees_reminder' ||
        normalized == 'fee_payment_reminder') {
      return NotificationKind.feeReminders;
    }
    if (normalized.startsWith('exam')) {
      return NotificationKind.eventsHolidays;
    }
    return NotificationKind.unknown;
  }
}

enum UpdateTargetType {
  all,
  batch;

  String toJson() => name;
}

enum UpdateCategory {
  Academic,
  Administrative,
  Emergency,
  Event,
  Holiday,
  Other;

  String toJson() => name;
}

enum ResourceType { image, video, document }

enum ChatMenuAction { delete }

enum MessageStatus { sending, sent, delivered, read, failed }

enum FeedbackRating { loveIt, useful, meh, broken }

enum FeeStatus { paid, pending }

enum AssignmentBadge { today, tomorrow, done }

enum AssignmentAttachmentKind { document, image, video, audio }

enum ReportPeriod { thisWeek, fourWeeks, twelveWeeks }

enum AttachmentSourceType { assignment, resource }
