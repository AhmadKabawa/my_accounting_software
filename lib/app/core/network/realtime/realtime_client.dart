// core/network/realtime/realtime_client.dart

typedef RealtimeEventHandler = void Function(Map<String, dynamic> data);

abstract class RealtimeClient {

  // اتصال وقطع
  Future<void> connect();
  Future<void> disconnect();

  // اشتراك في حدث — مثل socket.on('event', handler)
  void on(String event, RealtimeEventHandler handler);

  // إلغاء الاشتراك — مثل socket.off('event')
  void off(String event);

  // إرسال حدث — مثل socket.emit('event', data)
  Future<void> emit(String event, Map<String, dynamic> data);

  // حالة الاتصال
  Stream<RealtimeStatus> get statusStream;

  // اشتراك في تغييرات جدول — sugar method للـ Supabase
  void onTableChange({
    required String                          table,
    required String                          filter,
    required RealtimeEventHandler            onInsert,
    RealtimeEventHandler?                    onUpdate,
    RealtimeEventHandler?                    onDelete,
  });

  // إلغاء اشتراك جدول
  void offTable({required String table, required String filter});
}

enum RealtimeStatus { connecting, connected, disconnected, error }