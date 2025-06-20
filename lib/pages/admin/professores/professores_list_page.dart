// lib/pages/admin/professores/professores_list_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sistema_ensalamento/pages/admin/professores/professor_form_page.dart';

class ProfessoresListPage extends StatefulWidget {
  const ProfessoresListPage({super.key});

  @override
  State<ProfessoresListPage> createState() => _ProfessoresListPageState();
}

class _ProfessoresListPageState extends State<ProfessoresListPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _professores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfessores();
  }

  Future<void> _fetchProfessores() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _supabase.from('professores').select('*').order('nome', ascending: true);
      setState(() {
        _professores = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar professores: $e', style: const TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
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

  Future<void> _deleteProfessor(String id) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja excluir este professor?'),
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
        await _supabase.from('professores').delete().eq('id', id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Professor excluído com sucesso!', style: TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
              backgroundColor: Colors.green, // MODIFICADO: Fundo verde para sucesso
            ),
          );
        }
        _fetchProfessores();
      } on PostgrestException catch (e) {
        if (mounted) {
          String message = 'Erro ao excluir professor.';
          if (e.code == '23503') {
            message = 'Este professor está sendo utilizado no sistema no momento e não pode ser excluído.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message, style: const TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
              backgroundColor: Colors.red, // MODIFICADO: Fundo vermelho para erro
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir professor: $e', style: const TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _professores.isEmpty
              ? const Center(child: Text('Nenhum professor cadastrado. Adicione um!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _professores.length,
                  itemBuilder: (context, index) {
                    final professor = _professores[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.13),
                          child: Icon(Icons.person, color: Theme.of(context).colorScheme.secondary),
                        ),
                        title: Text('Nome: ${professor['nome']}'),
                        subtitle: Text(
                          'Email: ${professor['email']}\n'
                          'Telefone: ${professor['telefone'] ?? 'N/A'}\n'
                          'Disciplinas: ${professor['disciplinas_lecionadas'] ?? 'N/A'}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                              onPressed: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ProfessorFormPage(professor: professor),
                                  ),
                                );
                                if (result == true) {
                                  _fetchProfessores();
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                              onPressed: () => _deleteProfessor(professor['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ProfessorFormPage(),
            ),
          );
          if (result == true) {
            _fetchProfessores();
          }
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}