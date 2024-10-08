import 'package:flutter/material.dart';
import 'package:eduticket/screens/home/HomePage.dart';
import 'package:eduticket/screens/utilisateur/Utilisateur-List-page.dart';
import 'package:eduticket/screens/ticket/Ticket-List-Page.dart';
import 'package:eduticket/screens/HistoriquePage.dart';
import 'package:eduticket/screens/Profil/Profil-Page.dart';
import 'package:eduticket/screens/Chat/Conversation-List-Page.dart';
import 'package:eduticket/services/AuthService.dart';

class HomeWithBottomNavigationPage extends StatefulWidget {
  @override
  _HomeWithBottomNavigationPageState createState() => _HomeWithBottomNavigationPageState();
}

class _HomeWithBottomNavigationPageState extends State<HomeWithBottomNavigationPage> {
  // Indice de la page actuellement sélectionnée
  int _selectedIndex = 0;

  // Variable pour stocker l'ID de l'utilisateur
  String? _userId;

  // Liste des pages à afficher dans le corps du Scaffold
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  // Méthode pour initialiser les données utilisateur
  Future<void> _initUser() async {
    String userId = await AuthService().getCurrentFormateurId();
    setState(() {
      _userId = userId;

      _pages = [
        HomePage(),                // Page d'accueil
        UtilisateurListPage(),     // Page des utilisateurs
        TicketListPage(),          // Page de la liste des tickets
        HistoriquePage(),          // Page de l'historique des tickets
        ProfilPage(),              // Page de profil
        ConversationListPage(userId: userId), // Page de la liste des conversations
      ];
    });
  }

  // Fonction appelée lorsque l'utilisateur sélectionne un élément dans la BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Met à jour l'indice de la page sélectionnée
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _userId == null 
          ? Center(child: CircularProgressIndicator()) 
          : _pages[_selectedIndex], // Affiche la page sélectionnée
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home', // Label pour la page d'accueil
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Utilisateurs', // Label pour la page des utilisateurs
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tickets', // Label pour la page des tickets
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique', // Label pour la page d'historique des tickets
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle), // Icône pour la page de profil
            label: 'Profil', // Label pour la page de profil
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat), // Icône pour la page de conversations
            label: 'Conversations', // Label pour la page des conversations
          ),
        ],
        currentIndex: _selectedIndex, // Indice de la page actuellement sélectionnée
        selectedItemColor: Color(0xFFE50B14), // Couleur de l'élément sélectionné
        unselectedItemColor: Colors.black, // Couleur des éléments non sélectionnés
        onTap: _onItemTapped, // Fonction appelée lors de la sélection d'un élément
      ),
    );
  }
}
