class Task {
  final String id;
  final String title;
  final String description;
  final String priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final bool completed;

  Task({this.id = '', required this.title, this.description = '', this.priority = 'medium', this.dueDate, DateTime? createdAt, this.completed = false}) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({String? title, String? description, String? priority, DateTime? dueDate, bool? completed}) {
    return Task(
      id: id, title: title ?? this.title, description: description ?? this.description, 
      priority: priority ?? this.priority, dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt, completed: completed ?? this.completed
    );
  }
}

class Assignment {
  final String id;
  final String title;
  final String course;
  final DateTime dueDate;
  final double? grade;
  final double? percentage;
  
  Assignment({this.id = '', required this.title, required this.course, required this.dueDate, this.grade, this.percentage});
  
  Duration get timeUntilDue => dueDate.difference(DateTime.now());
  bool get isOverdue => timeUntilDue.isNegative;
}

class StudySession {
  final String id;
  final String subject;
  final Duration duration;
  final DateTime date;
  final int durationMinutes;
  StudySession({this.id='', this.subject='', this.duration=Duration.zero, required this.date, this.durationMinutes=0});
}

class StartupMetrics {
  final double mrr;
  final int activeUsers;
  final double growth;
  final double burnRate;
  final double runwayMonths;
  final int totalUsers;
  StartupMetrics({this.mrr=0, this.activeUsers=0, this.growth=0, this.burnRate=0, this.runwayMonths=0, this.totalUsers=0});
}

class Investor {
  final String id;
  final String name;
  final String firm;
  final double amount;
  final String stage;
  final String stageEmoji;
  Investor({this.id='', this.name='', this.firm='', this.amount=0, this.stage='', this.stageEmoji=''});
}

class ReadingItem {
  final String id;
  final String title;
  final String author;
  final double progress;
  final String status;
  final String typeEmoji;
  final String statusLabel;
  final String? url;
  final String? itemType;
  ReadingItem({this.id='', this.title='', this.author='', this.progress=0, this.status='', this.typeEmoji='', this.statusLabel='', this.url, this.itemType});
}

class Mood {
  final String id;
  final int moodScore;
  final String notes;
  final DateTime date;
  final String moodEmoji;
  final int energyLevel;
  final String energyEmoji;
  Mood({this.id='', this.moodScore=5, this.notes='', required this.date, this.moodEmoji='', this.energyLevel=5, this.energyEmoji=''});
}

class MemorySlot {
  final String id;
  final String content;
  final DateTime date;
  final String key;
  final String value;
  MemorySlot({this.id='', this.content='', required this.date, this.key='', this.value=''});
}

class Expense {
  String get categoryEmoji => '💰';
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String? description;
  Expense({this.id='', this.title='', this.amount=0, required this.date, this.category='', this.description});
}

class FinanceTransaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isIncome;
  FinanceTransaction({this.id='', this.title='', this.amount=0, this.category='', required this.date, this.isIncome=false});
}

class CalendarEvent {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? description;
  final String color;
  final bool isAllDay;
  final String eventType;
  final String location;

  CalendarEvent({
    this.id = '',
    this.title = '',
    required this.startTime,
    required this.endTime,
    this.description,
    this.color = '#FFFFFF',
    this.isAllDay = false,
    this.eventType = 'general',
    this.location = '',
  });
}
