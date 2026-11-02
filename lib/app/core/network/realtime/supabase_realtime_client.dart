// // core/network/realtime/supabase_realtime_client.dart
// import 'dart:async';
// import 'dart:convert';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'realtime_client.dart';

// class SupabaseRealtimeClient implements RealtimeClient {
//   SupabaseRealtimeClient({
//     required String supabaseUrl,
//     required String anonKey,
//   })  : _wsUrl   = '${supabaseUrl.replaceFirst('https', 'wss')}'
//                    '/realtime/v1/websocket?apikey=$anonKey&vsn=1.0.0',
//         _anonKey  = anonKey;

//   final String _wsUrl;
//   final String _anonKey;

//   WebSocketChannel?                              _channel;
//   Timer?                                         _heartbeat;
//   int                                            _ref = 0;

//   // event → list of handlers  (مثل socket.on)
//   final Map<String, List<RealtimeEventHandler>>  _handlers  = {};

//   // table:filter → topic  (لتتبع الاشتراكات)
//   final Map<String, String>                      _topics    = {};

//   final StreamController<RealtimeStatus>         _statusCtrl =
//       StreamController<RealtimeStatus>.broadcast();

//   // ─── connect ─────────────────────────────────────────────────────────────
//   @override
//   Future<void> connect() async {
//     _statusCtrl.add(RealtimeStatus.connecting);

//     _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));

//     _channel!.stream.listen(
//       _onMessage,
//       onDone:  _onDone,
//       onError: _onError,
//     );

//     // heartbeat كل 30 ثانية
//     _heartbeat = Timer.periodic(
//       const Duration(seconds: 30),
//       (_) => _sendRaw({
//         'topic':   'phoenix',
//         'event':   'heartbeat',
//         'payload': {},
//         'ref':     '${_ref++}',
//       }),
//     );

//     _statusCtrl.add(RealtimeStatus.connected);
//   }

//   // ─── disconnect ───────────────────────────────────────────────────────────
//   @override
//   Future<void> disconnect() async {
//     _heartbeat?.cancel();
//     await _channel?.sink.close();
//     _handlers.clear();
//     _topics.clear();
//     _statusCtrl.add(RealtimeStatus.disconnected);
//   }

//   // ─── on — مثل socket.on('messages:insert', handler) ──────────────────────
//   @override
//   void on(String event, RealtimeEventHandler handler) {
//     _handlers.putIfAbsent(event, () => []).add(handler);
//   }

//   // ─── off — مثل socket.off('messages:insert') ─────────────────────────────
//   @override
//   void off(String event) => _handlers.remove(event);

//   // ─── emit — مثل socket.emit('typing', {ticketId: '...'}) ─────────────────
//   @override
//   Future<void> emit(String event, Map<String, dynamic> data) async {
//     _sendRaw({
//       'topic':   'realtime',
//       'event':   event,
//       'payload': data,
//       'ref':     '${_ref++}',
//     });
//   }

//   // ─── onTableChange — sugar method ────────────────────────────────────────
//   @override
//   void onTableChange({
//     required String               table,
//     required String               filter,
//     required RealtimeEventHandler onInsert,
//     RealtimeEventHandler?         onUpdate,
//     RealtimeEventHandler?         onDelete,
//   }) {
//     final topic = 'realtime:public:$table:$filter';
//     _topics['$table:$filter'] = topic;

//     // تسجيل الـ handlers باسم واضح مثل socket.on
//     on('$table:insert', onInsert);
//     if (onUpdate != null) on('$table:update', onUpdate);
//     if (onDelete != null) on('$table:delete', onDelete);

//     // إرسال طلب الاشتراك بصيغة Phoenix
//     _sendRaw({
//       'topic': topic,
//       'event': 'phx_join',
//       'payload': {
//         'config': {
//           'postgres_changes': [
//             if (true) ...[
//               {'event': 'INSERT', 'schema': 'public', 'table': table, 'filter': filter},
//               if (onUpdate != null)
//                 {'event': 'UPDATE', 'schema': 'public', 'table': table, 'filter': filter},
//               if (onDelete != null)
//                 {'event': 'DELETE', 'schema': 'public', 'table': table, 'filter': filter},
//             ]
//           ],
//         }
//       },
//       'ref': '${_ref++}',
//     });
//   }

//   // ─── offTable ─────────────────────────────────────────────────────────────
//   @override
//   void offTable({required String table, required String filter}) {
//     final key   = '$table:$filter';
//     final topic = _topics.remove(key);
//     if (topic == null) return;

//     off('$table:insert');
//     off('$table:update');
//     off('$table:delete');

//     // إرسال طلب إلغاء الاشتراك
//     _sendRaw({
//       'topic':   topic,
//       'event':   'phx_leave',
//       'payload': {},
//       'ref':     '${_ref++}',
//     });
//   }

//   // ─── statusStream ─────────────────────────────────────────────────────────
//   @override
//   Stream<RealtimeStatus> get statusStream => _statusCtrl.stream;

//   // ─── معالجة الرسائل الواردة ───────────────────────────────────────────────
//   void _onMessage(dynamic raw) {
//     final json    = jsonDecode(raw as String) as Map<String, dynamic>;
//     final event   = json['event']   as String?;
//     final payload = json['payload'] as Map<String, dynamic>?;
//     final topic   = json['topic']   as String?;

//     if (event == null || payload == null) return;

//     // تحويل أحداث Phoenix إلى أحداث بصيغة table:action
//     if (event == 'postgres_changes') {
//       final data       = payload['data']   as Map<String, dynamic>?;
//       final changeType = data?['type']     as String?; // INSERT / UPDATE / DELETE
//       final record     = data?['record']   as Map<String, dynamic>?;
//       final table      = data?['table']    as String?;

//       if (changeType != null && record != null && table != null) {
//         final eventKey = '$table:${changeType.toLowerCase()}';
//         _dispatch(eventKey, record);
//       }
//       return;
//     }

//     // أحداث broadcast مباشرة
//     _dispatch(event, payload);
//   }

//   void _dispatch(String event, Map<String, dynamic> data) {
//     final handlers = _handlers[event];
//     if (handlers == null) return;
//     for (final h in handlers) {
//       h(data);
//     }
//   }

//   void _onDone() {
//     _statusCtrl.add(RealtimeStatus.disconnected);
//     _reconnect();
//   }

//   void _onError(Object error) {
//     _statusCtrl.add(RealtimeStatus.error);
//   }

//   // إعادة الاتصال تلقائياً عند الانقطاع
//   Future<void> _reconnect() async {
//     await Future.delayed(const Duration(seconds: 3));
//     await connect();
//     // إعادة الاشتراكات الموجودة
//     for (final entry in _topics.entries) {
//       final parts  = entry.key.split(':');
//       final table  = parts[0];
//       final filter = parts.sublist(1).join(':');
//       final insert = _handlers['$table:insert']?.first;
//       if (insert != null) {
//         onTableChange(table: table, filter: filter, onInsert: insert);
//       }
//     }
//   }

//   void _sendRaw(Map<String, dynamic> data) =>
//       _channel?.sink.add(jsonEncode(data));
// }