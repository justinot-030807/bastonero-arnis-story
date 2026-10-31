import 'package:flutter/material.dart';
import '../../models/story_event_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final dialogues = widget.event.dialogues;
    final isLast = _dialogueIndex >= dialogues.length - 1;

    return Center(
      child: Container(
        width: 460,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border.all(color: const Color(0xFFFBBF24), width: 3),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 18,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SPEAKER HEADER
            Row(
              children: [
                // Stylized Pixel Avatar Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    border: Border.all(color: const Color(0xFFFBBF24), width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      widget.event.speaker.substring(0, 1),
                      style: const TextStyle(
                        color: Color(0xFFFBBF24),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.speaker,
                        style: const TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        widget.event.speakerRole,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // DIALOGUE TEXT BOX
            Container(
              padding: const EdgeInsets.all(14),
              constraints: const BoxConstraints(minHeight: 80),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                border: Border.all(color: const Color(0xFF334155)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                dialogues.isNotEmpty ? dialogues[_dialogueIndex] : '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 12),

            // REWARD PREVIEW (IF ANY)
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
                      Text(
                        '+₱${widget.event.rewardPesos} ',
                        style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    if (widget.event.rewardPower > 0)
                      Text(
                        '+${widget.event.rewardPower} Lakas ',
                        style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    if (widget.event.rewardAcademics > 0)
                      Text(
                        '+${widget.event.rewardAcademics} Grado ',
                        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),

            // NEXT / DONE BUTTON
            SizedBox(
              height: 42,
              child: ElevatedButton(
                onPressed: () {
                  if (isLast) {
                    widget.onDismiss();
                  } else {
                    setState(() {
                      _dialogueIndex++;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(color: Colors.white, width: 1.5),
                  ),
                ),
                child: Text(
                  isLast ? 'SIGE! (CONFIRM)' : 'SUNOD >> (${_dialogueIndex + 1}/${dialogues.length})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
