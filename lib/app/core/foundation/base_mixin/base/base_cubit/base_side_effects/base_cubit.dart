// core/base/base_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/foundation/base_mixin/mixin/effect_mixin.dart';

/// [State] نوع الـ state الخاص بالـ cubit
/// [Effect] نوع الـ one-time effects
abstract class BaseCubit<State, Effect> extends Cubit<State>
    with EffectMixin<Effect>
    implements HasEffects<Effect> {
  BaseCubit(super.initialState);

  @override
  Future<void> close() async {
    await disposeEffects();
    return super.close();
  }
}
