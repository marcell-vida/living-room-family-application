import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

/// Navigációs sáv állapotát kezelő Cubit osztály
class NavigatorBarCubit extends Cubit<NavigatorBarState> {
  /// Inicializáláskor létrehozunk egy állapotot
  NavigatorBarCubit() : super(const NavigatorBarState());

  /// metódus, ami egy új állapotot fog sugározni a kívánt
  /// indexszel
  void changeIndex(int index) {
    if (state.selectedIndex != index) {
      /// az új érték nem egyezik a régivel

      /// új állapot létrehozása, sugárzása
      emit(state.copyWith(selectedIndex: index));
    }
  }
}

/// Navigációs sáv állapota
class NavigatorBarState extends Equatable {
  /// a tárolt értékeknek nem kell módosíthatónak lenniük,
  /// mert új állapot lesz létrehozva az új értékeknek
  final int selectedIndex;

  const NavigatorBarState({this.selectedIndex = 0});

  NavigatorBarState copyWith({int? selectedIndex}) {
    return NavigatorBarState(
        selectedIndex: selectedIndex ?? this.selectedIndex);
  }

  /// a felületépítés során az itt felsorolt változók között
  /// lehet különbséget tenni
  @override
  List<Object?> get props => [selectedIndex];
}
