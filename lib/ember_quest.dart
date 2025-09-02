import 'dart:async';

import 'package:ember_quest/actors/ember.dart';
import 'package:ember_quest/hud.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';

import 'actors/water_enemy.dart';
import 'managers/segment_manager.dart';
import 'objects/ground_block.dart';
import 'objects/platform_block.dart';
import 'objects/star.dart';

class EmberQuestGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  EmberQuestGame();
  late EmberPlayer ember;
  double objectSpeed = 0.0;
  late double lastBlockXPosition = 0.0;
  late UniqueKey lastBlockKey;

  int starsCollected = 0;
  int health = 3;

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }

  @override
  FutureOr<void> onLoad() async{
    await images.loadAll([
      'block.png',
      'ember.png',
      'ground.png',
      'heart_half.png',
      'heart.png',
      'star.png',
      'water_enemy.png',
    ]);

    camera.viewfinder.anchor = Anchor.topLeft;
  }

  @override
  void update(double dt) {
    if (health <= 0) overlays.add('GameOver');
    super.update(dt);
  }

  void loadSegment(int segmentIndex, double xPositionOffset) {
    for (final block in segments[segmentIndex]) {
      switch (block.blockType) {
        case GroundBlock:
          world.add(GroundBlock(
              gridPosition: block.gridPosition,
              xOffset: xPositionOffset
          ));
          break;
        case PlatformBlock:
          world.add(PlatformBlock(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset
          ));
          break;
        case Star:
          world.add(Star(
              gridPosition: block.gridPosition,
              xOffset: xPositionOffset
          ));
          break;
        case WaterEnemy:
          world.add(WaterEnemy(
              gridPosition: block.gridPosition,
              xOffset: xPositionOffset
          ));
          break;
      }
    }
  }

  void initiateGame(bool loadHud) {
    final segmentsToLoad = (size.x / 640).ceil();
    segmentsToLoad.clamp(0, segments.length);

    for (var i = 0; i <= segmentsToLoad; i++) {
      loadSegment(i, (640 * i).toDouble());
    }

    ember = EmberPlayer(position: Vector2(128, canvasSize.y - 128));
    add(ember);

    if (loadHud) {
      add(HUD());
    }
  }

  void reset() {
    starsCollected = 0;
    health = 3;
    initiateGame(false);
  }
}