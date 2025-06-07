import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:comaslimpio/features/auth/presentation/providers/register_form_provider.dart';

class Step3Notifications extends StatelessWidget {
  final Function(bool) onUpdateDaytimeAlerts;
  final Function(bool) onUpdateNighttimeAlerts;
  final Function(String) onUpdateDaytimeStart;
  final Function(String) onUpdateDaytimeEnd;
  final Function(String) onUpdateNighttimeStart;
  final Function(String) onUpdateNighttimeEnd;
  final RegisterFormState formState;

  const Step3Notifications({
    super.key,
    required this.onUpdateDaytimeAlerts,
    required this.onUpdateNighttimeAlerts,
    required this.onUpdateDaytimeStart,
    required this.onUpdateDaytimeEnd,
    required this.onUpdateNighttimeStart,
    required this.onUpdateNighttimeEnd,
    required this.formState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text(
            'Alertas Diurnas',
            style: TextStyle(
              color: Color(0xFF0C3751),
              fontWeight: FontWeight.w600,
            ),
          ),
          value: formState.daytimeAlerts,
          onChanged: onUpdateDaytimeAlerts,
          activeColor: AppTheme.primary,
        ),
        if (formState.daytimeAlerts) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputLabel('Inicio Diurno'),
                    const SizedBox(height: 4),
                    TextFormField(
                      initialValue: formState.daytimeStart,
                      decoration: _inputDecoration(hint: '06:00'),
                      onChanged: onUpdateDaytimeStart,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputLabel('Fin Diurno'),
                    const SizedBox(height: 4),
                    TextFormField(
                      initialValue: formState.daytimeEnd,
                      decoration: _inputDecoration(hint: '20:00'),
                      onChanged: onUpdateDaytimeEnd,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        SwitchListTile(
          title: const Text(
            'Alertas Nocturnas',
            style: TextStyle(
              color: Color(0xFF0C3751),
              fontWeight: FontWeight.w600,
            ),
          ),
          value: formState.nighttimeAlerts,
          onChanged: onUpdateNighttimeAlerts,
          activeColor: AppTheme.primary,
        ),
        if (formState.nighttimeAlerts) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputLabel('Inicio Nocturno'),
                    const SizedBox(height: 4),
                    TextFormField(
                      initialValue: formState.nighttimeStart,
                      decoration: _inputDecoration(hint: '20:00'),
                      onChanged: onUpdateNighttimeStart,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputLabel('Fin Nocturno'),
                    const SizedBox(height: 4),
                    TextFormField(
                      initialValue: formState.nighttimeEnd,
                      decoration: _inputDecoration(hint: '06:00'),
                      onChanged: onUpdateNighttimeEnd,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _inputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0C3751),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
