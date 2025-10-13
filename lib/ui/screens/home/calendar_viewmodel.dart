import 'package:flutter/material.dart';
import 'package:pandora_snap/domain/models/photo_model.dart';
import 'package:pandora_snap/domain/models/user_model.dart' as model;
import 'package:pandora_snap/domain/repositories/photo_repository.dart';

class CalendarViewModel extends ChangeNotifier {
  final PhotoRepository _photoRepository;

  CalendarViewModel(this._photoRepository);

  Map<DateTime, List<Photo>> _photosByDate = {};
  Map<DateTime, List<Photo>> get photosByDate => _photosByDate;
  
  Set<DateTime> get datesWithPhotos => _photosByDate.keys.toSet();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchData(model.User? user) async {
    if (user == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final dates = await _photoRepository.getDatesWithPhotos(user).first;
      final Map<DateTime, List<Photo>> tempMap = {};
      for (final date in dates) {
        final photos = await _photoRepository.getPhotosForDate(date, user);
        tempMap[date] = photos;
      }
      _photosByDate = tempMap;
    } catch (e) {
      debugPrint('Erro ao carregar dados do calendário: $e');
      _photosByDate = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}