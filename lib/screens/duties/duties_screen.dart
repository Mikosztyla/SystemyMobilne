import 'package:bursa_app/models/app_user.dart';
import 'package:bursa_app/screens/duties/views/all_duties_view.dart';
import 'package:bursa_app/screens/duties/views/floor_duties_view.dart';
import 'package:bursa_app/screens/duties/views/my_duties_view.dart';
import 'package:bursa_app/services/duties_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

class DutiesScreen extends StatefulWidget {
  const DutiesScreen({super.key});

  @override
  State<DutiesScreen> createState() => _DutiesScreenState();
}

class _DutiesScreenState extends State<DutiesScreen> {
  final DutiesRepository _repository = DutiesRepository();
  late final Stream<AppUser?> _userStream;
  late final String _uid;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser!;
    _uid = user.uid;
    _userStream = _repository.watchUser(user.uid, user.email ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: _userStream,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Dyżury")),
            body: Center(
              child: snapshot.hasError
                  ? const Text("Nie udało się pobrać profilu.")
                  : const CircularProgressIndicator(),
            ),
          );
        }
        return _buildTabs(user);
      },
    );
  }

  Widget _buildTabs(AppUser user) {
    final tabs = [
      const Tab(text: "Moje"),
      const Tab(text: "Piętro"),
      if (user.isAdmin) const Tab(text: "Wszystkie"),
    ];
    final views = [
      MyDutiesView(repository: _repository, uid: _uid, isAdmin: user.isAdmin),
      FloorDutiesView(
        repository: _repository,
        floor: user.floor,
        uid: _uid,
        isAdmin: user.isAdmin,
      ),
      if (user.isAdmin) AllDutiesView(repository: _repository, uid: _uid),
    ];

    return DefaultTabController(
      key: ValueKey(user.isAdmin),
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Dyżury"),
          bottom: TabBar(tabs: tabs),
        ),
        body: TabBarView(children: views),
      ),
    );
  }
}
