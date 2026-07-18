import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../game/gravity_flip_game.dart';
import '../game/systems/audio_system.dart';
import 'leaderboard_service.dart';

// ── Leaderboard display ────────────────────────────────────────────────────

class LeaderboardScreen extends StatefulWidget {
  static const id = 'leaderboard';

  final GravityFlipGame game;

  const LeaderboardScreen({super.key, required this.game});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardEntry>? _entries;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final entries = await widget.game.leaderboardService.fetchTop100();
      if (mounted) {
        setState(() {
          _entries = entries;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context)?.failedToLoad ??
              'Failed to load leaderboard';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final myUid = widget.game.leaderboardService.uid;

    return Material(
      color: const Color(0xF20D0D1A),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              s.leaderboard,
              style: const TextStyle(
                color: Color(0xFF00D4FF),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody(s, myUid)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                AudioSystem.playSfx(Sfx.buttonTap);
                widget.game.showMainMenu();
              },
              child: Text(
                s.back,
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations s, String? myUid) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Color(0xFF777799), fontSize: 14),
        ),
      );
    }
    final entries = _entries!;
    if (entries.isEmpty) {
      return Center(
        child: Text(
          s.noScoresYet,
          style: const TextStyle(color: Color(0xFF777799), fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isMe = entry.uid == myUid;
        return Container(
          color: isMe ? const Color(0x226C63FF) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: index < 3
                        ? const Color(0xFFFFEE58)
                        : const Color(0xFF555577),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  entry.name,
                  style: TextStyle(
                    color: isMe
                        ? const Color(0xFF00D4FF)
                        : const Color(0xFFCCCCCC),
                    fontSize: 14,
                    fontWeight:
                        isMe ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${entry.score}',
                style: TextStyle(
                  color: isMe
                      ? const Color(0xFF00D4FF)
                      : const Color(0xFFCCCCCC),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Name entry overlay ─────────────────────────────────────────────────────

class NameEntryOverlay extends StatefulWidget {
  static const id = 'nameEntry';

  final GravityFlipGame game;

  const NameEntryOverlay({super.key, required this.game});

  @override
  State<NameEntryOverlay> createState() => _NameEntryOverlayState();
}

class _NameEntryOverlayState extends State<NameEntryOverlay> {
  final _controller = TextEditingController();
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations s) async {
    AudioSystem.playSfx(Sfx.buttonTap);
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = s.nameEmpty);
      return;
    }
    if (name.length > 20) {
      setState(() => _errorText = s.nameTooLong);
      return;
    }
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    await widget.game.leaderboardService.setName(name);
    await widget.game.leaderboardService
        .submitScore(widget.game.pendingLeaderboardScore);
    widget.game.analyticsService
        .logLeaderboardScoreSubmitted(widget.game.pendingLeaderboardScore);
    widget.game.hideNameEntry();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    return Material(
      color: const Color(0xCC000000),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF12122A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s.yourName,
                style: const TextStyle(
                  color: Color(0xFF00D4FF),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.enterNameDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF777799),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                autofocus: true,
                maxLength: 20,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintText: s.enterNameHint,
                  hintStyle: const TextStyle(color: Color(0xFF444466)),
                  counterStyle: const TextStyle(color: Color(0xFF555577)),
                  errorText: _errorText,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF333355)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6C63FF)),
                  ),
                ),
                onSubmitted: (_) => _submit(s),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : () => _submit(s),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          s.saveAndSubmit,
                          style: const TextStyle(
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
