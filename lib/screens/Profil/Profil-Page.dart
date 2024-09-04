import 'package:eduticket/models/Utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:eduticket/services/AuthService.dart';


class ProfilPage extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.of(context).pop(); // Retourne à l'écran précédent après la déconnexion
            },
          ),
        ],
      ),
      body: FutureBuilder<Utilisateur?>(
        future: _authService.getCurrentUser(),
        builder: (BuildContext context, AsyncSnapshot<Utilisateur?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Aucun utilisateur connecté.'));
          } else {
            Utilisateur user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/user_placeholder.png'), // Placeholder image
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nom:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(user.nom),
                      SizedBox(height: 16),
                      Text(
                        'Email:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(user.email),
                      SizedBox(height: 16),
                      Text(
                        'Role:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(user.role.toString().split('.').last), // Display role
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
