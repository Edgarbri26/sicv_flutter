import 'package:flutter/material.dart';
// 1. IMPORTA EL PAQUETE
import 'package:calendar_date_picker2/calendar_date_picker2.dart'; 

class DateFilterSelector extends StatelessWidget {
  final String selectedFilter;
  final DateTimeRange? selectedDateRange;
  final Function(String) onFilterChanged;
  final Function(DateTimeRange) onDateRangeChanged;

  const DateFilterSelector({
    super.key,
    required this.selectedFilter,
    required this.selectedDateRange,
    required this.onFilterChanged,
    required this.onDateRangeChanged,
  });

  static const Map<String, String> _labels = {
    'today': 'Hoy',
    'week': 'Esta Semana',
    'month': 'Este Mes',
    'year': 'Este Año',
    'custom': 'Personalizado',
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showFilterBottomSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 18, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                _getDisplayText(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down,
                  size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  String _getDisplayText() {
    if (selectedFilter == 'custom' && selectedDateRange != null) {
      return "${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}";
    }
    return _labels[selectedFilter] ?? selectedFilter;
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Seleccionar Periodo",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const Divider(),
              ..._labels.entries.map((entry) {
                final isSelected = entry.key == selectedFilter;
                return ListTile(
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  title: Text(
                    entry.value,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blue[800] : Colors.black87,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx); // Cerrar menú de opciones
                    if (entry.key == 'custom') {
                      // 2. AHORA ABRIMOS EL CALENDARIO EN OTRO BOTTOM SHEET
                      _showInlineCalendarSheet(context);
                    } else {
                      onFilterChanged(entry.key);
                    }
                  },
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // NUEVO: CALENDARIO EN BOTTOM SHEET (Estilo Airbnb)
  // -------------------------------------------------------------
  void _showInlineCalendarSheet(BuildContext context) {
    // Valores iniciales
    List<DateTime?> initDates = [];
    if (selectedDateRange != null) {
      initDates = [selectedDateRange!.start, selectedDateRange!.end];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Importante para que se vea bien la altura
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65, // Ocupa 65% pantalla
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Barra superior del modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Seleccionar Rango", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  )
                ],
              ),
              const Divider(),
              
              // EL CALENDARIO INCRUSTADO
              Expanded(
                child: CalendarDatePicker2WithActionButtons(
                  config: CalendarDatePicker2WithActionButtonsConfig(
                    calendarType: CalendarDatePicker2Type.range, // Modo Rango
                    selectedDayHighlightColor: Colors.blue,
                    closeDialogOnCancelTapped: true,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  ),
                  value: initDates,
                  onValueChanged: (dates) {
                    // Esto se actualiza mientras seleccionas
                    initDates = dates;
                  },
                  onCancelTapped: () => Navigator.pop(ctx),
                  onOkTapped: () {
                    if (initDates.length == 2 && initDates[0] != null && initDates[1] != null) {
                        // Ordenamos las fechas por si acaso
                        initDates.sort((a, b) => a!.compareTo(b!));
                        
                        final range = DateTimeRange(
                            start: initDates[0]!, 
                            end: initDates[1]!
                        );
                        
                        onDateRangeChanged(range);
                        Navigator.pop(ctx);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}