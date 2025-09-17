import 'package:flutter/material.dart';
import '../../../../data/models/service.dart';

class ServicePreferencesSelector extends StatefulWidget {
  final List<Service> selectedServices;
  final Function(List<Service>) onServicesChanged;

  const ServicePreferencesSelector({
    super.key,
    required this.selectedServices,
    required this.onServicesChanged,
  });

  @override
  State<ServicePreferencesSelector> createState() => _ServicePreferencesSelectorState();
}

class _ServicePreferencesSelectorState extends State<ServicePreferencesSelector> {
  List<Service> _selectedServices = [];

  @override
  void initState() {
    super.initState();
    _selectedServices = List.from(widget.selectedServices);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Предпочитаемые услуги',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'В новой архитектуре услуги привязаны к мастерам.\nВыбор предпочтений временно недоступен.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.onServicesChanged(_selectedServices);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
