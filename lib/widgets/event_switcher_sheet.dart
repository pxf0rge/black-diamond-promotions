import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../models/event_model.dart';
import '../providers/event_provider.dart';
import '../theme/app_theme.dart';
import '../utils/event_scope.dart';
import '../utils/formatters.dart';
import 'custom_text_field.dart';
import 'primary_button.dart';

Future<void> showEventSwitcherSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) => const EventSwitcherSheet(),
  );
}

Future<bool?> showCreateEventDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => const CreateEventDialog(),
  );
}

class EventSwitcherSheet extends StatelessWidget {
  const EventSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        final events = eventProvider.events;
        final currentId = eventProvider.currentEvent?.id;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Events',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final created = await showCreateEventDialog(context);
                        if (created == true && context.mounted) {
                          await reloadEventScopedData(context);
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (events.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'No events yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: events.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final event = events[index];
                        final isCurrent = event.id == currentId;
                        return _EventListTile(
                          event: event,
                          isCurrent: isCurrent,
                          onTap: () async {
                            if (isCurrent) {
                              Navigator.pop(context);
                              return;
                            }
                            final ok = await eventProvider.switchEvent(
                              event.id,
                            );
                            if (!context.mounted) return;
                            if (ok) {
                              await reloadEventScopedData(context);
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EventListTile extends StatelessWidget {
  const _EventListTile({
    required this.event,
    required this.isCurrent,
    required this.onTap,
  });

  final EventModel event;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isCurrent
          ? AppColors.primary.withValues(alpha: 0.12)
          : AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                isCurrent ? Icons.check_circle : Icons.event_outlined,
                color: isCurrent ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        Formatters.date(event.date),
                        if (event.location.trim().isNotEmpty) event.location,
                      ].join(' · '),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateEventDialog extends StatefulWidget {
  const CreateEventDialog({super.key});

  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Event name is required')));
      return;
    }

    setState(() => _isCreating = true);
    final success = await context.read<EventProvider>().createEvent(
      name: name,
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _date,
    );
    if (!mounted) return;
    setState(() => _isCreating = false);
    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _nameController,
              labelText: 'Event Name',
              hintText: 'e.g. Summer Festival 2026',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _locationController,
              labelText: 'Location',
              hintText: 'Venue or city',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _descriptionController,
              labelText: 'Description',
              hintText: 'Optional notes',
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Event Date',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              subtitle: Text(
                Formatters.date(_date),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDate,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        PrimaryButton(
          label: 'Create',
          icon: Icons.check,
          isLoading: _isCreating,
          onPressed: _isCreating ? null : _submit,
        ),
      ],
    );
  }
}
