import 'package:campus_flutter/base/enums/home_widget.dart';
import 'package:campus_flutter/base/enums/user_preference.dart';
import 'package:campus_flutter/base/enums/widget_type.dart';
import 'package:campus_flutter/calendarComponent/views/homeWidget/calendar_widget_view.dart';
import 'package:campus_flutter/departuresComponent/views/homeWidget/departures_widget_view.dart';
import 'package:campus_flutter/main.dart';
import 'package:campus_flutter/movieComponent/views/homeWidget/movies_widget_view.dart';
import 'package:campus_flutter/newsComponent/views/homeWidget/news_widget_view.dart';
import 'package:campus_flutter/placesComponent/views/homeWidget/cafeteria_widget_view.dart';
import 'package:campus_flutter/placesComponent/views/homeWidget/study_room_widget_view.dart';
import 'package:campus_flutter/settingsComponent/service/user_preferences_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

final homeViewModel = Provider((ref) => HomeViewModel(ref));

class HomeViewModel {
  late BehaviorSubject<List<HomeScreenWidget>> widgets;

  final Ref ref;

  HomeViewModel(this.ref) {
    final data = getIt<UserPreferencesService>()
            .load(UserPreference.homeWidgets) as List<String>? ??
        <String>[];
    List<HomeScreenWidget> widgets = defaultWidgets;
    final types = data.map((e) => HomeScreenWidget.fromString(e)).toList();
    if (types.isNotEmpty) {
      widgets = types;
    }
    this.widgets = BehaviorSubject.seeded(widgets);
  }

  void toggleWidget(int index, bool value) {
    if (widgets.value.length - 1 >= index) {
      final data = widgets.value;
      final widget = data[index];
      widget.enabled = value;
      data[index] = widget;
      savePreference(data);
      widgets.add(data);
    }
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final data = widgets.value;
    final HomeScreenWidget item = data.removeAt(oldIndex);
    data.insert(newIndex, item);
    savePreference(data);
    widgets.add(data);
  }

  void savePreference(List<HomeScreenWidget> data) {
    final enabledWidgets = data.map((e) => e.convertToString()).toList();
    getIt<UserPreferencesService>()
        .save(UserPreference.homeWidgets, enabledWidgets);
  }

  List<HomeScreenWidget> getEnabledWidgets() {
    return widgets.value.where((element) => element.enabled).toList();
  }

  bool widgetsEnabled() {
    return widgets.value.where((element) => element.enabled).isNotEmpty;
  }

  static Widget getWidget(WidgetType widgetType) {
    switch (widgetType) {
      case WidgetType.cafeterias:
        return const CafeteriaWidgetView();
      case WidgetType.calendar:
        return const CalendarHomeWidgetView();
      case WidgetType.departures:
        return const DeparturesHomeWidget();
      case WidgetType.studyRooms:
        return const StudyRoomWidgetView.closest();
      case WidgetType.movies:
        return const MoviesHomeWidget();
      case WidgetType.news:
        return const NewsWidgetView();
    }
  }

  static String getTitle(WidgetType widgetType, BuildContext context) {
    switch (widgetType) {
      case WidgetType.cafeterias:
        return context.tr("cafeteria");
      case WidgetType.calendar:
        return context.tr("calendar");
      case WidgetType.departures:
        return context.tr("departures");
      case WidgetType.studyRooms:
        return context.tr("nearestStudyRooms");
      case WidgetType.movies:
        return context.tr("movies");
      case WidgetType.news:
        return context.tr("news");
    }
  }

  static List<HomeScreenWidget> get defaultWidgets => [
        HomeScreenWidget(widgetType: WidgetType.cafeterias),
        HomeScreenWidget(widgetType: WidgetType.calendar),
        HomeScreenWidget(widgetType: WidgetType.departures),
        HomeScreenWidget(widgetType: WidgetType.studyRooms),
        HomeScreenWidget(widgetType: WidgetType.movies),
        HomeScreenWidget(widgetType: WidgetType.news),
      ];

  void reset() {
    widgets.add(defaultWidgets);
    savePreference(defaultWidgets);
  }
}
