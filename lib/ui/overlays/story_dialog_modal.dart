import 'package:flutter/material.dart';
import '../../models/story_event_model.dart';
import '../retro_ui.dart';

class StoryDialogModal extends StatefulWidget {
  final StoryEvent event;
  final VoidCallback onDismiss;

  const StoryDialogModal({
    super.key,
    required this.event,
    required this.onDismiss,
  });

  @override
  State<StoryDialogModal> createState() => _StoryDialogModalState();
}

class _StoryDialogModalState extends State<StoryDialogModal> {
  int _dialogueIndex = 0;

  List<String> _getSpeakerPortrait(String speaker) {
    if (speaker.contains('Kanor')) {
      return PixelArtCatalog.coachKanorPortrait;
    } else if (speaker.contains('Berto')) {
      return PixelArtCatalog.bertoPortrait;
    } else if (speaker.contains('Lorenzo')) {
      return PixelArtCatalog.lorenzoPortrait;
    } else {
      return PixelArtCatalog.bayaniPortrait;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dialogues = widget.event.dialogues;
    final isLast = _dialogueIndex >= dialogues.length - 1;
    final portrait = _getSpeakerPortrait(widget.event.speaker);

    return Center(
      child: RetroBox(
        width: 440,
        title: widget.event.title,
        backgroundColor: const Color(0xFF0F172A),
        borderColor: const Color(0xFF1A1C2C),
        bevelColor: const Color(0xFFF4B41B),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                PixelSpriteWidget(matrix: portrait, pixelSize: 2.4),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.speaker,
                        style: const TextStyle(
                          color: Color(0xFFFDE047),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        widget.event.speakerRole,
                        style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 9, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(minHeight: 70),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                border: Border.all(color: const Color(0xFF475569)),
              ),
              child: Text(
                dialogues.isNotEmpty ? dialogues[_dialogueIndex] : '',
                style: const TextStyle(
                  color: Color(0xFFF4ECE1),
                  fontSize: 11,
                  height: 1.4,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 10),

            if (isLast &&
                (widget.event.rewardPesos > 0 ||
                    widget.event.rewardPower > 0 ||
                    widget.event.rewardAcademics > 0))
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.event.rewardPesos > 0)
                      Text('+P${widget.event.rewardPesos} ', style: const TextStyle(color: Color(0xFFFDE047), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                    if (widget.event.rewardPower > 0)
                      Text('+${widget.event.rewardPower} Lakas ', style: const TextStyle(color: Color(0xFFDC2626), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                    if (widget.event.rewardAcademics > 0)
                      Text('+${widget.event.rewardAcademics} Grado ', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  ],
                ),
              ),

            RetroButton(
              height: 40,
              color: const Color(0xFFF4B41B),
              onTap: () {
                if (isLast) {
                  widget.onDismiss();
                } else {
                  setState(() => _dialogueIndex++);
                }
              },
              child: Text(
                isLast ? 'SIGE! (CONFIRM)' : 'SUNOD >> (${_dialogueIndex + 1}/${dialogues.length})',
                style: const TextStyle(color: Color(0xFF1A1C2C), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
