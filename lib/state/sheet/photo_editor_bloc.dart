import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:living_room/extension/dart/string_extension.dart';

class PhotoEditorCubit extends Cubit<PhotoEditorState> {
  PhotoEditorCubit() : super(const PhotoEditorState(photoDetailsMode: PhotoDetailsMode.choose));

  void setChosenPhoto(String? path) {
    if (path.isNotEmptyOrNull) {
      emit(state.copyWith(chosenPhoto: path));
    }
  }
}

enum PhotoDetailsMode { choose, approve }

class PhotoEditorState extends Equatable {
  final String? chosenPhoto;
  final PhotoDetailsMode photoDetailsMode;

  const PhotoEditorState({this.chosenPhoto, required this.photoDetailsMode});

  PhotoEditorState copyWith(
      {String? chosenPhoto, PhotoDetailsMode? photoDetailsMode}) {
    return PhotoEditorState(
        chosenPhoto: chosenPhoto ?? this.chosenPhoto,
        photoDetailsMode: photoDetailsMode ?? this.photoDetailsMode);
  }

  @override
  List<Object?> get props => [chosenPhoto, photoDetailsMode];
}
