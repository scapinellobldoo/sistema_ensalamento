// lib/pages/professor/professor_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Para formatar a data

class ProfessorDashboardPage extends StatefulWidget {
  const ProfessorDashboardPage({super.key});

  @override
  State<ProfessorDashboardPage> createState() => _ProfessorDashboardPageState();
}

class _ProfessorDashboardPageState extends State<ProfessorDashboardPage> {
  final _supabase = Supabase.instance.client;
  String? _currentProfessorId; // ID do professor logado
  String? _currentProfessorName; // Nome do professor logado
  List<Map<String, dynamic>> _aulasDoProfessor = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfessorDataAndAulas();
  }

  Future<void> _loadProfessorDataAndAulas() async {
    setState(() {
      _isLoading = true;
    });

    final User? currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      if (mounted) Navigator.of(context).pushReplacementNamed('/');
      return;
    }

    try {
      final profile = await _supabase.from('profiles').select('nome_completo, role').eq('id', currentUser.id).single();
      _currentProfessorName = profile['nome_completo'];

      // BUSCA O PROFESSOR PELO EMAIL DO USUÁRIO LOGADO
      final professorMatch = await _supabase.from('professores').select('id').eq('email', currentUser.email!).single();
      _currentProfessorId = professorMatch['id']?.toString();

      if (_currentProfessorId == null) {
        throw Exception('Professor não encontrado para o usuário logado com este email.');
      }

      // UPDATED: Include 'disciplinas(nome)' in the select statement
      final List<dynamic> aulasData = await _supabase
          .from('aulas')
          .select('*, salas(numero, bloco), professores(nome), disciplinas(nome)') // Fetch discipline name
          .eq('id_professor', _currentProfessorId!)
          .order('data_aula', ascending: true)
          .order('horario', ascending: true);

      setState(() {
        _aulasDoProfessor = List<Map<String, dynamic>>.from(aulasData);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados do professor ou aulas: $e')),
        );
      }
      // Considerar um tratamento mais robusto para este erro em produção.
      // Por exemplo, redirecionar para uma tela de erro ou de reconfiguração de perfil.
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    await _supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard do Professor')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${_currentProfessorName ?? 'Professor'}!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _aulasDoProfessor.isEmpty
          ? Center(
              child: Text(
                'Nenhuma aula agendada para você.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _aulasDoProfessor.length,
              itemBuilder: (context, index) {
                final aula = _aulasDoProfessor[index];
                final sala = aula['salas'];
                final disciplina = aula['disciplinas']; // ADDED: Get discipline object

                final DateTime aulaDate = DateTime.parse(aula['data_aula']);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      // MODIFIED: background opacity to 0.13
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.13),
                      child: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                    ),
                    // UPDATED: Use disciplina['nome'] instead of aula['disciplina']
                    title: Text(
                      '${disciplina['nome']} - ${aula['horario']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Data: ${DateFormat('dd/MM/yyyy').format(aulaDate)}\n'
                      'Sala: ${sala['numero']} ${sala['bloco'] != null ? '(${sala['bloco']})' : ''}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}