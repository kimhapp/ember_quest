import 'dart:async';

import 'package:ember_quest/actors/ember.dart';
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
  late EmberPlayer _ember;
  double objectSpeed = 0.0;
  late double lastBlockXPosition = 0.0;
  late UniqueKey lastBlockKey;

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
    initiateGame();
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

  void initiateGame() {
    final segmentsToLoad = (size.x / 640).ceil();
    segmentsToLoad.clamp(0, segments.length);

    for (var i = 0; i <= segmentsToLoad; i++) {
      loadSegment(i, (640 * i).toDouble());
    }

    _ember = EmberPlayer(position: Vector2(128, canvasSize.y - 128));
    world.add(_ember);
  }
}