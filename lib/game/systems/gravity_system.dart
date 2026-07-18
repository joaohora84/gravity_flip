/// Applies gravity/flap physics to the player each frame and handles flip state.
class GravitySystem {
  static const double gravity = 1200.0;
  static const double maxVelocity = 600.0;
  static const double flapImpulse = 500.0;

  double velocityY = 0.0;
  bool _frozen = false;

  void flip() {
    if (_frozen) return;
    velocityY = -flapImpulse;
  }

  void freeze() => _frozen = true;

  void unfreeze() {
    _frozen = false;
    velocityY = 0;
  }

  /// Advances the simulation by [dt] and returns the vertical displacement
  /// to apply to the player's position.
  double update(double dt) {
    if (_frozen) return 0;
    velocityY += gravity * dt;
    velocityY = velocityY.clamp(-maxVelocity, maxVelocity);
    return velocityY * dt;
  }
}
