import 'package:cloud_firestore/cloud_firestore.dart';

extension MapExtension on Map<String, dynamic> {
  String? getString(String key, {String? defaultValue}) {
    if (containsKey(key)) {
      return this[key]?.toString();
    } else {
      return defaultValue;
    }
  }

  bool? getBool(String key, {bool? defaultValue}) {
    if (containsKey(key)) {
      switch (this[key].toString().trim().toLowerCase()) {
        case "true":
          return true;
        case "false":
          return false;
        default:
          return defaultValue;
      }
    } else {
      return defaultValue;
    }
  }

  int? getInt(String key, {int? defaultValue}) {
    if (containsKey(key)) {
      var value = this[key];
      if (value is int) {
        return value;
      }
      return int.tryParse("$value") ?? defaultValue;
    } else {
      return defaultValue;
    }
  }

  double? getDouble(String key, {double? defaultValue}) {
    if (containsKey(key)) {
      var value = this[key];
      if (value is double) {
        return value;
      }
      return double.tryParse("$value") ?? defaultValue;
    } else {
      return defaultValue;
    }
  }

  Timestamp? getTimestamp(String key, {Timestamp? defaultValue}) {
    if (containsKey(key)) {
      try {
        return this[key] as Timestamp;
      } catch (e) {
        return defaultValue;
      }
    } else {
      return defaultValue;
    }
  }

  List<String>? getStringList(String key, {List<String>? defaultValue}){
    if (containsKey(key)) {
      try {
        return this[key] as List<String>;
      } catch (e) {
        return defaultValue;
      }
    } else {
      return defaultValue;
    }
  }

  Map<String, dynamic>? getMap(String key, {Map<String, dynamic>? defaultValue}) {
    if (containsKey(key)) {
      try {
        return this[key] as Map<String, dynamic>;
      } catch (e) {
        return defaultValue;
      }
    } else {
      return defaultValue;
    }
  }
}
