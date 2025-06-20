// lib/pages/admin/disciplinas/disciplina_form_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DisciplinaFormPage extends StatefulWidget {
  final Map<String, dynamic>? disciplina; // Disciplina para edição (opcional)

  const DisciplinaFormPage({super.key, this.disciplina});

  @override
  State<DisciplinaFormPage> createState() => _DisciplinaFormPageState();
}

class _DisciplinaFormPageState extends State<DisciplinaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.disciplina != null) {
      _nomeController.text = widget.disciplina!['nome'] ?? '';
    }
  }

  Future<void> _saveDisciplina() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final newDisciplina = {
      'nome': _nomeController.text.trim(),
    };

    try {
      if (widget.disciplina == null) {
        await _supabase.from('disciplinas').insert(newDisciplina);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Disciplina cadastrada com sucesso!', style: TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
              backgroundColor: Colors.green, // MODIFICADO: Fundo verde para sucesso
            ),
          );
        }
      } else {
        await _supabase.from('disciplinas').update(newDisciplina).eq('id', widget.disciplina!['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Disciplina atualizada com sucesso!', style: TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
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
        String message = 'Erro ao salvar disciplina.';
        if (e.message.contains('duplicate key value violates unique constraint "disciplinas_nome_key"')) {
          message = 'Erro: O nome da disciplina "${newDisciplina['nome']}" já existe.';
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
            content: Text('Erro inesperado ao salvar disciplina: $e', style: const TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
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
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.disciplina == null ? 'Nova Disciplina' : 'Editar Disciplina'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Disciplina',
                  prefixIcon: Icon(Icons.class_),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome da disciplina.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveDisciplina,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: Text(widget.disciplina == null ? 'Cadastrar Disciplina' : 'Salvar Alterações'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}