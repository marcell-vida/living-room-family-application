import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

class TempBottomSheetCubit extends Cubit<TempBottomSheetState> {
  TempBottomSheetCubit({int? seconds})
      : super(TempBottomSheetState(timeLeft: seconds ?? 10)) {
    _init();
  }

  _init() {
    _startCounter();
  }

  Future<void> _startCounter() async {
    while (state.timeLeft > 0) {
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(timeLeft: state.timeLeft - 1));
    }
  }
}

class TempBottomSheetState extends Equatable {
  final int timeLeft;

  const TempBottomSheetState({this.timeLeft = 10});

  TempBottomSheetState copyWith({int? timeLeft}) {
    return TempBottomSheetState(timeLeft: timeLeft ?? this.timeLeft);
  }

  @override
  List<Object?> get props => [timeLeft];
}
