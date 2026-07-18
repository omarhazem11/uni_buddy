import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

// Grouped by category so the user can quickly scan and find the right icon.
const _emojiGroups = <String, List<String>>{
  'Study': ['📚', '📖', '✏️', '💻', '📝', '📊', '📋', '🔬', '🖥️', '🗒️'],
  'Work': ['💼', '📌', '📎', '🖨️', '📧', '📞', '🤝', '🏢', '📑', '⏰'],
  'Food': ['☕', '🍵', '🍽️', '🥗', '🍕', '🥪', '🍎', '🧃', '🥤', '🍰'],
  'Fitness': ['🏃', '🏋️', '🧘', '🚴', '🏊', '⚽', '🎯', '💪', '🚶', '🧗'],
  'Rest': ['😴', '🛁', '🛒', '🏠', '💊', '🌿', '🎮', '📱', '🛏️', '🧹'],
  'Creative': ['🎨', '🎵', '🎸', '📷', '🎬', '✂️', '🖌️', '🎭', '📻', '🌍'],
};

// Flat list used for persistence — DO NOT reorder (existing items reference
// by value not index, but ordering here controls what the picker shows first).
const scheduleEmojiOptions = [
  '📚', '📖', '✏️', '💻', '📝', '📊', '📋', '🔬', '🖥️', '🗒️',
  '💼', '📌', '📎', '🖨️', '📧', '📞', '🤝', '🏢', '📑', '⏰',
  '☕', '🍵', '🍽️', '🥗', '🍕', '🥪', '🍎', '🧃', '🥤', '🍰',
  '🏃', '🏋️', '🧘', '🚴', '🏊', '⚽', '🎯', '💪', '🚶', '🧗',
  '😴', '🛁', '🛒', '🏠', '💊', '🌿', '🎮', '📱', '🛏️', '🧹',
  '🎨', '🎵', '🎸', '📷', '🎬', '✂️', '🖌️', '🎭', '📻', '🌍',
];

class ScheduleEmojiPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const ScheduleEmojiPicker({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in _emojiGroups.entries) ...[
          _GroupRow(groupName: entry.key, emojis: entry.value, selected: selected, onChanged: onChanged),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _GroupRow extends StatelessWidget {
  final String groupName;
  final List<String> emojis;
  final String selected;
  final ValueChanged<String> onChanged;

  const _GroupRow({
    required this.groupName,
    required this.emojis,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            groupName,
            style: const TextStyle(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: emojis.length,
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                final emoji = emojis[index];
                final isSelected = emoji == selected;
                return GestureDetector(
                  onTap: () => onChanged(emoji),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.violet.withValues(alpha: 0.12) : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: AppColors.violet, width: 2) : null,
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 18)),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
