import 'package:bursa_app/models/firestore_collections.dart';
import 'package:bursa_app/screens/events/empty_week_view.dart';
import 'package:bursa_app/screens/events/week_panel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../models/event.dart';
import '../utils/date_utils.dart';
import 'day_header.dart';
import 'event_tile.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  DateTime _weekStart = startOfWeek(DateTime.now());
  late Stream<List<Event>> _eventsStream;
  late final Timer _refreshTimer;
  final _todayKey = GlobalKey();
  bool _didAutoScroll = false;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {});
    });
    _eventsStream = _loadEvents();
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wydarzenia")),
      body: Column(
        children: [
          SizedBox(height: 8),
          WeekPanel(
            leftClick: () => _changeWeek(-7),
            rightClick: () => _changeWeek(7),
            startDate: _weekStart,
          ),
          Expanded(
            child: StreamBuilder<List<Event>>(
              stream: _eventsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  ); // TODO - co robimy w trakcie ładowania danych?
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  ); // TODO - jakieś "nie udało się pobrać danych"
                }

                if (snapshot.data!.isEmpty) {
                  return EmptyWeekView();
                }

                final events = _mapEventList(snapshot.data!);
                final scrollTarget = _scrollTargetDay(events);

                if (!_didAutoScroll && scrollTarget != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final ctx = _todayKey.currentContext;
                    if (ctx != null) {
                      Scrollable.ensureVisible(
                        ctx,
                        duration: const Duration(milliseconds: 600),
                      );
                    }
                  });
                  _didAutoScroll = true;
                }

                return ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    for (var i = 0; i < 7; i++)
                      if (events[i].isNotEmpty) ...[
                        DayHeader(
                          key: i == scrollTarget ? _todayKey : null,
                          date: addDays(_weekStart, i),
                        ),
                        SizedBox(height: 8),
                        for (final e in events[i]) ...[
                          EventTile(event: e),
                          SizedBox(height: 12),
                        ],
                      ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<Event>> _loadEvents() {
    return FirebaseFirestore.instance
        .collection(FirestoreCollections.events)
        .where(
          EventFields.start,
          isGreaterThanOrEqualTo: Timestamp.fromDate(_weekStart),
        )
        .where(
          EventFields.start,
          isLessThan: Timestamp.fromDate(addDays(_weekStart, 7)),
        )
        .orderBy(EventFields.start)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Event.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  List<List<Event>> _mapEventList(List<Event> events) {
    final days = List.generate(7, (_) => <Event>[]);

    for (var event in events) {
      days[event.start.weekday - 1].add(event);
    }
    return days;
  }

  void _changeWeek(int days){
    setState(() {
      _weekStart = addDays(_weekStart, days);
      _eventsStream = _loadEvents();
      _didAutoScroll = false;
    });
  }

  int? _scrollTargetDay(List<List<Event>> days) {
    if (_weekStart != startOfWeek(DateTime.now())) return null;

    final todayIndex = DateTime.now().weekday - 1;
    for (var i = todayIndex; i < 7; i++) {
      if (days[i].isNotEmpty) return i;
    }
    return null;
  }
}
