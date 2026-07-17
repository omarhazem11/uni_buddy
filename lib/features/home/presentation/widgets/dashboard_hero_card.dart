import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class DashboardHeroCard extends StatelessWidget {
  final String greeting;
  final String subtitle;
  final VoidCallback onViewTasks;
  final int overdueCount;

  const DashboardHeroCard({
    super.key,
    required this.greeting,
    required this.subtitle,
    required this.onViewTasks,
    this.overdueCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.violet,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            const Positioned.fill(child: _DecorativeCircles()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  if (overdueCount > 0) ...[
                    const SizedBox(height: 10),
                    _OverdueBanner(count: overdueCount),
                  ],
                  const SizedBox(height: 16),
                  _ViewTasksPill(
                    onTap: onViewTasks,
                    label: overdueCount > 0 ? 'View overdue →' : 'View tasks →',
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

class _ViewTasksPill extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const _ViewTasksPill({required this.onTap, this.label = 'View tasks →'});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _OverdueBanner extends StatelessWidget {
  final int count;
  const _OverdueBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.coral.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.coral.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            '$count task${count == 1 ? '' : 's'} past due',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeCircles extends StatelessWidget {
  const _DecorativeCircles();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: -30,
          top: -30,
          child: _circle(140),
        ),
        Positioned(
          right: 20,
          bottom: -40,
          child: _circle(100),
        ),
      ],
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
    );
  }
}
