import 'package:arloop/bloc/store_owner/store_owner_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/shop/shop_bloc.dart';

class UpdateStatusDialog extends StatefulWidget {
  final bool currentStatus;

  const UpdateStatusDialog({super.key, required this.currentStatus});

  @override
  State<UpdateStatusDialog> createState() => _UpdateStatusDialogState();
}

class _UpdateStatusDialogState extends State<UpdateStatusDialog> {
  late bool _isOpen;
  String? _reason;
  final _reasonController = TextEditingController();

  final List<String> _closureReasons = [
    'Lunch break',
    'Medicine restock',
    'Technical issues',
    'Emergency',
    'Personal work',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _isOpen = widget.currentStatus;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _updateStatus() {
    if (!_isOpen && (_reason == null || _reason!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a reason for closing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Update shop status in bloc
    context.read<StoreOwnerBloc>().add(
      UpdateShopStatusEvent(
        operationalStatus: _isOpen ? 'open' : 'closed',
        statusMessage: _isOpen ? null : _reason ?? 'Closed',
      ),
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isOpen
              ? 'Shop is now open'
              : 'Shop is now closed${_reason != null ? ' - $_reason' : ''}',
        ),
        backgroundColor: _isOpen ? Colors.green : Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Shop Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isOpen ? Icons.store : Icons.store_mall_directory_outlined,
                color: _isOpen ? Colors.green : Colors.grey,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Status',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      widget.currentStatus ? 'Open' : 'Closed',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.currentStatus ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Text(
            'New Status',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Open'),
                  value: true,
                  groupValue: _isOpen,
                  onChanged: (value) {
                    setState(() {
                      _isOpen = value!;
                      _reason = null;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Closed'),
                  value: false,
                  groupValue: _isOpen,
                  onChanged: (value) {
                    setState(() {
                      _isOpen = value!;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),

          if (!_isOpen) ...[
            const SizedBox(height: 16),
            const Text(
              'Reason for closing',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select reason',
              ),
              value: _reason,
              items: _closureReasons.map((reason) {
                return DropdownMenuItem(value: reason, child: Text(reason));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _reason = value;
                });
              },
            ),

            if (_reason == 'Other') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter custom reason',
                ),
                onChanged: (value) {
                  _reason = value.isNotEmpty ? value : 'Other';
                },
              ),
            ],
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateStatus,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isOpen ? Colors.green : Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: Text(_isOpen ? 'Open Shop' : 'Close Shop'),
        ),
      ],
    );
  }
}
