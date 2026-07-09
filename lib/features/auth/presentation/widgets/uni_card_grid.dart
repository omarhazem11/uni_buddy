import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class UniCardData {
  final String name;
  final String location;
  final String emoji;
  final Color color;

  const UniCardData({
    required this.name,
    required this.location,
    required this.emoji,
    required this.color,
  });
}

const previewUniversities = [
  UniCardData(name: 'Cairo University', location: 'Giza', emoji: '🏛️', color: AppColors.violet),
  UniCardData(name: 'AUC', location: 'New Cairo', emoji: '🎓', color: AppColors.coral),
  UniCardData(name: 'Ain Shams', location: 'Cairo', emoji: '☀️', color: AppColors.amber),
  UniCardData(name: 'Alexandria Uni', location: 'Alexandria', emoji: '🌊', color: AppColors.mint),
  UniCardData(name: 'GUC', location: 'New Cairo', emoji: '🔬', color: AppColors.violet),
  UniCardData(name: 'Mansoura Uni', location: 'Mansoura', emoji: '⚕️', color: AppColors.coral),
];

const _delays = [
  Duration.zero,
  Duration(milliseconds: 400),
  Duration(milliseconds: 800),
  Duration(milliseconds: 200),
  Duration(milliseconds: 600),
  Duration(milliseconds: 1000),
];

const _durations = [
  Duration(milliseconds: 2800),
  Duration(milliseconds: 3200),
  Duration(milliseconds: 2600),
  Duration(milliseconds: 3000),
  Duration(milliseconds: 2900),
  Duration(milliseconds: 3100),
];

const _pulseDurations = [
  Duration(milliseconds: 1800),
  Duration(milliseconds: 2200),
  Duration(milliseconds: 1500),
  Duration(milliseconds: 2500),
  Duration(milliseconds: 1650),
  Duration(milliseconds: 2350),
];

const _pulseDelays = [
  Duration.zero,
  Duration(milliseconds: 300),
  Duration(milliseconds: 600),
  Duration(milliseconds: 150),
  Duration(milliseconds: 900),
  Duration(milliseconds: 450),
];

class UniCardGrid extends StatelessWidget {
  const UniCardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int row = 0; row < 3; row++) ...[
          Row(
            children: [
              Expanded(
                child: AnimatedUniCard(
                  data: previewUniversities[row * 2],
                  delay: _delays[row * 2],
                  duration: _durations[row * 2],
                  pulseDuration: _pulseDurations[row * 2],
                  pulseDelay: _pulseDelays[row * 2],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedUniCard(
                  data: previewUniversities[row * 2 + 1],
                  delay: _delays[row * 2 + 1],
                  duration: _durations[row * 2 + 1],
                  pulseDuration: _pulseDurations[row * 2 + 1],
                  pulseDelay: _pulseDelays[row * 2 + 1],
                ),
              ),
            ],
          ),
          if (row < 2) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class AnimatedUniCard extends StatefulWidget {
  final UniCardData data;
  final Duration duration;
  final Duration delay;
  final Duration pulseDuration;
  final Duration pulseDelay;

  const AnimatedUniCard({
    super.key,
    required this.data,
    required this.duration,
    required this.delay,
    required this.pulseDuration,
    required this.pulseDelay,
  });

  @override
  State<AnimatedUniCard> createState() => _AnimatedUniCardState();
}

class _AnimatedUniCardState extends State<AnimatedUniCard>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnim;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _floatController =
        AnimationController(vsync: this, duration: widget.duration);
    _floatAnim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _floatController.repeat(reverse: true);
    });

    _pulseController =
        AnimationController(vsync: this, duration: widget.pulseDuration);
    _pulseAnim = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    Future.delayed(widget.pulseDelay, () {
      if (mounted) _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _pulseController]),
      builder: (context, child) => Opacity(
        opacity: _pulseAnim.value,
        child: Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: child,
        ),
      ),
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: widget.data.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.data.color.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.data.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(widget.data.emoji,
                    style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.data.name,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.data.location,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
