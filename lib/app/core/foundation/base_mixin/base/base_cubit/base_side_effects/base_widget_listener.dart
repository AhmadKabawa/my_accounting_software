// core/widgets/bloc_effect_listener.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/foundation/base_mixin/mixin/effect_mixin.dart';

// core/widgets/bloc_effect_listener.dart
// ignore: avoid_types_as_parameter_names
class BlocEffectListener<Effects, CubitB extends HasEffects<Effects>>
    extends StatefulWidget {
  final Widget child;
  final void Function(BuildContext context, Effects effect) onEffect;

  final CubitB? cubit; // optional

  const BlocEffectListener({
    super.key,
    required this.onEffect,
    required this.child,
    this.cubit,
  });

  @override
  State<BlocEffectListener<Effects, CubitB>> createState() =>
      _BlocEffectListenerState<Effects, CubitB>();
}

class _BlocEffectListenerState<Effects, CubitB extends HasEffects<Effects>>
    extends State<BlocEffectListener<Effects, CubitB>> {
  StreamSubscription<Effects>? _subscription;

  late CubitB _cubit;

  @override
  void initState() {
    super.initState();

    _cubit = widget.cubit ?? context.read<CubitB>();

    _subscribe();
  }

  void _subscribe() {
    _subscription = _cubit.effectStream.listen((effect) {
      if (mounted) {
        widget.onEffect(context, effect);
      }
    });
  }

  @override
  void didUpdateWidget(BlocEffectListener<Effects, CubitB> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldCubit = oldWidget.cubit ?? _cubit;
    final newCubit = widget.cubit ?? context.read<CubitB>();

    if (oldCubit != newCubit) {
      _subscription?.cancel();
      _cubit = newCubit;
      _subscribe();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
/*


// core/widgets/bloc_effect_listener.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/foundation/base_mixin/base/base_cubit/base_side_effects/base_cubit.dart';

class BlocEffectListener<CubitB extends BaseCubit<S, Effects>, S, Effects>
    extends StatefulWidget {
  final Widget child;
  final void Function(BuildContext context, Effects effect) onEffect;
  final CubitB? cubit; // اختياري - لو مش موجود يقرأه من context

  const BlocEffectListener({
    super.key,
    required this.child,
    required this.onEffect,
    this.cubit,
  });

  @override
  State<BlocEffectListener<CubitB, S, Effects>> createState() =>
      _BlocEffectListenerState<CubitB, S, Effects>();
}

class _BlocEffectListenerState<CubitB extends BaseCubit<S, Effects>, S, Effects>
    extends State<BlocEffectListener<CubitB, S, Effects>> {
  StreamSubscription<Effects>? _subscription;
  late CubitB _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? context.read<CubitB>();
    _subscribe();
  }

  void _subscribe() {
    _subscription = _cubit.effectStream.listen((effect) {
      if (mounted) widget.onEffect(context, effect);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
/**BlocEffectListener<AuthCubit, AuthState, AuthEffect>(
  cubit: myAuthCubit, // ✅ مش محتاج يكون في الـ context
  onEffect: (context, effect) { ... },
  child: const MyWidget(),
)



// لو عندك effects + states تستمع ليهم
MultiBlocListener(
  listeners: [
    BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // تغيرات الـ state
      },
    ),
    BlocEffectListener<AuthCubit, AuthState, AuthEffect>(
      onEffect: (context, effect) {
        // one-time effects
      },
    ),
  ],
  child: const LoginBody(),
)
```

---

## المقارنة النهائية 🎯
```
BlocListener          BlocEffectListener
──────────────────────────────────────────────
يستمع للـ State   →   يستمع للـ Effects فقط
يُعاد trigger     →   مرة واحدة فقط
جزء من flutter_bloc→  custom widget خفيف

 */
/* غير هام class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();

    // ✅ مباشرة على الـ Stream بدون Widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscription = context.read<AuthCubit>().effectStream.listen((effect) {
        if (mounted) _handleEffect(effect);
      });
    });
  }

  void _handleEffect(AuthEffect effect) {
    switch (effect) {
      case NavigateToHome():
        Navigator.pushReplacementNamed(context, '/home');
      case ShowErrorSnackBar():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(effect.message)),
        );
      // ...
    }
  }

  @override
  void dispose() {
    _subscription?.cancel(); // ✅ مهم
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(); // بدون BlocEffectListener
  }
}
```

---

## متى تستخدم كل واحدة؟
```
initState + Stream.listen    →  لو محتاج logic قبل أو عند بناء الـ Widget
BlocEffectListener           →  الاستخدام الطبيعي داخل build() */
*/