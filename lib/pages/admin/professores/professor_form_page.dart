// lib/pages/admin/professores/professor_form_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfessorFormPage extends StatefulWidget {
  final Map<String, dynamic>? professor; // Professor para edição (opcional)

  const ProfessorFormPage({super.key, this.professor});

  @override
  State<ProfessorFormPage> createState() => _ProfessorFormPageState();
}

class _ProfessorFormPageState extends State<ProfessorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _disciplinasController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.professor != null) {
      // Se estiver editando, preencher os campos com os dados existentes
      _nomeController.text = widget.professor!['nome'] ?? '';
      _emailController.text = widget.professor!['email'] ?? '';
      _telefoneController.text = widget.professor!['telefone'] ?? '';
      _disciplinasController.text = widget.professor!['disciplinas_lecionadas'] ?? '';
    }
  }

  Future<void> _saveProfessor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final newProfessor = {
      'nome': _nomeController.text.trim(),
      'email': _emailController.text.trim(),
      'telefone': _telefoneController.text.trim().isEmpty ? null : _telefoneController.text.trim(),
      'disciplinas_lecionadas': _disciplinasController.text.trim().isEmpty ? null : _disciplinasController.text.trim(),
    };

    try {
      if (widget.professor == null) {
        // Adicionar novo professor
        await _supabase.from('professores').insert(newProfessor);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Professor cadastrado com sucesso!', style: TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
              backgroundColor: Colors.green, // MODIFICADO: Fundo verde para sucesso
            ),
          );
        }
      } else {
        // Atualizar professor existente
        await _supabase.from('professores').update(newProfessor).eq('id', widget.professor!['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Professor atualizado com sucesso!', style: TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
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
        String message = 'Erro ao salvar professor.';
        if (e.message.contains('duplicate key value violates unique constraint "professores_email_key"')) {
          message = 'Erro: O email ${newProfessor['email']} já está em uso.';
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
            content: Text('Erro inesperado ao salvar professor: $e', style: const TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
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
    _emailController.dispose();
    _telefoneController.dispose();
    _disciplinasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.professor == null ? 'Novo Professor' : 'Editar Professor'),
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
                  labelText: 'Nome Completo',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do professor.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email do professor.';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Por favor, insira um email válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone (Opcional)',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _disciplinasController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Disciplinas que leciona (Opcional)',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.library_books),
                ),
              ),
              const SizedBox(height: 24.0),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfessor,
                        child: Text(widget.professor == null ? 'Cadastrar Professor' : 'Salvar Alterações'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}