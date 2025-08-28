import 'dart:async';

import 'package:ember_quest/ember_quest.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class PlatformBlock extends SpriteComponent with HasGameReference<EmberQuestGame> {
  PlatformBlock({required this.gridPosition, required this.xOffset})
      : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  final Vector2 gridPosition;
  final xOffset;
  final Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    final platformImage = game.images.fromCache('block.png');
    sprite = Sprite(platformImage);
    position = Vector2(
        (gridPosition.x * size.x) + xOffset,
        game.size.y - (gridPosition.y * size.y)
    );
    add(RectangleHitbox(collisionType: CollisionType.passive));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    velocity.x = game.objectSpeed;
    position += velocity * dt;
    if (position.x < -size.x) removeFromParent();
    super.update(dt);
  }
}