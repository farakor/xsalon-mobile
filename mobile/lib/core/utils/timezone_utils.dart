import 'package:flutter/material.dart';

/// Утилиты для работы с самаркандским временем (UTC+5)
class TimezoneUtils {
  /// Смещение для самаркандского времени (UTC+5)
  static const Duration samarkandOffset = Duration(hours: 5);
  
  /// Преобразовать DateTime в самаркандское время
  static DateTime toSamarkandTime(DateTime dateTime) {
    // Если время уже в UTC, добавляем смещение
    if (dateTime.isUtc) {
      return dateTime.add(samarkandOffset);
    }
    
    // Если время локальное, сначала преобразуем в UTC, затем в самаркандское
    return dateTime.toUtc().add(samarkandOffset);
  }
  
  /// Преобразовать самаркандское время в UTC для сохранения в БД
  static DateTime samarkandToUtc(DateTime samarkandTime) {
    return samarkandTime.subtract(samarkandOffset).toUtc();
  }
  
  /// Создать DateTime для самаркандского времени из даты и времени
  static DateTime createSamarkandDateTime(DateTime date, TimeOfDay time) {
    // Создаем локальное время
    final localDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    
    // Преобразуем в UTC и добавляем смещение для Самарканда
    return localDateTime.toUtc().add(samarkandOffset);
  }
  
  /// Получить текущее самаркандское время
  static DateTime nowInSamarkand() {
    return toSamarkandTime(DateTime.now().toUtc());
  }
  
  /// Форматировать время для отображения (только время)
  static String formatTimeForDisplay(DateTime dateTime) {
    final samarkandTime = toSamarkandTime(dateTime);
    return '${samarkandTime.hour.toString().padLeft(2, '0')}:${samarkandTime.minute.toString().padLeft(2, '0')}';
  }
  
  /// Форматировать дату и время для отображения
  static String formatDateTimeForDisplay(DateTime dateTime) {
    final samarkandTime = toSamarkandTime(dateTime);
    return '${samarkandTime.day.toString().padLeft(2, '0')}.${samarkandTime.month.toString().padLeft(2, '0')}.${samarkandTime.year} ${formatTimeForDisplay(dateTime)}';
  }
}
