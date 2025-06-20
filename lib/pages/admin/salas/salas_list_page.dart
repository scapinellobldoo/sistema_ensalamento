// lib/pages/admin/salas/salas_list_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sistema_ensalamento/pages/admin/salas/sala_form_page.dart';

class SalasListPage extends StatefulWidget {
  const SalasListPage({super.key});

  @override
  State<SalasListPage> createState() => _SalasListPageState();
}

class _SalasListPageState extends State<SalasListPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _salas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSalas();
  }

  Future<void> _fetchSalas() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _supabase.from('salas').select('*').order('numero', ascending: true);
      setState(() {
        _salas = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar salas: $e', style: const TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
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

  Future<void> _deleteSala(String id) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja excluir esta sala?'),
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
        await _supabase.from('salas').delete().eq('id', id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sala excluída com sucesso!', style: TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
              backgroundColor: Colors.green, // MODIFICADO: Fundo verde para sucesso
            ),
          );
        }
        _fetchSalas();
      } on PostgrestException catch (e) {
        if (mounted) {
          String message = 'Erro ao excluir sala.';
          if (e.code == '23503') {
            message = 'Esta sala está sendo utilizada no sistema no momento e não pode ser excluída.';
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
              content: Text('Erro ao excluir sala: $e', style: const TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
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
          : _salas.isEmpty
              ? const Center(child: Text('Nenhuma sala cadastrada. Adicione uma!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _salas.length,
                  itemBuilder: (context, index) {
                    final sala = _salas[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text('Sala: ${sala['numero']}'),
                        subtitle: Text(
                          'Bloco: ${sala['bloco'] ?? 'N/A'}\n'
                          'Capacidade: ${sala['capacidade'] ?? 'N/A'}\n'
                          'Recursos: ${sala['recursos'] ?? 'N/A'}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SalaFormPage(sala: sala),
                                  ),
                                );
                                if (result == true) {
                                  _fetchSalas();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteSala(sala['id']),
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
              builder: (context) => const SalaFormPage(),
            ),
          );
          if (result == true) {
            _fetchSalas();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}