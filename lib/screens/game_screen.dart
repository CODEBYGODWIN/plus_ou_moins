import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/game_controller.dart';
import '../models/product.dart';
import '../models/game_state.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Plus ou Moins')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (message) => _ErrorView(
          message: message,
          onRetry: () => ref.read(gameProvider.notifier).playAgain(),
        ),

        playing: (current, next, score, pool, revealed, lastGuessCorrect) =>
            _PlayingView(
              current: current,
              next: next,
              score: score,
              onHigher: () => ref.read(gameProvider.notifier).guessHigher(),
              onLower: () => ref.read(gameProvider.notifier).guessLower(),
            ),

        gameOver: (finalScore) => _GameOverView(
          score: finalScore,
          onReplay: () => ref.read(gameProvider.notifier).playAgain(),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Oups, une erreur est survenue',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayingView extends StatelessWidget {
  final Product current;
  final Product next;
  final int score;
  final VoidCallback onHigher;
  final VoidCallback onLower;

  const _PlayingView({
    required this.current,
    required this.next,
    required this.score,
    required this.onHigher,
    required this.onLower,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Score : $score',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(child: _ProductCard(product: current, showPrice: true)),
            const SizedBox(height: 8),

            const Text(
              'Le produit suivant est-il plus cher ou moins cher ?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),

            Expanded(child: _ProductCard(product: next, showPrice: false)),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onLower,
                    icon: const Icon(Icons.arrow_downward),
                    label: const Text('Moins cher'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onHigher,
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('Plus cher'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GameOverView extends StatelessWidget {
  final int score;
  final VoidCallback onReplay;
  const _GameOverView({required this.score, required this.onReplay});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.sentiment_very_dissatisfied,
            size: 80,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          const Text(
            'Game Over',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Score final : $score', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onReplay,
            icon: const Icon(Icons.replay),
            label: const Text('Rejouer'),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final bool showPrice; // affiche le prix (visible) ou un "?" (caché)
  const _ProductCard({required this.product, required this.showPrice});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.network(
                product.thumbnail,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stack) =>
                    const Icon(Icons.image_not_supported, size: 48),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              showPrice ? '${product.price} \$' : '???',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: showPrice ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
