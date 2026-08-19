import '../models/modules_models.dart';

class ZenDatabase {
  Future<List<Task>> getTasks({bool includeCompleted = true}) async => [];
  Future<void> updateTask(Task task) async {}
  Future<void> insertEvent(CalendarEvent e) async {}
  Future<void> deleteEvent(String id) async {}
  Future<List<CalendarEvent>> getEvents({DateTime? from, DateTime? to}) async => [];
  Future<void> insertTask(Task task) async {}
  Future<void> deleteTask(String id) async {}
  Future<void> completeTask(String id) async {}
  Future<void> uncompleteTask(String id) async {}

  Future<List<Assignment>> getAssignments() async => [];
  Future<double> calculateGPA() async => 3.8;
  Future<void> insertAssignment(Assignment a) async {}
  
  // Stubs for others that might be called
  Future<List<StudySession>> getStudySessions({int? days}) async => [];
  Future<List<Expense>> getExpenses({int? days}) async => [];
  Future<Map<String, double>> getExpensesByCategory({int? days}) async => {};
  Future<double> getTotalExpenses({int? days}) async => 0.0;
  Future<void> deleteExpense(String id) async {}
  Future<void> insertExpense(Expense e) async {}
  Future<List<Mood>> getMoods() async => [];
  Future<List<ReadingItem>> getReadingItems() async => [];
  Future<List<MemorySlot>> getMemorySlots() async => [];
  Future<int> getStudyStreak() async => 0;
  Future<int> getTotalStudyMinutesToday() async => 0;
  Future<void> insertStudySession(StudySession s) async {}
  Future<void> saveFinanceTransaction(FinanceTransaction t) async {}
  Future<void> deleteFinanceTransaction(String id) async {}
  Future<void> insertReadingItem(ReadingItem item, {String? url, String? itemType}) async {}
  Future<void> updateReadingStatus(String id, String status) async {}
  Future<StartupMetrics?> getLatestStartupMetrics() async => null;
  Future<List<Investor>> getInvestors() async => [];
  Future<void> insertStartupMetrics(StartupMetrics m) async {}
  Future<void> insertInvestor(Investor i) async {}
  Future<void> setMemory(String key, String value) async {}
  Future<List<MemorySlot>> getAllMemories() async => [];
  Future<void> deleteMemory(String id) async {}
  Future<List<Mood>> getMoodHistory({int? days}) async => [];
  Future<Mood?> getTodaysMood() async => null;
  Future<double> getAverageEnergy({int? days}) async => 0.0;
  Future<void> insertMood(Mood m) async {}
}

class ZenBrain {
  Future<String> chat(String prompt, {bool persistHistory = false, String? contextData, String? sessionId}) async {
    return 'ZenBrain response to: $prompt';
  }
  
  Stream<String> chatStream(String prompt, {bool persistHistory = false}) async* {
    yield 'Streaming ';
    yield 'response';
  }
  
  Future<void> analyzeAndPrioritizeTasks() async {}
  Future<Map<String, dynamic>> defaultAliveCalculation() async => {};
}

enum VoiceState { listening, speaking, idle, thinking, processing }

class VoiceEngine {
  Stream<String> get responseStream => const Stream.empty();
  Stream<String> get transcriptStream => const Stream.empty();
  Stream<VoiceState> get stateStream => const Stream.empty();
  Future<void> startListening() async {}
  Future<void> stopListening() async {}
  Future<void> speak(String text) async {}
  Future<void> stopSpeaking() async {}
}

class FocusService {
  bool get isRunning => false;
  int get secondsRemaining => 0;
  Stream<void> get onUpdate => const Stream.empty();
  Stream<void> get onComplete => const Stream.empty();
  void startFocus(int minutes, String subject) {}
  void stopFocus() {}
}

class SpotifyService {
  Future<dynamic> getCurrentTrack() async => null;
}

class ZenNotifier {
  Future<void> scheduleTaskReminder(Task task) async {}
  Future<void> scheduleEventReminder(CalendarEvent e) async {}
  Future<void> cancelReminder(String id) async {}
}

