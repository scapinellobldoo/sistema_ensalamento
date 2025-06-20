// lib/pages/admin/aulas/aula_form_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AulaFormPage extends StatefulWidget {
  final Map<String, dynamic>? aula;
  final DateTime selectedDate;

  const AulaFormPage({super.key, this.aula, required this.selectedDate});

  @override
  State<AulaFormPage> createState() => _AulaFormPageState();
}

class _AulaFormPageState extends State<AulaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  List<Map<String, dynamic>> _salas = [];
  List<Map<String, dynamic>> _professores = [];
  List<Map<String, dynamic>> _disciplinas = [];
  String? _selectedSalaId;
  String? _selectedProfessorId;
  String? _selectedDisciplinaId;
  String? _selectedHorario;

  final List<String> _horarios = [
    '1º Horário (19:00)',
    '2º Horário (20:50)',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.aula != null) {
      _selectedDisciplinaId = widget.aula!['id_disciplina']?.toString();
      _selectedSalaId = widget.aula!['id_sala']?.toString();
      _selectedProfessorId = widget.aula!['id_professor']?.toString();
      _selectedHorario = widget.aula!['horario']?.toString();
    }
    _fetchDependencies();
  }

  Future<void> _fetchDependencies() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final List<dynamic> salasData = await _supabase.from('salas').select('id::text, numero, bloco').order('numero', ascending: true);
      final List<dynamic> professoresData = await _supabase.from('professores').select('id::text, nome').order('nome', ascending: true);
      final List<dynamic> disciplinasData = await _supabase.from('disciplinas').select('id::text, nome').order('nome', ascending: true);

      setState(() {
        _salas = List<Map<String, dynamic>>.from(salasData);
        _professores = List<Map<String, dynamic>>.from(professoresData);
        _disciplinas = List<Map<String, dynamic>>.from(disciplinasData);

        if (_selectedSalaId != null && !_salas.any((s) => s['id'] == _selectedSalaId)) {
          _selectedSalaId = null;
        }
        if (_selectedProfessorId != null && !_professores.any((p) => p['id'] == _selectedProfessorId)) {
          _selectedProfessorId = null;
        }
        if (_selectedDisciplinaId != null && !_disciplinas.any((d) => d['id'] == _selectedDisciplinaId)) {
          _selectedDisciplinaId = null;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados de suporte (salas/professores/disciplinas): $e', style: const TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
            backgroundColor: Colors.red, // MODIFICADO: Fundo vermelho para erro
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveAula() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedSalaId == null || _selectedProfessorId == null || _selectedHorario == null || _selectedDisciplinaId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, preencha todos os campos obrigatórios.', style: TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
            backgroundColor: Colors.red, // MODIFICADO: Fundo vermelho para erro
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final newAula = {
      'data_aula': DateFormat('yyyy-MM-dd').format(widget.selectedDate),
      'horario': _selectedHorario,
      'id_disciplina': _selectedDisciplinaId,
      'id_sala': _selectedSalaId,
      'id_professor': _selectedProfessorId,
    };

    try {
      final existingAulasForDayAndHorario = await _supabase
          .from('aulas')
          .select('id, id_sala, id_professor')
          .eq('data_aula', newAula['data_aula'] as String)
          .eq('horario', newAula['horario'] as String);

      bool conflict = false;
      String conflictMessage = '';

      for (var aula in existingAulasForDayAndHorario) {
        if (widget.aula != null && aula['id'] == widget.aula!['id']) {
          continue;
        }

        if (aula['id_sala'].toString() == newAula['id_sala']!.toString()) {
          conflict = true;
          conflictMessage = 'Conflito: Esta sala já está ocupada neste horário e dia por outra aula.';
          break;
        }
        if (aula['id_professor'].toString() == newAula['id_professor']!.toString()) {
          conflict = true;
          conflictMessage = 'Conflito: Este professor já tem uma aula agendada neste horário e dia.';
          break;
        }
      }

      if (conflict) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(conflictMessage, style: const TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
              backgroundColor: Colors.red, // MODIFICADO: Fundo vermelho para erro
            ),
          );
        }
        setState(() { _isLoading = false; });
        return;
      }

      if (widget.aula == null) {
        await _supabase.from('aulas').insert(newAula);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aula cadastrada com sucesso!', style: TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
              backgroundColor: Colors.green, // MODIFICADO: Fundo verde para sucesso
            ),
          );
        }
      } else {
        await _supabase.from('aulas').update(newAula).eq('id', widget.aula!['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aula atualizada com sucesso!', style: TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
              backgroundColor: Colors.green, // MODIFICADO: Fundo verde para sucesso
            ),
          );
        }
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar aula: ${e.message}', style: const TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
            backgroundColor: Colors.red, // MODIFICADO: Fundo vermelho para erro
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado ao salvar aula: $e', style: const TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
            backgroundColor: Colors.red, // MODIFICADO: Fundo vermelho para erro
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.aula == null ? 'Nova Aula' : 'Editar Aula'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data da Aula: ${DateFormat('dd/MM/yyyy').format(widget.selectedDate)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Disciplina',
                        prefixIcon: Icon(Icons.school),
                      ),
                      value: _selectedDisciplinaId,
                      items: _disciplinas.map<DropdownMenuItem<String>>((disciplina) {
                        return DropdownMenuItem<String>(
                          value: disciplina['id'] as String,
                          child: Text(disciplina['nome']),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedDisciplinaId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, selecione uma disciplina.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Horário',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      value: _selectedHorario,
                      items: _horarios.map<DropdownMenuItem<String>>((horario) {
                        return DropdownMenuItem<String>(
                          value: horario,
                          child: Text(horario),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedHorario = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, selecione o horário.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Sala',
                        prefixIcon: Icon(Icons.meeting_room),
                      ),
                      value: _selectedSalaId,
                      items: _salas.map<DropdownMenuItem<String>>((sala) {
                        return DropdownMenuItem<String>(
                          value: sala['id'] as String,
                          child: Text('Sala ${sala['numero']} ${sala['bloco'] != null ? '(${sala['bloco']})' : ''}'),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedSalaId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, selecione uma sala.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Professor',
                        prefixIcon: Icon(Icons.person),
                      ),
                      value: _selectedProfessorId,
                      items: _professores.map<DropdownMenuItem<String>>((professor) {
                        return DropdownMenuItem<String>(
                          value: professor['id'] as String,
                          child: Text(professor['nome']),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedProfessorId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, selecione um professor.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveAula,
                        child: Text(widget.aula == null ? 'Cadastrar Aula' : 'Salvar Alterações'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}