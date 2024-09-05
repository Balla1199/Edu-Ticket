import 'package:flutter/material.dart';
import 'package:eduticket/models/Ticket-model.dart';

class TicketForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String initialTitre;
  final String initialDescription;
  final Categorie initialCategorie;
  final Function(String) onTitreChanged;
  final Function(String) onDescriptionChanged;
  final Function(Categorie) onCategorieChanged;
  final VoidCallback onSubmit;

  TicketForm({
    required this.formKey,
    required this.initialTitre,
    required this.initialDescription,
    required this.initialCategorie,
    required this.onTitreChanged,
    required this.onDescriptionChanged,
    required this.onCategorieChanged,
    required this.onSubmit,
  });

  @override
  _TicketFormState createState() => _TicketFormState();
}

class _TicketFormState extends State<TicketForm> {
  late String _titre;
  late String _description;
  late Categorie _categorie;

  @override
  void initState() {
    super.initState();
    _titre = widget.initialTitre;
    _description = widget.initialDescription;
    _categorie = widget.initialCategorie;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildTextField(
            label: 'Titre',
            initialValue: _titre,
            onChanged: (value) {
              setState(() {
                _titre = value;
                widget.onTitreChanged(value);
              });
            },
          ),
          SizedBox(height: 16.0),
          _buildTextField(
            label: 'Description',
            initialValue: _description,
            maxLines: 4,
            onChanged: (value) {
              setState(() {
                _description = value;
                widget.onDescriptionChanged(value);
              });
            },
          ),
          SizedBox(height: 16.0),
          _buildDropdown(
            label: 'Catégorie',
            value: _categorie,
            items: Categorie.values,
            onChanged: (value) {
              setState(() {
                _categorie = value ?? Categorie.technique;
                widget.onCategorieChanged(_categorie);
              });
            },
          ),
          SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: widget.onSubmit,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.blueAccent, // Couleur du texte du bouton
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: Text('Créer Ticket', style: TextStyle(fontSize: 18.0)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer un $label';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown({
    required String label,
    required Categorie value,
    required List<Categorie> items,
    required Function(Categorie?) onChanged,
  }) {
    return DropdownButtonFormField<Categorie>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      items: items.map((categorie) {
        return DropdownMenuItem(
          value: categorie,
          child: Text(categorie.toString().split('.').last),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
