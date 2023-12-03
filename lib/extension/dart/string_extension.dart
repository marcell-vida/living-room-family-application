extension StringExtension on String?{
  bool get isNotEmptyOrNull => this != null && this!.isNotEmpty;
}