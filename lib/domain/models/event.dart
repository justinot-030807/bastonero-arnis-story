// lib/domain/models/event.dart
// Pure Dart model for random events, flavor encounters, and news.

class EventChoice {
  final String id;
  final String label;
  final String effectDescription;
  final Map<String, dynamic> effects;

  const EventChoice({
    required this.id,
    required this.label,
    required this.effectDescription,
    this.effects = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'effectDescription': effectDescription,
        'effects': effects,
      };

  factory EventChoice.fromJson(Map<String, dynamic> json) => EventChoice(
        id: json['id'] as String? ?? 'choice',
        label: json['label'] as String? ?? 'Sige',
        effectDescription: json['effectDescription'] as String? ?? '',
        effects: json['effects'] as Map<String, dynamic>? ?? {},
      );
}

class GameEvent {
  final String id;
  final String title;
  final String tag; // 'positive' | 'negative' | 'neutral'
  final String text;
  final Map<String, dynamic> effects;
  final List<EventChoice> choices;
  final int? triggerMonth; // Specific month required (e.g., 12 for December / Pasko)
  final String? condition; // e.g. 'rainy_season', 'has_failing_student', 'has_alumni'
  final int cooldownWeeks;

  const GameEvent({
    required this.id,
    required this.title,
    required this.tag,
    required this.text,
    required this.effects,
    this.choices = const [],
    this.triggerMonth,
    this.condition,
    this.cooldownWeeks = 12,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'tag': tag,
        'text': text,
        'effects': effects,
        'choices': choices.map((c) => c.toJson()).toList(),
        'triggerMonth': triggerMonth,
        'condition': condition,
        'cooldownWeeks': cooldownWeeks,
      };

  factory GameEvent.fromJson(Map<String, dynamic> json) => GameEvent(
        id: json['id'] as String,
        title: json['title'] as String,
        tag: json['tag'] as String? ?? 'neutral',
        text: json['text'] as String? ?? '',
        effects: json['effects'] as Map<String, dynamic>? ?? {},
        choices: (json['choices'] as List<dynamic>?)
                ?.map((c) => EventChoice.fromJson(c as Map<String, dynamic>))
                .toList() ??
            const [],
        triggerMonth: json['triggerMonth'] as int?,
        condition: json['condition'] as String?,
        cooldownWeeks: json['cooldownWeeks'] as int? ?? 12,
      );
}
