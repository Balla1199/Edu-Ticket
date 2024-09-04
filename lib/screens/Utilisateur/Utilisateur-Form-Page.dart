import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduticket/models/utilisateur.dart';
import 'package:eduticket/services/UtilisateurService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class UtilisateurFormPage extends StatefulWidget {
  final Utilisateur? utilisateur; 

  UtilisateurFormPage({Key? key, this.utilisateur}) : super(key: key);

  @override
  _UtilisateurFormPageState createState() => _UtilisateurFormPageState();
}

class _UtilisateurFormPageState extends State<UtilisateurFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _id;
  late String _nom;
  late String _email;
  late String _motDePasse;
  late Role _role;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    if (widget.utilisateur != null) {
      _id = widget.utilisateur!.id;
      _nom = widget.utilisateur!.nom;
      _email = widget.utilisateur!.email;
      _motDePasse = widget.utilisateur!.motDePasse;
      _role = widget.utilisateur!.role;
    } else {
      _id = '';
      _nom = '';
      _email = '';
      _motDePasse = '';
      _role = Role.apprenant;
    }
  }

  // Méthode pour soumettre le formulaire
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      try {
        if (_id.isEmpty) {
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _email,
            password: _motDePasse,
          );

          await ajouterUtilisateurApresInscription(userCredential.user!, _role.toString().split('.').last);
        } else {
          await UtilisateurService().modifierUtilisateur(
            Utilisateur(
              id: _id,
              nom: _nom,
              email: _email,
              motDePasse: _motDePasse,
              role: _role,
            ),
          );
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'inscription ou de la mise à jour: ${e.toString()}')),
        );  
      }
    }
  }

  // Méthode pour ajouter un utilisateur dans Firestore après l'inscription
  Future<void> ajouterUtilisateurApresInscription(User user, String roleString) async {
    try {
      print('Vérification si l\'utilisateur existe déjà dans Firestore...');
      DocumentSnapshot doc = await _db.collection('utilisateurs').doc(user.uid).get();

      if (!doc.exists) {
        print('L\'utilisateur n\'existe pas dans Firestore, ajout de l\'utilisateur...');
        Role role = _stringToRole(roleString);

        Utilisateur newUser = Utilisateur(
          id: user.uid,
          nom: _nom,
          email: user.email ?? 'email@example.com',
          motDePasse: '', // Le mot de passe ne devrait pas être stocké en clair
          role: role,
        );

        await _db.collection('utilisateurs').doc(user.uid).set(newUser.toMap());
        print('Utilisateur ajouté avec succès dans Firestore.');
      } else {
        print('L\'utilisateur existe déjà dans Firestore.');
      }
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'utilisateur après l\'inscription: $e');
    }
  }

  // Conversion d'une chaîne de caractères en Role
  Role _stringToRole(String roleString) {
    return Role.values.firstWhere((role) => role.toString().split('.').last == roleString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.utilisateur != null ? 'Modifier Utilisateur' : 'Ajouter un Utilisateur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Nom'),
                initialValue: _nom,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
                onSaved: (value) {
                  _nom = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                initialValue: _email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Mot de passe'),
                initialValue: _motDePasse,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe';
                  }
                  return null;
                },
                onSaved: (value) {
                  _motDePasse = value ?? '';
                },
              ),
              DropdownButtonFormField<Role>(
                value: _role,
                decoration: InputDecoration(labelText: 'Rôle'),
                items: Role.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _role = value ?? Role.apprenant;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un rôle';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.utilisateur != null ? 'Modifier' : 'Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}