import 'dart:async';
import 'dart:math';

import 'package:ember_quest/ember_quest.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';

import '../managers/segment_manager.dart';

class GroundBlock extends SpriteComponent with HasGameReference<EmberQuestGame> {
  GroundBlock({required this.gridPosition, required this.xOffset})
      : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  final Vector2 gridPosition;
  double xOffset;
  final Vector2 velocity = Vector2.zero();
  final UniqueKey _blockKey= UniqueKey();

  @override
  FutureOr<void> onLoad() {
    final groundImage = game.images.fromCache('ground.png');
    sprite = Sprite(groundImage);
    position = Vector2(
        (gridPosition.x * size.x) + xOffset,
        game.size.y - (gridPosition.y * size.y)
    );
    add(RectangleHitbox(collisionType: CollisionType.passive));

    if (gridPosition.x == 9 && position.x > game.lastBlockXPosition) {
      game.lastBlockKey = _blockKey;
      game.lastBlockXPosition = position.x + size.x;
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    velocity.x = game.objectSpeed;
    position += velocity * dt;

    if (position.x < -size.x) {
      removeFromParent();

      if (gridPosition.x == 0) {
        game.loadSegment(
            Random().nextInt(segments.length),
            game.lastBlockXPosition);
      }
    }

    if (gridPosition.x == 9) {
      if (game.lastBlockKey == _blockKey) {
        game.lastBlockXPosition = position.x + size.x - 10;
      }
    }
    super.update(dt);
  }
}