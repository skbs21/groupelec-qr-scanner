import 'package:flutter/material.dart';

class ContactDialog extends StatefulWidget {
  final String scannedData;
  final Function(String, String, String, String, String) onSave;

  final List<String> typesContacts;
  final List<String> secteursActivite;
  final List<String> offresInteressantes;

  const ContactDialog({
    Key? key,
    required this.scannedData,
    required this.onSave,
    required this.typesContacts,
    required this.secteursActivite,
    required this.offresInteressantes,
  }) : super(key: key);

  @override
  _ContactDialogState createState() => _ContactDialogState();
}

class _ContactDialogState extends State<ContactDialog> {
  final TextEditingController _phoneController = TextEditingController();
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

  void _saveContact() {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("📞 Numéro de téléphone requis"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onSave(
      phoneNumber,
      _selectedTypeContact,
      _selectedSecteur,
      _selectedOffre,
      widget.scannedData,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("🏢 Groupelec - Nouveau Contact"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Numéro de téléphone
            _buildLabel("📞 Numéro de téléphone"),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Entrez le numéro...",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
            ),
            SizedBox(height: 20),

            // Catégorie client
            _buildLabel("👥 Catégorie client"),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButton<String>(
                value: _selectedTypeContact,
                isExpanded: true,
                underline: SizedBox(),
                items: widget.typesContacts.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTypeContact = newValue!;
                  });
                },
              ),
            ),
            SizedBox(height: 20),

            // Secteur d'activité
            _buildLabel("🏗️ Secteur d'activité"),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButton<String>(
                value: _selectedSecteur,
                isExpanded: true,
                underline: SizedBox(),
                items: widget.secteursActivite.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSecteur = newValue!;
                  });
                },
              ),
            ),
            SizedBox(height: 20),

            // Offres intéressantes
            _buildLabel("💡 Offres intéressantes"),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButton<String>(
                value: _selectedOffre,
                isExpanded: true,
                underline: SizedBox(),
                items: widget.offresInteressantes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedOffre = newValue!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("❌ Scan annulé")),
            );
          },
          child: Text("❌ ANNULER"),
        ),
        ElevatedButton(
          onPressed: _saveContact,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
          child: Text("✅ VALIDER"),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
    );
  }
}