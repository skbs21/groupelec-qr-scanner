import 'dart:io';
import 'package:flutter/material.dart';
import '../models/person_info.dart';
import '../widgets/contact_dialog.dart';
import '../widgets/manual_entry_dialog.dart';
import '../utils/file_exporter.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PersonInfo> personList = [];
  Set<String> qrSet = {};
  String statusText = "👋 Prêt à scanner/saisir des contacts";
  File? _lastExportedFile;
  String? _filePath;

  // Listes pour les dropdowns
  final List<String> typesContacts = [
    "Client final", "Installateur", "Distributeur", "Fabricant",
    "EPC", "Etudiant", "Autre"
  ];

  final List<String> secteursActivite = [
    "Industrie Chimique", "Industrie Minière", "Industrie Automobile",
    "Industrie Agroalimentaire", "Autres Industries",
    "Eau : Station de Pompage, de Traitement ou de Déssalement",
    "Datacenters", "Port & Aéroport", "Autres Infrastructures",
    "Hôpitaux & Santé", "Hôtellerie", "Grandes surfaces & Restauration",
    "Tours", "Autres Building", "Production d'énergie",
    "Transport d'Énergie", "Distribution d'Énergie",
    "Énergies Renouvelables", "Autre"
  ];

  final List<String> offresInteressantes = [
    "Tableaux Basse Tension - Okken",
    "Tableaux Basse Tension - Tableaux testés IEC61439",
    "Cellules Moyenne Tension type Primaire PIX50",
    "Solutions Power Monitoring",
    "Armoires de Tranches",
    "Canalisation Préfabriquées (Gaine à Barre)",
    "Solutions de Contrôle commande numérique – Smart Grid",
    "Plusieurs offres", "Autre"
  ];

  @override
  void initState() {
    super.initState();
    _showWelcomeMessage();
  }

  void _showWelcomeMessage() {
    Future.delayed(Duration(milliseconds: 500), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🚀 Groupelec QR Scanner - Prêt !"),
          duration: Duration(seconds: 3),
          backgroundColor: Color(0xFFFE970D),
        ),
      );
    });
  }

  void _startQrScan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScannerScreen()),
    );

    if (result != null && result is String) {
      _showContactDetailsDialog(result);
    }
  }

  void _showContactDetailsDialog(String scannedData) {
    showDialog(
      context: context,
      builder: (context) => ContactDialog(
        scannedData: scannedData,
        onSave: _saveScannedData,
        typesContacts: typesContacts,
        secteursActivite: secteursActivite,
        offresInteressantes: offresInteressantes,
      ),
    );
  }

  void _saveScannedData(String phoneNumber, String typeContact, String secteurActivite, String offresInteressantes, String scannedData) {
    if (qrSet.contains(scannedData)) {
      _showErrorToast("⚠️ Ce QR code a déjà été scanné");
      setState(() {
        statusText = "⚠️ Doublon ignoré";
      });
      return;
    }

    qrSet.add(scannedData);
    final parsedData = _parseQRData(scannedData);

    final personInfo = PersonInfo(
      qrData: scannedData,
      phoneNumber: phoneNumber,
      typeContact: typeContact,
      secteurActivite: secteurActivite,
      offresInteressantes: offresInteressantes,
      parsedData: parsedData,
    );

    setState(() {
      personList.add(personInfo);
      statusText = "✅ Scan ${personList.length} - $typeContact";
    });

    _showSuccessToast("✅ $typeContact enregistré !\n📞 $phoneNumber\n🏢 ${parsedData.entreprise}");
  }

  void _showManualEntry() {
    showDialog(
      context: context,
      builder: (context) => ManualEntryDialog(
        onSave: _saveManualData,
        typesContacts: typesContacts,
        secteursActivite: secteursActivite,
        offresInteressantes: offresInteressantes,
      ),
    );
  }

  void _saveManualData(Map<String, String> data) {
    final manualId = "MANUAL_${DateTime.now().millisecondsSinceEpoch}";

    final parsedData = ParsedData(
      nomPrenom: data['nomPrenom'] ?? "Non spécifié",
      email: data['email'] ?? "Non spécifié",
      entreprise: data['entreprise'] ?? "Non spécifié",
    );

    final personInfo = PersonInfo(
      qrData: manualId,
      phoneNumber: data['phoneNumber'] ?? "Non spécifié",
      typeContact: data['typeContact'] ?? "Non spécifié",
      secteurActivite: data['secteurActivite'] ?? "Non spécifié",
      offresInteressantes: data['offresInteressantes'] ?? "Non spécifié",
      parsedData: parsedData,
    );

    setState(() {
      personList.add(personInfo);
      statusText = "✅ Saisie ${personList.length}";
    });

    _showSuccessToast("✅ Contact enregistré !\n👤 ${parsedData.nomPrenom}");
  }

  ParsedData _parseQRData(String qrData) {
    final parsedData = ParsedData();
    final cleanedData = qrData.replaceAll("\n", " ").replaceAll("\r", " ").trim();

    if (cleanedData.contains(";")) {
      final parts = cleanedData.split(";").map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      switch (parts.length) {
        case 1:
          parsedData.nomPrenom = parts[0];
          break;
        case 2:
          if (parts[1].contains("@")) {
            parsedData.nomPrenom = parts[0];
            parsedData.email = parts[1];
          } else {
            parsedData.nomPrenom = parts[0];
            parsedData.entreprise = parts[1];
          }
          break;
        case 3:
          parsedData.nomPrenom = parts[0];
          parsedData.email = parts[1];
          parsedData.entreprise = parts[2];
          break;
        default:
          parsedData.nomPrenom = parts[0];
          parsedData.email = parts[1];
          parsedData.entreprise = parts[2];
      }
    } else {
      final emailRegex = RegExp(r"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}");
      final emailMatch = emailRegex.firstMatch(cleanedData);
      if (emailMatch != null) {
        parsedData.email = emailMatch.group(0)!;
        final beforeEmail = cleanedData.substring(0, emailMatch.start).trim();
        final afterEmail = cleanedData.substring(emailMatch.end).trim();
        if (beforeEmail.isNotEmpty) parsedData.nomPrenom = beforeEmail;
        if (afterEmail.isNotEmpty) parsedData.entreprise = afterEmail;
      } else {
        parsedData.nomPrenom = cleanedData;
      }
    }
    return parsedData;
  }

  void _showPersonDetails(int index) {
    final person = personList[index];
    final parsed = person.parsedData;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("📋 Détails du Contact #${index + 1}"),
        content: SingleChildScrollView(
          child: Text("""
🏢 Groupelec - Détails du Contact

ID: ${index + 1}
📞 Téléphone: ${person.phoneNumber}
👤 Nom & Prénom: ${parsed.nomPrenom.isEmpty ? "Non spécifié" : parsed.nomPrenom}
📧 Email: ${parsed.email.isEmpty ? "Non spécifié" : parsed.email}
🏭 Entreprise: ${parsed.entreprise.isEmpty ? "Non spécifié" : parsed.entreprise}
📊 Catégorie: ${person.typeContact}
🏗️ Secteur d'activité: ${person.secteurActivite}
💡 Offres intéressantes: ${person.offresInteressantes}
          """),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("👌 OK"),
          ),
        ],
      ),
    );
  }

  void _exportToTXT() async {
    if (personList.isEmpty) {
      _showErrorToast("📭 Aucun contact à exporter");
      return;
    }

    try {
      final file = await FileExporter.exportToTXT(personList);

      if (file != null) {
        _lastExportedFile = file;
        _filePath = file.path;

        setState(() {
          statusText = "📤 Exporté: ${personList.length} contacts";
        });

        // Montrer le chemin du fichier
        _showFileLocation(file.path);

      } else {
        _showErrorToast("❌ Erreur lors de l'export");
      }

    } catch (e) {
      _showErrorToast("❌ Erreur export: ${e.toString()}");
    }
  }

  void _showFileLocation(String filePath) {
    String fileName = filePath.split('/').last;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("✅ Fichier Exporté", style: TextStyle(color: Color(0xFFFE970D))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📁 Nom: $fileName", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("📍 Chemin:", style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                filePath,
                style: TextStyle(fontSize: 10, color: Colors.grey[700], fontFamily: 'Monospace'),
              ),
            ),
            SizedBox(height: 10),
            Text("💾 Utilisez 'Partager' pour envoyer le fichier", style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: Color(0xFFFE970D))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _shareLastFile();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFE970D)),
            child: Text("📨 Partager Maintenant"),
          ),
        ],
      ),
    );
  }

  void _shareLastFile() async {
    if (personList.isEmpty) {
      _showErrorToast("📭 Aucun contact à partager");
      return;
    }

    if (_lastExportedFile == null) {
      _exportToTXT();
      return;
    }

    try {
      await FileExporter.shareFile(_lastExportedFile!);
      _showSuccessToast("📨 Fichier partagé avec succès!");
    } catch (e) {
      _showErrorToast("❌ Erreur partage: ${e.toString()}");
    }
  }

  void _showSuccessToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFFFE970D),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFE970D),
                Color(0xFFFF6F00),
              ],
            ),
          ),
          child: Column(
            children: [
              // HEADER AVEC 2 LOGOS
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // LOGO GAUCHE
                    Image.asset(
                      'assets/images/logo_groupelec.png',
                      height: 50,
                      fit: BoxFit.contain,
                    ),

                    // TITRE CENTRAL
                    Column(
                      children: [
                        Text(
                          "",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),

                    // LOGO DROITE (QR)
                    Image.asset(
                      'assets/images/logo_qr.png',
                      height: 90,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              // SECTION PRÊT À SCANNER/SAISIR
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Color(0xFFFE970D), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Prêt à scanner/saisir des contacts",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFE970D),
                      ),
                    ),
                    SizedBox(height: 15),

                    // BOUTONS D'ACTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMenuButton("SAISIE MANUELLE", Icons.edit_note, _showManualEntry),
                        _buildMenuButton("SCANNER QR CODE", Icons.qr_code_scanner, _startQrScan),
                        _buildMenuButton("EXPORTER", Icons.file_download, _exportToTXT),
                        _buildMenuButton("PARTAGER", Icons.share, _shareLastFile),
                      ],
                    ),
                  ],
                ),
              ),

              // COMPTEUR DE CONTACTS
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        color: Color(0xFFFF6F00),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${personList.length}",
                        style: TextStyle(
                          color: Color(0xFFFE970D),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // HISTORIQUE DES CONTACTS
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      // TITRE HISTORIQUE
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFFE970D),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.history, color: Colors.white, size: 24),
                            SizedBox(width: 10),
                            Text(
                              "HISTORIQUE DES CONTACTS",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // LISTE DES CONTACTS
                      Expanded(
                        child: personList.isEmpty
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.contacts, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                "Aucun contact enregistré",
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Utilisez Scanner QR ou Saisie Manuelle",
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                            : ListView.builder(
                          itemCount: personList.length,
                          itemBuilder: (context, index) {
                            return _buildContactItem(index);
                          },
                        ),
                      ),

                      // FOOTER
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "© 2025 Groupelec - Tous droits réservés",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, IconData icon, Function() onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xFFFE970D),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFFFE970D),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(int index) {
    final person = personList[index];
    final parsed = person.parsedData;
    final prefix = person.qrData.startsWith("MANUAL_") ? "📝" : "📷";

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFFE970D),
          child: Text("${index + 1}", style: TextStyle(color: Colors.white)),
        ),
        title: Text("$prefix ${parsed.nomPrenom}", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("📞 ${person.phoneNumber} | 🏢 ${parsed.entreprise}"),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFFE970D)),
        onTap: () => _showPersonDetails(index),
      ),
    );
  }
}