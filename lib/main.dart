import 'package:ember_quest/ember_quest.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const GameWidget<EmberQuestGame>.controlled(gameFactory: EmberQuestGame.new));
}