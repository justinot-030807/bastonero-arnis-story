// lib/domain/models/event.dart
// Pure Dart model for random events and news.

class GameEvent {
  final String id;
  final String title;
  final String tag; // 'positive' | 'negative' | 'neutral'
  final String text;
  final Map<String, dynamic> effects;

  const GameEvent({
    required this.id,
    required this.title,
    required this.tag,
    required this.text,
    required this.effects,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'tag': tag,
        'text': text,
        'effects': effects,
      };

  factory GameEvent.fromJson(Map<String, dynamic> json) => GameEvent(
        id: json['id'] as String,
        title: json['title'] as String,
        tag: json['tag'] as String? ?? 'neutral',
        text: json['text'] as String? ?? '',
        effects: json['effects'] as Map<String, dynamic>? ?? {},
      );
}
