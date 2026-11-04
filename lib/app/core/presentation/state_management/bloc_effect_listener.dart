// core/widgets/bloc_effect_listener.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/presentation/state_management/effect_mixin.dart';

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
