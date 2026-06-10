import 'package:flutter/material.dart';

class LandingPageContent {
  final String title;
  final String subtitle;
  final List<String> notices;

  LandingPageContent({
    required this.title,
    required this.subtitle,
    this.notices = const [],
  });
}

class CmsProvider extends ChangeNotifier {
  LandingPageContent _content = LandingPageContent(
    title: 'Kapoeta Logistics & Parcels',
    subtitle: 'Fast. Secure. Affordable.',
    notices: [
      'New branch opened in Juba!',
      'Holiday shipping schedules now available.',
    ],
  );

  LandingPageContent get content => _content;

  void updateContent(String title, String subtitle) {
    _content = LandingPageContent(
      title: title,
      subtitle: subtitle,
      notices: _content.notices,
    );
    notifyListeners();
  }

  void addNotice(String notice) {
    _content.notices.add(notice);
    notifyListeners();
  }

  void removeNotice(int index) {
    _content.notices.removeAt(index);
    notifyListeners();
  }
}
