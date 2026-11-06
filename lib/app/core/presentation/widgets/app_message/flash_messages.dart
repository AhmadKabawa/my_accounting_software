import 'package:flutter/widgets.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';

/// A message to show once, wherever the user lands next.
class FlashMessage {
  const FlashMessage(this.key, this.type);

  final AppKey key;
  final MessageType type;
}

/// Small long-lived service for messages that must outlive the page (and the
/// page cubit) that produced them: "signed out", "session expired",
/// "password changed"...
///
/// - With a listener attached, [post] delivers to the most recent one only
///   (so stacked pages never show it twice).
/// - Without one, the message waits and is replayed to the first listener that
///   attaches.
class FlashMessages {
  final List<FlashMessage> _pending = [];
  final List<void Function(FlashMessage)> _listeners = [];

  /// Number of messages waiting for a listener (for tests).
  int get pendingCount => _pending.length;

  void post(AppKey key, MessageType type) {
    final message = FlashMessage(key, type);
    if (_listeners.isEmpty) {
      _pending.add(message);
    } else {
      _listeners.last(message);
    }
  }

  /// Starts listening; returns the function that stops it. Anything waiting is
  /// delivered right away to this listener.
  VoidCallback listen(void Function(FlashMessage) onMessage) {
    _listeners.add(onMessage);
    if (_pending.isNotEmpty) {
      final waiting = List<FlashMessage>.of(_pending);
      _pending.clear();
      waiting.forEach(onMessage);
    }
    return () => _listeners.remove(onMessage);
  }
}

/// Shows [FlashMessages] while it is in the tree. Put it once in every
/// scaffold that can be the landing page after a redirect (`AuthPageScaffold`
/// and the app shell).
class FlashMessageListener extends StatefulWidget {
  const FlashMessageListener({super.key, required this.child, this.messages});

  final Widget child;

  /// Defaults to the registered singleton (none registered = no messages).
  final FlashMessages? messages;

  @override
  State<FlashMessageListener> createState() => _FlashMessageListenerState();
}

class _FlashMessageListenerState extends State<FlashMessageListener> {
  VoidCallback? _cancel;

  @override
  void initState() {
    super.initState();
    // No service registered (e.g. a widget test of a page): nothing to show.
    final service =
        widget.messages ??
        (sl.isRegistered<FlashMessages>() ? sl<FlashMessages>() : null);
    _cancel = service?.listen(_show);
  }

  void _show(FlashMessage message) {
    // Replayed messages arrive during initState: wait for the first frame so
    // a Scaffold/ScaffoldMessenger exists.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      MessageViewWidgets.showMessage(
        context,
        messageKey: message.key,
        type: message.type,
      );
    });
  }

  @override
  void dispose() {
    _cancel?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
