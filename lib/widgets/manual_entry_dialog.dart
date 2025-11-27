import 'package:flutter/material.dart';

class ManualEntryDialog extends StatefulWidget {
  final Function(Map<String, String>) onSave;
  final List<String> typesContacts;
  final List<String> secteursActivite;
  final List<String> offresInteressantes;

  const ManualEntryDialog({
    Key? key,
    required this.onSave,
    required this.typesContacts,
    required this.secteursActivite,
    required this.offresInteressantes,
  }) : super(key: key);

  @override
  _ManualEntryDialogState createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<ManualEntryDialog> {
  final TextEditingController _nomPrenomController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _entrepriseController = TextEditingController();

  late String _selectedTypeContact;
  late String _selectedSecteur;
  late String _selectedOffre;

  @override
  void initState() {
    super.initState();
    _selectedTypeContact = widget.typesContacts.firstWhere(
          (item) => item == "Autre",
      orElse: () => widget.typesContacts.first,
    );
    _selectedSecteur = widget.secteursActivite.firstWhere(
          (item) => item == "Autre",
      orElse: () => widget.secteursActivite.first,
    );
    _selectedOffre = widget.offresInteressantes.firstWhere(
          (item) => item == "Autre",
      orElse: () => widget.offresInteressantes.first,
    );
  }

  void _saveManualData() {
    final data = {
      'nomPrenom': _nomPrenomController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'entreprise': _entrepriseController.text.trim(),
      'typeContact': _selectedTypeContact,
      'secteurActivite': _selectedSecteur,
      'offresInteressantes': _selectedOffre,
    };

    widget.onSave(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("📝 Groupelec - Saisie Manuelle"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nom & Prénom
            _buildTextField("👤 Nom & Prénom", _nomPrenomController, false),
            SizedBox(height: 16),

            // Téléphone
            _buildTextField("📞 Téléphone", _phoneController, false, TextInputType.phone),
            SizedBox(height: 16),

            // Email
            _buildTextField("📧 Email", _emailController, false, TextInputType.emailAddress),
            SizedBox(height: 16),

            // Entreprise
            _buildTextField("🏢 Entreprise", _entrepriseController, false),
            SizedBox(height: 16),

            // Catégorie
            _buildLabel("📊 Catégorie client"),
            _buildDropdown(_selectedTypeContact, widget.typesContacts, (value) {
              setState(() {
                _selectedTypeContact = value!;
              });
            }),
            SizedBox(height: 16),

            // Secteur d'activité
            _buildLabel("🏗️ Secteur d'activité"),
            _buildDropdown(_selectedSecteur, widget.secteursActivite, (value) {
              setState(() {
                _selectedSecteur = value!;
              });
            }),
            SizedBox(height: 16),

            // Offres intéressantes
            _buildLabel("💡 Offres intéressantes"),
            _buildDropdown(_selectedOffre, widget.offresInteressantes, (value) {
              setState(() {
                _selectedOffre = value!;
              });
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Saisie annulée")),
            );
          },
          child: Text("❌ ANNULER"),
        ),
        ElevatedButton(
          onPressed: _saveManualData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
          child: Text("✅ ENREGISTRER"),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isRequired, [TextInputType? keyboardType]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.orange,
          ),
        ),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: "Entrez ${label.toLowerCase()}...",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: SizedBox(),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}