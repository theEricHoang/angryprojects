import 'package:flutter/material.dart';

import '../models/card.dart';
import '../models/folder.dart';
import '../repositories/card_repository.dart';
import '../repositories/folder_repository.dart';

class AddEditCardScreen extends StatefulWidget {
  final int folderId;
  final String folderName;
  final PlayingCard? existingCard; // null = add mode, non-null = edit mode

  const AddEditCardScreen({
    super.key,
    required this.folderId,
    required this.folderName,
    this.existingCard,
  });

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final CardRepository _cardRepo = CardRepository();
  final FolderRepository _folderRepo = FolderRepository();

  late TextEditingController _nameController;
  late TextEditingController _imageUrlController;

  String _selectedSuit = 'Hearts';
  int _selectedFolderId = 0;
  List<Folder> _folders = [];
  bool _isLoading = false;

  bool get _isEditing => widget.existingCard != null;

  static const _suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.existingCard?.cardName ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.existingCard?.imageUrl ?? '',
    );
    _selectedSuit = widget.existingCard?.suit ?? 'Hearts';
    _selectedFolderId = widget.existingCard?.folderId ?? widget.folderId;

    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final folders = await _folderRepo.getAllFolders();
    setState(() {
      _folders = folders;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final imageUrl = _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim();

      if (_isEditing) {
        final updated = widget.existingCard!.copyWith(
          cardName: _nameController.text.trim(),
          suit: _selectedSuit,
          imageUrl: imageUrl,
          folderId: _selectedFolderId,
        );
        await _cardRepo.updateCard(updated);
      } else {
        final newCard = PlayingCard(
          cardName: _nameController.text.trim(),
          suit: _selectedSuit,
          imageUrl: imageUrl,
          folderId: _selectedFolderId,
        );
        await _cardRepo.insertCard(newCard);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Card updated successfully.'
                  : 'Card added successfully.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save card: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Card' : 'Add Card'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card name input
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Card Name',
                  hintText: 'e.g. Ace, King, 7',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.style),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a card name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Suit selection dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedSuit,
                decoration: const InputDecoration(
                  labelText: 'Suit',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _suits.map((suit) {
                  return DropdownMenuItem(value: suit, child: Text(suit));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedSuit = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Image URL input
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                  hintText: 'https://example.com/card.png',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              // Folder assignment dropdown
              DropdownButtonFormField<int>(
                initialValue: _folders.any((f) => f.id == _selectedFolderId)
                    ? _selectedFolderId
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Folder',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.folder),
                ),
                items: _folders.map((folder) {
                  return DropdownMenuItem(
                    value: folder.id,
                    child: Text(folder.folderName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedFolderId = value);
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a folder.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Image preview
              if (_imageUrlController.text.trim().startsWith('http'))
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _imageUrlController.text.trim(),
                      height: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey.shade200,
                        child: const Center(child: Text('Image not available')),
                      ),
                    ),
                  ),
                ),

              // Save and Cancel buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ? null : _saveCard,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_isEditing ? 'Update' : 'Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
