import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:living_room/extension/dart/string_extension.dart';
import 'package:living_room/state/object/families_bloc.dart';
import 'package:living_room/state/object/family_bloc.dart';

class FamilySelectorCubit extends Cubit<FamilySelectorState> {
  final FamiliesCubit currentUserFamiliesCubit;

  FamilySelectorCubit({required this.currentUserFamiliesCubit})
      : super(const FamilySelectorState());

  void changeFamily(String? id) {
    if (id.isNotEmptyOrNull) {
      emit(state.copyWith(
          selectedFamily: currentUserFamiliesCubit.getFamilyById(id)));
    }
  }
}

class FamilySelectorState extends Equatable {
  final FamilyCubit? selectedFamily;

  const FamilySelectorState({this.selectedFamily});

  FamilySelectorState copyWith({FamilyCubit? selectedFamily}) {
    return FamilySelectorState(
        selectedFamily: selectedFamily ?? this.selectedFamily);
  }

  @override
  List<Object?> get props => [selectedFamily];
}
