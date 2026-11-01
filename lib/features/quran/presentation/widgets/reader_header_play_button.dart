import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';

/// Compact round play / pause button for the sura header.
/// - primary-color gradient with a hairline highlight border
/// - soft glow that grows while playing
/// - icon morphs between play and pause, spinner while loading
/// - press-down scale feedback, 44px touch target around a 22px visual
class ReaderHeaderPlayButton extends StatefulWidget {
  final String tooltip;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback? onPressed;

  const ReaderHeaderPlayButton({
    super.key,
    required this.tooltip,
    required this.isPlaying,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<ReaderHeaderPlayButton> createState() => _ReaderHeaderPlayButtonState();
}

class _ReaderHeaderPlayButtonState extends State<ReaderHeaderPlayButton> {
  static const double _size = 22;
  static const double _touchSize = 44;

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final enabled = widget.onPressed != null;
    final playing = widget.isPlaying;

    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: widget.tooltip,
        child: AnimatedOpacity(
          opacity: enabled || widget.isLoading ? 1 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: p.primary.withValues(alpha: 0.25),
              highlightColor: Colors.transparent,
              onHighlightChanged: (value) => setState(() => _pressed = value),
              onTap: widget.onPressed,
              child: SizedBox(
                width: _touchSize,
                height: _touchSize,
                child: Center(
                  child: AnimatedScale(
                    scale: _pressed ? 0.88 : 1,
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOut,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      width: _size,
                      height: _size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.lerp(
                              p.primary,
                              Colors.white,
                              Theme.of(context).brightness == Brightness.dark
                                  ? 0.45
                                  : 0.12,
                            )!,
                            p.primary,
                            Color.lerp(p.primary, Colors.black, 0.12)!,
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: p.primary.withValues(
                              alpha: playing ? 0.5 : 0.22,
                            ),
                            blurRadius: playing ? 14 : 8,
                            spreadRadius: playing ? 1 : 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(
                                scale: animation,
                                child: RotationTransition(
                                  turns: Tween<double>(begin: 0.85, end: 1)
                                      .animate(animation),
                                  child: child,
                                ),
                              ),
                          child: widget.isLoading
                              ? SizedBox(
                            key: const ValueKey('loading'),
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: p.onPrimary,
                            ),
                          )
                              : Icon(
                            playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            key: ValueKey<bool>(playing),
                            size: 21,
                            color: p.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
