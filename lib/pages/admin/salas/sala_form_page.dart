// lib/pages/admin/salas/sala_form_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SalaFormPage extends StatefulWidget {
  final Map<String, dynamic>? sala; // Sala para edição (opcional)

  const SalaFormPage({super.key, this.sala});

  @override
  State<SalaFormPage> createState() => _SalaFormPageState();
}

class _SalaFormPageState extends State<SalaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _blocoController = TextEditingController();
  final _capacidadeController = TextEditingController();
  final _recursosController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.sala != null) {
      // Se estiver editando, preencher os campos com os dados existentes
      _numeroController.text = widget.sala!['numero'] ?? '';
      _blocoController.text = widget.sala!['bloco'] ?? '';
      _capacidadeController.text = (widget.sala!['capacidade'] ?? '').toString();
      _recursosController.text = widget.sala!['recursos'] ?? '';
    }
  }

  Future<void> _saveSala() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final int? capacidade = int.tryParse(_capacidadeController.text);
    if (_capacidadeController.text.isNotEmpty && capacidade == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Capacidade deve ser um número válido.', style: TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
            backgroundColor: Colors.red, // MODIFICADO: Fundo vermelho para erro
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final newSala = {
      'numero': _numeroController.text.trim(),
      'bloco': _blocoController.text.trim().isEmpty ? null : _blocoController.text.trim(),
      'capacidade': capacidade,
      'recursos': _recursosController.text.trim().isEmpty ? null : _recursosController.text.trim(),
    };

    try {
      if (widget.sala == null) {
        // Adicionar nova sala
        await _supabase.from('salas').insert(newSala);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sala cadastrada com sucesso!', style: TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
              backgroundColor: Colors.green, // MODIFICADO: Fundo verde para sucesso
            ),
          );
        }
      } else {
        // Atualizar sala existente
        await _supabase.from('salas').update(newSala).eq('id', widget.sala!['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sala atualizada com sucesso!', style: TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
              backgroundColor: Colors.green, // MODIFICADO: Fundo verde para sucesso
            ),
          );
        }
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar sala: $e', style: const TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
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
    _numeroController.dispose();
    _blocoController.dispose();
    _capacidadeController.dispose();
    _recursosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sala == null ? 'Nova Sala' : 'Editar Sala'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _numeroController,
                decoration: const InputDecoration(
                  labelText: 'Número da Sala',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o número da sala.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _blocoController,
                decoration: const InputDecoration(
                  labelText: 'Bloco (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _capacidadeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capacidade (Opcional)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                    return 'Por favor, insira um número válido para a capacidade.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _recursosController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Recursos (Ex: Projetor, Ar Cond.) (Opcional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24.0),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveSala,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: Text(widget.sala == null ? 'Cadastrar Sala' : 'Salvar Alterações'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}