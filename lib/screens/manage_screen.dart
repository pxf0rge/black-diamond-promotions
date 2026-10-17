import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../models/event_model.dart';
import '../providers/catalog_provider.dart';
import '../providers/event_provider.dart';
import '../theme/app_theme.dart';
import '../utils/event_scope.dart';
import '../utils/formatters.dart';
import '../widgets/app_header.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/event_switcher_sheet.dart';
import '../widgets/manage_category_card.dart';
import '../widgets/primary_button.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  final _categoryController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _syncedEventId;
  DateTime _newEventDate = DateTime.now();
  bool _isCreatingEvent = false;

  Future<void> _createFirstEvent(EventProvider eventProvider) async {
    final name = _eventNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Event name is required')));
      return;
    }

    setState(() => _isCreatingEvent = true);
    final success = await eventProvider.createEvent(
      name: name,
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _newEventDate,
    );
    if (!mounted) return;
    setState(() => _isCreatingEvent = false);

    if (success) {
      await context.read<CatalogProvider>().reloadForManage();
    }
  }

  Future<void> _createAdditionalEvent() async {
    final created = await showCreateEventDialog(context);
    if (created == true && mounted) {
      await reloadEventScopedData(context);
    }
  }

  Future<void> _switchToEvent(String eventId) async {
    final eventProvider = context.read<EventProvider>();
    if (eventProvider.currentEvent?.id == eventId) return;
    final ok = await eventProvider.switchEvent(eventId);
    if (!mounted || !ok) return;
    _syncedEventId = null;
    await reloadEventScopedData(context);
  }

  Future<void> _deleteEvent(EventModel event) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Delete Event',
      message:
          'Delete "${event.name}"? Categories and products for this event will remain in storage but the event will be removed.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    final ok = await context.read<EventProvider>().deleteEvent(event.id);
    if (!mounted || !ok) return;
    _syncedEventId = null;
    await reloadEventScopedData(context);
  }

  Future<void> _pickNewEventDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _newEventDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _newEventDate = picked);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().reloadForManage();
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _eventNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _syncControllers(EventProvider eventProvider) {
    final event = eventProvider.currentEvent;
    if (event == null || event.id == _syncedEventId) return;
    _syncedEventId = event.id;
    _eventNameController.text = event.name;
    _locationController.text = event.location;
    _descriptionController.text = event.description;
  }

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.sizeOf(context).width >= AppConstants.tabletBreakpoint;

    return Scaffold(
      appBar: const AppHeader(),
      body: Consumer2<EventProvider, CatalogProvider>(
        builder: (context, eventProvider, catalog, _) {
          _syncControllers(eventProvider);
          final event = eventProvider.currentEvent;

          if (event == null) {
            return _buildFirstEventSetup(eventProvider);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(isWide ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eventProvider.errorMessage != null)
                  _ErrorBanner(message: eventProvider.errorMessage!),
                if (catalog.errorMessage != null)
                  _ErrorBanner(message: catalog.errorMessage!),
                _buildEventsList(eventProvider),
                const SizedBox(height: 20),
                _buildEventSection(eventProvider, isWide),
                const SizedBox(height: 28),
                const Text(
                  'Add Category',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _categoryController,
                        hintText: 'New category name...',
                        onSubmitted: (_) => _addCategory(catalog),
                      ),
                    ),
                    const SizedBox(width: 10),
                    PrimaryButton(
                      label: 'Add',
                      icon: Icons.add,
                      onPressed: () => _addCategory(catalog),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...catalog.categories.map(
                  (category) => ManageCategoryCard(
                    category: category,
                    onToggle: () => catalog.toggleCategory(category.id),
                    onDelete: () => catalog.deleteCategory(category.id),
                    onRename: (name) =>
                        catalog.renameCategory(category.id, name),
                    onDeleteProduct: (productId) =>
                        catalog.deleteProduct(category.id, productId),
                    onEditProduct: (productId, name, price) => catalog
                        .updateProduct(category.id, productId, name, price),
                    onAddProduct: (name, price) =>
                        catalog.addProduct(category.id, name, price),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _addCategory(CatalogProvider catalog) async {
    final name = _categoryController.text.trim();
    if (name.isEmpty) return;
    await catalog.addCategory(name);
    _categoryController.clear();
  }

  Widget _buildEventsList(EventProvider eventProvider) {
    final events = eventProvider.events;
    final currentId = eventProvider.currentEvent?.id;

    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Your Events',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              PrimaryButton(
                label: 'New Event',
                icon: Icons.add,
                onPressed: _createAdditionalEvent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Select an event to manage its catalog and sales.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ...events.map((event) {
            final isCurrent = event.id == currentId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: isCurrent
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                child: InkWell(
                  onTap: () => _switchToEvent(event.id),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCurrent
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isCurrent
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isCurrent
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                [
                                  Formatters.date(event.date),
                                  if (event.location.trim().isNotEmpty)
                                    event.location,
                                ].join(' · '),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isCurrent)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                            ),
                          ),
                        IconButton(
                          tooltip: 'Delete event',
                          onPressed: events.length <= 1
                              ? null
                              : () => _deleteEvent(event),
                          icon: Icon(
                            Icons.delete_outline,
                            color: events.length <= 1
                                ? AppColors.textSecondary.withValues(
                                    alpha: 0.3,
                                  )
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFirstEventSetup(EventProvider eventProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.event_outlined,
                size: 64,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Create Your First Event',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'No event has been set up yet. Enter event details to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              if (eventProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ErrorBanner(message: eventProvider.errorMessage!),
                ),
              CustomTextField(
                controller: _eventNameController,
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
                hintText: 'Optional notes about this event',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Event Date',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                subtitle: Text(
                  Formatters.date(_newEventDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _pickNewEventDate,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Create Event',
                icon: Icons.check,
                expand: true,
                isLoading: _isCreatingEvent,
                onPressed: _isCreatingEvent
                    ? null
                    : () => _createFirstEvent(eventProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventSection(EventProvider eventProvider, bool isWide) {
    final event = eventProvider.currentEvent!;

    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Edit details for the active event',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (isWide)
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _eventNameController,
                    labelText: 'Event Name',
                    onChanged: (v) => eventProvider.updateLocal(name: v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _locationController,
                    labelText: 'Location',
                    onChanged: (v) => eventProvider.updateLocal(location: v),
                  ),
                ),
              ],
            )
          else ...[
            CustomTextField(
              controller: _eventNameController,
              labelText: 'Event Name',
              onChanged: (v) => eventProvider.updateLocal(name: v),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _locationController,
              labelText: 'Location',
              onChanged: (v) => eventProvider.updateLocal(location: v),
            ),
          ],
          const SizedBox(height: 12),
          _DateField(
            date: event.date,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: event.date,
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: AppColors.primary,
                        surface: AppColors.card,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) eventProvider.updateLocal(date: date);
            },
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _descriptionController,
            labelText: 'Description',
            maxLines: 3,
            onChanged: (v) => eventProvider.updateLocal(description: v),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: AppConstants.shortAnimation,
            child: eventProvider.saveSuccess
                ? Container(
                    key: const ValueKey('success'),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success),
                        SizedBox(width: 8),
                        Text(
                          'Event saved successfully',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : PrimaryButton(
                    key: const ValueKey('save'),
                    label: 'Save Event',
                    icon: Icons.save_outlined,
                    expand: true,
                    isLoading: eventProvider.isSaving,
                    onPressed: eventProvider.saveEvent,
                  ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: CustomTextField(
          controller: TextEditingController(text: Formatters.date(date)),
          labelText: 'Date',
          readOnly: true,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Text(message, style: const TextStyle(color: AppColors.primary)),
    );
  }
}
