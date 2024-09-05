import 'package:eduticket/models/Conversation.dart';
import 'package:eduticket/screens/Chat/Chat-Page.dart';
import 'package:eduticket/screens/Chat/Conversation-List-Page.dart';
import 'package:eduticket/screens/HistoriquePage.dart';
import 'package:eduticket/screens/Profil/Profil-Page.dart';
import 'package:flutter/material.dart';
import 'package:eduticket/screens/ticket/Ticket-Form-Page.dart';
import 'package:eduticket/screens/ticket/Ticket-List-Page.dart';
import 'package:eduticket/screens/ticket/Treat-Ticket-Page.dart';
import 'package:eduticket/screens/ticket/Ticket-Details-Page.dart'; 
import 'package:eduticket/screens/utilisateur/Utilisateur-Form-Page.dart';
import 'package:eduticket/screens/utilisateur/Utilisateur-List-page.dart';
import 'package:eduticket/screens/login/LoginPage.dart';
import 'package:eduticket/screens/home/HomePage.dart';
import 'package:eduticket/models/Ticket-model.dart'; 
class AppRoutes {
  // Définition des chemins de route
  static const String loginPage = '/login';
  static const String homePage = '/home';
  static const String utilisateurFormPage = '/utilisateur-form';
  static const String utilisateurListPage = '/utilisateur-list';
  static const String notificationPage = '/notification';
  static const String profilePage = '/profile';
  static const String historiquePage = '/historique';
  static const String rapportPage = '/rapport';
  static const String ticketFormPage = '/ticket-form';
  static const String ticketListPage = '/ticket-list';
  static const String treatTicketPage = '/treat-ticket';
  static const String detailTicketPage = '/ticket-detail';
  static const String chatPage = '/chat'; // Ajout de la route pour ChatPage
  static const String conversationListPage = '/conversation-list'; // Ajout de la route pour ConversationListPage

  // Fonction pour générer les routes
 static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginPage:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case homePage:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case utilisateurFormPage:
        return MaterialPageRoute(builder: (_) => UtilisateurFormPage());
      case utilisateurListPage:
        return MaterialPageRoute(builder: (_) => UtilisateurListPage());
      case ticketFormPage:
        return MaterialPageRoute(builder: (_) => TicketFormPage());
      case ticketListPage:
        return MaterialPageRoute(builder: (_) => TicketListPage());
      case treatTicketPage:
        final Ticket ticket = settings.arguments as Ticket;
        return MaterialPageRoute(
          builder: (_) => TreatTicketPage(ticket: ticket),
        );
      case detailTicketPage:
        final Ticket ticket = settings.arguments as Ticket;
        return MaterialPageRoute(
          builder: (_) => DetailTicketPage(ticket: ticket),
        );
      case historiquePage:
        return MaterialPageRoute(builder: (_) => HistoriquePage());
      case profilePage:
        return MaterialPageRoute(builder: (_) => ProfilPage());

      case chatPage:
        final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
        final Conversation conversation = args['conversation'];
        final String currentUserId = args['currentUserId'];
        return MaterialPageRoute(
          builder: (_) => ChatPage(
            conversation: conversation,
            currentUserId: currentUserId,
          ),
        );

      case conversationListPage:
        final String userId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ConversationListPage(userId: userId),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Page non trouvée: ${settings.name}'),
            ),
          ),
        );
    }
  }


}
