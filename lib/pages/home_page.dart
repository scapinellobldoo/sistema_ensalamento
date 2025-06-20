// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importe as futuras páginas que serão acessadas
import 'package:sistema_ensalamento/pages/admin/admin_dashboard_page.dart';
import 'package:sistema_ensalamento/pages/professor/professor_dashboard_page.dart';
import 'package:sistema_ensalamento/pages/aluno/aluno_dashboard_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _supabase = Supabase.instance.client;
  User? _currentUser;
  String? _userRole; // Para armazenar a role do usuário
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndRole();
  }

  Future<void> _loadUserDataAndRole() async {
    _currentUser = _supabase.auth.currentUser;
    if (_currentUser != null) {
      try {
        // Buscar a role do usuário na tabela de perfis
        final response =
            await _supabase.from('profiles').select('role').eq('id', _currentUser!.id).single();
        setState(() {
          _userRole = response['role'];
          _isLoading = false;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao carregar perfil: $e', style: const TextStyle(color: Colors.white)), // MODIFICADO: Texto branco
              backgroundColor: Colors.red, // MODIFICADO: Fundo vermelho para erro
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // Se não há usuário logado, redireciona para o login.
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    }
  }

  Future<void> _signOut() async {
    await _supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/'); // Volta para a tela de login
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Se a role ainda não foi carregada, mostra um erro ou redireciona
    if (_userRole == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Não foi possível carregar o perfil do usuário.'),
              ElevatedButton(
                onPressed: _signOut,
                child: const Text('Voltar ao Login'),
              ),
            ],
          ),
        ),
      );
    }

    // Redireciona para a tela específica com base na role
    switch (_userRole) {
      case 'admin':
        return const AdminDashboardPage();
      case 'professor':
        return const ProfessorDashboardPage();
      case 'aluno':
        return const AlunoDashboardPage();
      default:
        // Caso a role seja inválida ou não reconhecida
        return Scaffold(
          appBar: AppBar(title: const Text('Erro de Acesso')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Sua função não é reconhecida. Contate o suporte.'),
                ElevatedButton(
                  onPressed: _signOut,
                  child: const Text('Sair'),
                ),
              ],
            ),
          ),
        );
    }
  }
}