// lib/pages/aluno/aluno_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Para formatar a data

class AlunoDashboardPage extends StatefulWidget {
  const AlunoDashboardPage({super.key});

  @override
  State<AlunoDashboardPage> createState() => _AlunoDashboardPageState();
}

class _AlunoDashboardPageState extends State<AlunoDashboardPage> {
  final _supabase = Supabase.instance.client;
  String? _currentAlunoName; // Nome do aluno logado
  List<Map<String, dynamic>> _todasAsAulas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlunoDataAndAllAulas();
  }

  Future<void> _loadAlunoDataAndAllAulas() async {
    setState(() {
      _isLoading = true;
    });

    final User? currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      // Se não há usuário logado, redireciona para o login
      if (mounted) Navigator.of(context).pushReplacementNamed('/');
      return;
    }

    try {
      // 1. Buscar o perfil do usuário logado para obter o nome (e a role, para verificar)
      final profile = await _supabase.from('profiles').select('nome_completo, role').eq('id', currentUser.id).single();
      _currentAlunoName = profile['nome_completo'];

      // 2. Buscar TODAS as aulas com detalhes de sala, professor e disciplina
      // UPDATED: Include 'disciplinas(nome)' in the select statement
      final List<dynamic> aulasData = await _supabase
          .from('aulas')
          .select('*, salas(numero, bloco), professores(nome), disciplinas(nome)') // Fetch discipline name
          .order('data_aula', ascending: true) // Ordena por data
          .order('horario', ascending: true); // E depois por horário

      setState(() {
        _todasAsAulas = List<Map<String, dynamic>>.from(aulasData);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados do aluno ou aulas: $e')),
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
        appBar: AppBar(title: const Text('Dashboard do Aluno')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${_currentAlunoName ?? 'Aluno'}!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _todasAsAulas.isEmpty
          ? Center(
              child: Text(
                'Nenhuma aula cadastrada no sistema.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _todasAsAulas.length,
              itemBuilder: (context, index) {
                final aula = _todasAsAulas[index];
                final sala = aula['salas'];
                final professor = aula['professores'];
                final disciplina = aula['disciplinas']; // ADDED: Get discipline object
                final DateTime aulaDate = DateTime.parse(aula['data_aula']);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      // MODIFIED: background opacity to 0.13
                      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.13),
                      child: Icon(Icons.class_, color: Theme.of(context).colorScheme.secondary), // Ícone de aula
                    ),
                    // UPDATED: Use disciplina['nome'] instead of aula['disciplina']
                    title: Text(
                      '${disciplina['nome']} - ${aula['horario']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Data: ${DateFormat('dd/MM/yyyy').format(aulaDate)}\n'
                      'Sala: ${sala['numero']} ${sala['bloco'] != null ? '(${sala['bloco']})' : ''}\n'
                      'Professor: ${professor['nome']}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}