import 'dart:async';

import 'package:ember_quest/actors/water_enemy.dart';
import 'package:ember_quest/ember_quest.dart';
import 'package:ember_quest/objects/ground_block.dart';
import 'package:ember_quest/objects/platform_block.dart';
import 'package:ember_quest/objects/star.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/services.dart';

class EmberPlayer extends SpriteAnimationComponent with HasGameReference<EmberQuestGame>, KeyboardHandler, CollisionCallbacks {
  EmberPlayer({required super.position}) : super(size: Vector2.all(64), anchor: Anchor.center);

  final Vector2 velocity = Vector2.zero();
  final double moveSpeed = 200;
  final Vector2 fromAbove = Vector2(0, -1);
  final double gravity = 9.8;
  final double jumpSpeed = 650;
  final double terminalVelocity = 150;
  int horizontalDirection = 0;

  bool isOnGround = false;
  bool hasJumped = false;
  bool hitByEnemy = false;

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('ember.png'), SpriteAnimationData.sequenced(
        amount: 4, stepTime: 0.12, textureSize: Vector2.all(16))
    );
    add(CircleHitbox());
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is GroundBlock || other is PlatformBlock) {
      if (intersectionPoints.length == 2) {
        // Calculate the collision normal and separation distance.
        final mid = (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) / 2;

        final collisionNormal = absoluteCenter - mid;
        final separationDistance = (size.x / 2) - collisionNormal.length;
        collisionNormal.normalize();

        // If collision normal is almost upwards,
        // ember must be on ground.
        if (fromAbove.dot(collisionNormal) > 0.9) {
          isOnGround = true;
        }

        position += collisionNormal.scaled(separationDistance);
      }
    }

    if (other is Star) {
      other.removeFromParent();
      game.starsCollected++;
    }

    if (other is WaterEnemy) hit();
    super.onCollision(intersectionPoints, other);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalDirection = 0;
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyA)) ||
        (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) ? -1 : 0;
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyD)) ||
        (keysPressed.contains(LogicalKeyboardKey.arrowRight)) ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    velocity.x = horizontalDirection * moveSpeed;
    game.objectSpeed = 0;
    if (position.x - 36 <= 0 && horizontalDirection < 0) velocity.x = 0;

    if (position.x + 64 >= game.size.x / 2 && horizontalDirection > 0) {
      velocity.x = 0;
      game.objectSpeed = -moveSpeed;
    }
    velocity.y += gravity;

    if (hasJumped) {
      if (isOnGround) {
        velocity.y -= jumpSpeed;
        isOnGround = false;
      }
      hasJumped = false;
    }
    velocity.y = velocity.y.clamp(-jumpSpeed, terminalVelocity);
    position += velocity * dt;

    if (horizontalDirection < 0 && !isFlippedHorizontally) {
      flipHorizontally();
    } else if (horizontalDirection > 0 && isFlippedHorizontally) {
      flipHorizontally();
    }
    super.update(dt);
  }

  void hit() {
    if (hitByEnemy) return;

    game.health--;
    hitByEnemy = true;

    add(
      OpacityEffect.fadeOut(EffectController(
        alternate: true,
        duration: 0.1,
        repeatCount: 6
      ))..onComplete = () {
        hitByEnemy = false;
      }
    );
  }
}