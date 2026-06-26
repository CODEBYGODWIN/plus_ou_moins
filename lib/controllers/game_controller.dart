import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../services/product_api.dart';

final gameProvider = NotifierProvider<GameController, GameState>(
  GameController.new,
);

class GameController extends Notifier<GameState> {
  final ProductApi _api = ProductApi();

  @override
  GameState build() {
    _loadAndStart();
    return const GameState.loading();
  }

  Future<void> _loadAndStart() async {
    state = const GameState.loading();
    try {
      final products = await _api.fetchProducts();

      if (products.length < 2) {
        state = const GameState.error('Pas assez de produits pour jouer.');
        return;
      }

      final shuffled = [...products]..shuffle(Random());

      final current = shuffled[0];
      final next = shuffled[1];
      final pool = shuffled.sublist(2);

      state = GameState.playing(
        current: current,
        next: next,
        score: 0,
        pool: pool,
      );
    } catch (e) {
      state = GameState.error(e.toString());
    }
  }

  void guessHigher() => _handleGuess(playerSaysHigher: true);

  void guessLower() => _handleGuess(playerSaysHigher: false);

  void _handleGuess({required bool playerSaysHigher}) {
    state.maybeWhen(
      playing: (visible, hidden, score, pool, revealed, lastGuessCorrect) {
        final isHigher = hidden.price > visible.price;
        final correct =
            (playerSaysHigher && isHigher) || (!playerSaysHigher && !isHigher);

        if (!correct) {
          state = GameState.gameOver(score);
          return;
        }

        final newScore = score + 1;

        if (pool.isEmpty) {
          state = GameState.gameOver(newScore);
          return;
        }

        final newNext = pool.first;
        final newPool = pool.sublist(1);

        state = GameState.playing(
          current: hidden,
          next: newNext,
          score: newScore,
          pool: newPool,
        );
      },

      orElse: () {},
    );
  }

  void playAgain() {
    _loadAndStart();
  }
}
