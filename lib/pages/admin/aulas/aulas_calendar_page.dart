// lib/pages/admin/aulas/aulas_calendar_page.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sistema_ensalamento/pages/admin/aulas/aula_form_page.dart';

class AulasCalendarPage extends StatefulWidget {
  const AulasCalendarPage({super.key});

  @override
  State<AulasCalendarPage> createState() => _AulasCalendarPageState();
}

class _AulasCalendarPageState extends State<AulasCalendarPage> {
  final _supabase = Supabase.instance.client;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<dynamic>> _events = {};
  List<dynamic> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchAndOrganizeAulas();
  }

  Future<void> _fetchAndOrganizeAulas() async {
    try {
      final List<dynamic> data = await _supabase
          .from('aulas')
          .select('*, salas(numero, bloco), professores(nome), disciplinas(nome)');

      final Map<DateTime, List<dynamic>> newEvents = {};
      for (var aula in data) {
        final DateTime aulaDate = DateTime.parse(aula['data_aula']);
        final normalizedDate = DateTime.utc(aulaDate.year, aulaDate.month, aulaDate.day);

        if (newEvents[normalizedDate] == null) {
          newEvents[normalizedDate] = [];
        }
        newEvents[normalizedDate]!.add(aula);
      }

      setState(() {
        _events = newEvents;
        _selectedEvents = _getEventsForDay(_selectedDay);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar aulas: $e', style: const TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
            backgroundColor: Colors.red, // MODIFICADO: Fundo vermelho para erro
          ),
        );
      }
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents = _getEventsForDay(selectedDay);
      });
    }
  }

  Future<void> _deleteAula(String id) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja excluir esta aula?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await _supabase.from('aulas').delete().eq('id', id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aula excluída com sucesso!', style: TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
              backgroundColor: Colors.green, // MODIFICADO: Fundo verde para sucesso
            ),
          );
        }
        _fetchAndOrganizeAulas();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir aula: $e', style: const TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
              backgroundColor: Colors.red, // MODIFICADO: Fundo vermelho para erro
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: _getEventsForDay,
              locale: 'pt_BR',
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.primary),
                rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.13),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.13),
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(color: Colors.grey.shade800),
                weekendTextStyle: TextStyle(color: Colors.red.shade600),
                holidayTextStyle: TextStyle(color: Colors.red.shade600),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                weekendStyle: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: _selectedEvents.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma aula agendada para este dia.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      final aula = _selectedEvents[index];
                      final sala = aula['salas'];
                      final professor = aula['professores'];
                      final disciplina = aula['disciplinas'];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          title: Text('${disciplina['nome']} - ${aula['horario']}'),
                          subtitle: Text(
                            'Sala: ${sala['numero']} ${sala['bloco'] != null ? '(${sala['bloco']})' : ''}\n'
                            'Professor: ${professor['nome']}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                                onPressed: () async {
                                  final result = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AulaFormPage(aula: aula, selectedDate: _selectedDay),
                                    ),
                                  );
                                  if (result == true) {
                                    _fetchAndOrganizeAulas();
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                                onPressed: () => _deleteAula(aula['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AulaFormPage(selectedDate: _selectedDay),
            ),
          );
          if (result == true) {
            _fetchAndOrganizeAulas();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}