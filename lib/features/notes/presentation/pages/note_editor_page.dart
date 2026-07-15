import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../planner/presentation/utils/schedule_color.dart';
import '../../../planner/presentation/widgets/schedule_color_picker.dart';
import '../../domain/entities/note_entity.dart';
import '../providers/note_provider.dart';
import '../widgets/note_delete_dialog.dart';
import '../widgets/note_editor_fields.dart';
import '../widgets/note_editor_link_row.dart';
import '../widgets/note_editor_tag_section.dart';

/// Full screen (not a sheet) since notes can run long. Auto-saves on any way
/// out — hardware back, swipe-back, or the app bar's back/save controls all
/// funnel through the single PopScope callback so content is never silently
/// discarded and never double-written.
class NoteEditorPage extends ConsumerStatefulWidget {
  final NoteEntity? existingNote;

  const NoteEditorPage({super.key, this.existingNote});

  @override
  ConsumerState<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage> {
  late final _titleController = TextEditingController(text: widget.existingNote?.title);
  late final _bodyController = TextEditingController(text: widget.existingNote?.body);
  late List<String> _tags = List.of(widget.existingNote?.tags ?? const []);
  late String _colorHex = widget.existingNote?.colorHex ?? plannerColorPalette[1];
  late String? _linkedTaskId;
  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    _linkedTaskId = widget.existingNote?.linkedTaskId;
  }

  bool get _isEditing => widget.existingNote != null;

  bool get _hasContent =>
      _titleController.text.trim().isNotEmpty || _bodyController.text.trim().isNotEmpty;

  // Single exit path for all routes out (done button, system back, swipe).
  // Pops immediately — Firebase offline cache commits locally before the
  // network round-trip, so content is persisted even before server confirms.
  void _handleExit() {
    if (_exiting) return;
    _exiting = true;

    // Capture before pop — controllers and ref may be disposed afterward.
    final hasContent = _hasContent;
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final tags = List<String>.of(_tags);
    final colorHex = _colorHex;
    final linkedTaskId = _linkedTaskId;
    final existingNote = widget.existingNote;
    final notifier = ref.read(noteActionsProvider.notifier);

    Navigator.of(context).pop();

    if (!hasContent) return;
    if (existingNote == null) {
      notifier.addNote(title: title, body: body, tags: tags, linkedTaskId: linkedTaskId, colorHex: colorHex);
    } else {
      notifier.updateNote(existingNote.copyWith(
        title: title,
        body: body,
        tags: tags,
        linkedTaskId: linkedTaskId,
        clearLinkedTaskId: linkedTaskId == null,
        colorHex: colorHex,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = _exiting;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleExit();
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.ink),
          title: Text(
            _isEditing ? 'Edit Note' : 'New Note',
            style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
          actions: [
            if (_isEditing)
              IconButton(
                onPressed: saving ? null : _delete,
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.coral),
              ),
            IconButton(
              key: const Key('noteEditorSaveButton'),
              onPressed: saving ? null : _handleExit,
              icon: const Icon(Icons.check_rounded, color: AppColors.violet),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: NoteEditorFields(titleController: _titleController, bodyController: _bodyController),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NoteEditorTagSection(tags: _tags, onChanged: (tags) => setState(() => _tags = tags)),
                  const SizedBox(height: 14),
                  ScheduleColorPicker(selectedHex: _colorHex, onChanged: (hex) => setState(() => _colorHex = hex)),
                  const SizedBox(height: 14),
                  NoteEditorLinkRow(
                    linkedTaskId: _linkedTaskId,
                    onChanged: (id) => setState(() => _linkedTaskId = id),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDeleteNoteDialog(context);
    if (!confirmed || !mounted) return;
    await ref.read(noteActionsProvider.notifier).deleteNote(widget.existingNote!.id);
    // Explicit pop bypasses PopScope's canPop:false guard (unlike
    // maybePop/system-back), so this doesn't re-trigger the auto-save path
    // and re-create the note we just deleted.
    if (mounted) Navigator.of(context).pop();
  }

}
