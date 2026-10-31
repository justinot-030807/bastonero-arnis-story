// lib/ui/overlays/event_dialog_modal.dart
// Retro pixel-art modal for random events and community encounters.

import 'package:flutter/material.dart';
import '../../domain/models/event.dart';
import '../retro_ui.dart';

class EventDialogModal extends StatelessWidget {
  final GameEvent event;
  final void Function(EventChoice? choice) onResolve;

  const EventDialogModal({
    super.key,
    required this.event,
    required this.onResolve,
  });

  Color _getTagColor() {
    switch (event.tag) {
      case 'positive':
        return const Color(0xFF16A34A);
      case 'negative':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF0284C7);
    }
  }

  String _getTagLabel() {
    switch (event.tag) {
      case 'positive':
        return '[POSITIBO]';
      case 'negative':
        return '[BABALA]';
      default:
        return '[BALITA]';
    }
  }

  List<String> _getEventIcon() {
    switch (event.tag) {
      case 'positive':
        return PixelArtCatalog.miniTrophy;
      case 'negative':
        return PixelArtCatalog.miniHeart;
      default:
        return PixelArtCatalog.miniWind;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: RetroBox(
          width: 440,
          title: 'BALITA SA BAKURAN',
          backgroundColor: const Color(0xFF0F172A),
          borderColor: const Color(0xFF1A1C2C),
          bevelColor: _getTagColor(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header tag & Title
              Row(
                children: [
                  PixelSpriteWidget(matrix: _getEventIcon(), pixelSize: 2.0),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          color: _getTagColor(),
                          child: Text(
                            _getTagLabel(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7.5,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Event Narrative Box
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  border: Border.all(color: const Color(0xFF475569), width: 1.5),
                ),
                child: Text(
                  event.text,
                  style: const TextStyle(
                    color: Color(0xFFF1F5F9),
                    fontSize: 10,
                    height: 1.4,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Choices or Acknowledge
              if (event.choices.isNotEmpty) ...[
                ...event.choices.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: RetroButton(
                      height: 38,
                      color: const Color(0xFF0284C7),
                      onTap: () => onResolve(c),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            c.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          if (c.effectDescription.isNotEmpty)
                            Text(
                              c.effectDescription,
                              style: const TextStyle(
                                color: Color(0xFFFDE047),
                                fontSize: 7.5,
                                fontFamily: 'monospace',
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ] else
                RetroButton(
                  height: 36,
                  color: const Color(0xFFE6482E),
                  onTap: () => onResolve(null),
                  child: const Text(
                    'SIGE, NAIINTINDIHAN KO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
