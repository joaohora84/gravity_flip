import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardEntry {
  final String uid;
  final String name;
  final int score;

  const LeaderboardEntry({
    required this.uid,
    required this.name,
    required this.score,
  });

  factory LeaderboardEntry.fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntry(
      uid: doc.id,
      name: data['name'] as String? ?? 'Unknown',
      score: (data['score'] as num?)?.toInt() ?? 0,
    );
  }
}

class LeaderboardService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  SharedPreferences? _prefs;

  static const _nameKey = 'player_name';

  String? get uid => _auth.currentUser?.uid;
  String? get playerName => _prefs?.getString(_nameKey);
  bool get hasName {
    final name = playerName;
    return name != null && name.trim().isNotEmpty;
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  Future<void> setName(String name) async {
    await _prefs?.setString(_nameKey, name.trim());
  }

  Future<void> submitScore(int score) async {
    final uid = this.uid;
    final name = playerName;
    if (uid == null || name == null || name.isEmpty) return;

    await _db.collection('leaderboard').doc(uid).set({
      'name': name,
      'score': score,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<LeaderboardEntry>> fetchTop100() async {
    final snapshot = await _db
        .collection('leaderboard')
        .orderBy('score', descending: true)
        .limit(100)
        .get();
    return snapshot.docs.map(LeaderboardEntry.fromDoc).toList();
  }
}
