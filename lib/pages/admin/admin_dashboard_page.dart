// lib/pages/admin/admin_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importar as futuras páginas de gerenciamento
import 'package:sistema_ensalamento/pages/admin/salas/salas_list_page.dart'; // Futuro
import 'package:sistema_ensalamento/pages/admin/professores/professores_list_page.dart'; // Futuro
import 'package:sistema_ensalamento/pages/admin/aulas/aulas_calendar_page.dart'; // Futuro
import 'package:sistema_ensalamento/pages/admin/disciplinas/disciplinas_list_page.dart'; // ADICIONADO: Import da página de listagem de disciplinas

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0; // Índice da página selecionada no Drawer
  final _supabase = Supabase.instance.client;

  // Lista de widgets para o corpo da dashboard
  static const List<Widget> _widgetOptions = <Widget>[
    AulasCalendarPage(),      // 0 - Calendário de Aulas
    SalasListPage(),          // 1 - Gerenciar Salas
    ProfessoresListPage(),    // 2 - Gerenciar Professores
    DisciplinasListPage(),    // ADICIONADO: 3 - Gerenciar Disciplinas
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    await _supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard da Secretaria'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gerenciamento do Sistema',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Gerenciar Aulas'),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context); // Fecha o drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.meeting_room),
              title: const Text('Gerenciar Salas'),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Gerenciar Professores'),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile( // ADICIONADO: Novo item para Disciplinas
              leading: const Icon(Icons.book), // Ícone para disciplinas
              title: const Text('Gerenciar Disciplinas'),
              selected: _selectedIndex == 3,
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
            const Divider(), // Divisor para separar itens
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Sobre'),
              onTap: () {
                // Implementar tela Sobre
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex), // Exibe a página selecionada
    );
  }
}