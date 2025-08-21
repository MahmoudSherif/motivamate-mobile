import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notes_provider.dart';
import '../../widgets/space_background.dart';
import '../../theme/app_theme.dart';

class NotesTab extends StatefulWidget {
  const NotesTab({super.key});

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, _) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              // Search and Filter Bar
              GlassContainer(
                child: Column(
                  children: [
                    // Search Field
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search notes...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                                onPressed: () {
                                  _searchController.clear();
                                  notesProvider.setSearchQuery('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: notesProvider.setSearchQuery,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Category Filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryChip(
                            'All',
                            null,
                            notesProvider.selectedCategory == null,
                            () => notesProvider.setSelectedCategory(null),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          ...NoteCategory.values.map((category) => Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: _buildCategoryChip(
                              NotesProvider.getLabelForCategory(category),
                              category,
                              notesProvider.selectedCategory == category,
                              () => notesProvider.setSelectedCategory(category),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Add Note Button
              GlassContainer(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddNoteDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Note'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.all(AppSpacing.md),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Notes Grid
              Expanded(
                child: notesProvider.notes.isNotEmpty
                    ? _buildNotesGrid(notesProvider)
                    : _buildEmptyState(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String label, NoteCategory? category, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.glassPrimary,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category != null) ...[
              Icon(
                NotesProvider.getIconForCategory(category),
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesGrid(NotesProvider notesProvider) {
    final notes = notesProvider.notes;
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.8,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteCard(note, notesProvider);
      },
    );
  }

  Widget _buildNoteCard(Note note, NotesProvider notesProvider) {
    return GestureDetector(
      onTap: () => _showNoteDetailDialog(context, note),
      child: Container(
        decoration: BoxDecoration(
          color: note.color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          border: Border.all(
            color: note.color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          child: Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      note.color.withOpacity(0.1),
                      note.color.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          NotesProvider.getIconForCategory(note.category),
                          size: 16,
                          color: note.color,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        if (note.isPinned)
                          Icon(
                            Icons.push_pin,
                            size: 16,
                            color: note.color,
                          ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          color: AppColors.glassPrimary,
                          onSelected: (value) async {
                            switch (value) {
                              case 'edit':
                                _showEditNoteDialog(context, note);
                                break;
                              case 'pin':
                                await notesProvider.togglePinNote(note.id);
                                break;
                              case 'delete':
                                _showDeleteNoteDialog(context, note, notesProvider);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit, size: 16, color: AppColors.textPrimary),
                                  const SizedBox(width: AppSpacing.sm),
                                  const Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'pin',
                              child: Row(
                                children: [
                                  Icon(
                                    note.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                                    size: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    note.isPinned ? 'Unpin' : 'Pin',
                                    style: const TextStyle(color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete, size: 16, color: AppColors.error),
                                  const SizedBox(width: AppSpacing.sm),
                                  const Text('Delete', style: TextStyle(color: AppColors.error)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Title
                    Text(
                      note.title.isEmpty ? 'Untitled' : note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Content Preview
                    Expanded(
                      child: Text(
                        note.preview,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Tags
                    if (note.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: note.tags.take(3).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: note.color.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '#$tag',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: note.color,
                              fontSize: 10,
                            ),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    
                    // Date
                    Text(
                      _formatDate(note.updatedAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GlassContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.note_add,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No Notes Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create your first note to capture your thoughts and ideas!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    _showNoteDialog(context, null);
  }

  void _showEditNoteDialog(BuildContext context, Note note) {
    _showNoteDialog(context, note);
  }

  void _showNoteDialog(BuildContext context, Note? note) {
    final isEditing = note != null;
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    final tagsController = TextEditingController(text: note?.tags.join(', ') ?? '');
    
    NoteCategory selectedCategory = note?.category ?? NoteCategory.personal;
    Color selectedColor = note?.color ?? NotesProvider.noteColors[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.glassPrimary,
          title: Text(
            isEditing ? 'Edit Note' : 'Add Note',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter note title',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Write your note here...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 8,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                    hintText: 'study, important, project',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<NoteCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  dropdownColor: AppColors.glassPrimary,
                  items: NoteCategory.values
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Icon(
                                  NotesProvider.getIconForCategory(category),
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  NotesProvider.getLabelForCategory(category),
                                  style: const TextStyle(color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Color Selection
                Text(
                  'Note Color',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: NotesProvider.noteColors.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.black, size: 16)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final notesProvider = Provider.of<NotesProvider>(context, listen: false);
                
                final tags = tagsController.text
                    .split(',')
                    .map((tag) => tag.trim())
                    .where((tag) => tag.isNotEmpty)
                    .toList();
                
                bool success;
                if (isEditing) {
                  success = await notesProvider.updateNote(
                    note!.id,
                    title: titleController.text,
                    content: contentController.text,
                    category: selectedCategory,
                    tags: tags,
                    color: selectedColor,
                  );
                } else {
                  success = await notesProvider.addNote(
                    title: titleController.text,
                    content: contentController.text,
                    category: selectedCategory,
                    tags: tags,
                    color: selectedColor,
                  );
                }
                
                Navigator.of(context).pop();
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'Note updated successfully!' : 'Note added successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteDetailDialog(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.glassPrimary,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: note.color.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppBorderRadius.lg),
                    topRight: Radius.circular(AppBorderRadius.lg),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      NotesProvider.getIconForCategory(note.category),
                      color: note.color,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        note.title.isEmpty ? 'Untitled' : note.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (note.isPinned)
                      Icon(
                        Icons.push_pin,
                        color: note.color,
                        size: 20,
                      ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Content
                        Text(
                          note.content.isEmpty ? 'No content' : note.content,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.lg),
                        
                        // Tags
                        if (note.tags.isNotEmpty) ...[
                          Text(
                            'Tags',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: note.tags.map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: note.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                              ),
                              child: Text(
                                '#$tag',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: note.color,
                                ),
                              ),
                            )).toList(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        
                        // Metadata
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.glassPrimary,
                            borderRadius: BorderRadius.circular(AppBorderRadius.md),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.create, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Created: ${_formatDate(note.createdAt)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                children: [
                                  const Icon(Icons.update, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Updated: ${_formatDate(note.updatedAt)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Actions
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showEditNoteDialog(context, note);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final notesProvider = Provider.of<NotesProvider>(context, listen: false);
                        await notesProvider.togglePinNote(note.id);
                      },
                      icon: Icon(note.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
                      label: Text(note.isPinned ? 'Unpin' : 'Pin'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showDeleteNoteDialog(context, note, Provider.of<NotesProvider>(context, listen: false));
                      },
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      label: const Text('Delete', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteNoteDialog(BuildContext context, Note note, NotesProvider notesProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassPrimary,
        title: const Text(
          'Delete Note',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${note.title.isEmpty ? 'Untitled' : note.title}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await notesProvider.deleteNote(note.id);
              Navigator.of(context).pop();
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Note deleted successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}