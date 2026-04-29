import 'dart:math';

String generateId() {
  final rand = Random();
  final ts = DateTime.now().millisecondsSinceEpoch;
  final suffix = List.generate(5, (_) => rand.nextInt(36).toRadixString(36)).join();
  return 'id-$ts-$suffix';
}
