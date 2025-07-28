import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/shop/shop_bloc.dart';

class AddAnnouncementDialog extends StatefulWidget {
  const AddAnnouncementDialog({super.key});

  @override
  State<AddAnnouncementDialog> createState() => _AddAnnouncementDialogState();
}

class _AddAnnouncementDialogState extends State<AddAnnouncementDialog> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedType = 'info';
  bool _isActive = true;

  final List<Map<String, dynamic>> _types = [
    {'value': 'info', 'label': 'Information', 'color': Colors.blue},
    {'value': 'warning', 'label': 'Warning', 'color': Colors.orange},
    {'value': 'urgent', 'label': 'Urgent', 'color': Colors.red},
    {'value': 'promotion', 'label': 'Promotion', 'color': Colors.green},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _addAnnouncement() {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create new announcement
    final announcement = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': _titleController.text,
      'message': _messageController.text,
      'type': _selectedType,
      'isActive': _isActive,
      'createdAt': DateTime.now(),
    };

    // Add to bloc
    context.read<ShopBloc>().add(AddAnnouncementEvent(
      title: _titleController.text,
      message: _messageController.text,
    ));

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Announcement added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Announcement'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                hintText: 'Enter announcement title',
              ),
              maxLength: 50,
            ),
            const SizedBox(height: 16),

            const Text(
              'Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _types.map((type) {
                final isSelected = type['value'] == _selectedType;
                return FilterChip(
                  label: Text(type['label']),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedType = type['value'];
                      });
                    }
                  },
                  backgroundColor: Colors.white,
                  selectedColor: (type['color'] as Color).withOpacity(0.2),
                  checkmarkColor: type['color'],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
                hintText: 'Enter announcement message',
              ),
              maxLines: 4,
              maxLength: 200,
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Active'),
              subtitle: const Text('Show this announcement to customers'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _addAnnouncement, child: const Text('Add')),
      ],
    );
  }
}
