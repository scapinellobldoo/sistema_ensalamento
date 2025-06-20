// lib/pages/admin/disciplinas/disciplinas_list_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sistema_ensalamento/pages/admin/disciplinas/disciplina_form_page.dart';

class DisciplinasListPage extends StatefulWidget {
  const DisciplinasListPage({super.key});

  @override
  State<DisciplinasListPage> createState() => _DisciplinasListPageState();
}

class _DisciplinasListPageState extends State<DisciplinasListPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _disciplinas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDisciplinas();
  }

  Future<void> _fetchDisciplinas() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _supabase.from('disciplinas').select('*').order('nome', ascending: true);
      setState(() {
        _disciplinas = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar disciplinas: $e', style: const TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
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

  Future<void> _deleteDisciplina(String id) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja excluir esta disciplina?'),
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
        await _supabase.from('disciplinas').delete().eq('id', id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Disciplina excluída com sucesso!', style: TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
              backgroundColor: Colors.green, // MODIFICADO: Fundo verde para sucesso
            ),
          );
        }
        _fetchDisciplinas();
      } on PostgrestException catch (e) {
        if (mounted) {
          String message = 'Erro ao excluir disciplina.';
          if (e.code == '23503') {
            message = 'Esta disciplina está sendo utilizada em aulas no momento e não pode ser excluída.';
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
              content: Text('Erro ao excluir disciplina: $e', style: const TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
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
          : _disciplinas.isEmpty
              ? const Center(child: Text('Nenhuma disciplina cadastrada. Adicione uma!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _disciplinas.length,
                  itemBuilder: (context, index) {
                    final disciplina = _disciplinas[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.13),
                          child: Icon(Icons.bookmark_border, color: Theme.of(context).colorScheme.primary),
                        ),
                        title: Text('Disciplina: ${disciplina['nome']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                              onPressed: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => DisciplinaFormPage(disciplina: disciplina),
                                  ),
                                );
                                if (result == true) {
                                  _fetchDisciplinas();
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                              onPressed: () => _deleteDisciplina(disciplina['id']),
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
              builder: (context) => const DisciplinaFormPage(),
            ),
          );
          if (result == true) {
            _fetchDisciplinas();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}