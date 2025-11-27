import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/person_info.dart';

class FileExporter {
  static Future<File?> exportToTXT(List<PersonInfo> personList) async {
    if (personList.isEmpty) {
      return null;
    }

    try {
      // Essayer d'abord le dossier Téléchargements
      Directory? downloadsDirectory;
      try {
        if (Platform.isAndroid) {
          downloadsDirectory = Directory('/storage/emulated/0/Download');
          if (!await downloadsDirectory.exists()) {
            downloadsDirectory = await getExternalStorageDirectory();
          }
        } else {
          downloadsDirectory = await getDownloadsDirectory();
        }
      } catch (e) {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      // Si pas de dossier Téléchargements, utiliser Documents
      final directory = downloadsDirectory ?? await getApplicationDocumentsDirectory();

      final timeStamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = "Groupelec_Contacts_$timeStamp.txt";
      final file = File('${directory.path}/$fileName');

      String content = "# 🏢 Groupelec - Export des Contacts\n";
      content += "# 📅 Généré le: ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now())}\n";
      content += "# 👥 Nombre de contacts: ${personList.length}\n";
      content += "ID;Téléphone;Nom_Prenom;Email;Entreprise;Catégorie_Client;Secteur_Activité;Offres_Intéressantes\n";

      for (int i = 0; i < personList.length; i++) {
        final person = personList[i];
        final parsed = person.parsedData;

        final cleanNomPrenom = _cleanField(parsed.nomPrenom);
        final cleanEmail = _cleanField(parsed.email);
        final cleanEntreprise = _cleanField(parsed.entreprise);
        final cleanCategorie = _cleanField(person.typeContact);
        final cleanSecteur = _cleanField(person.secteurActivite);
        final cleanOffres = _cleanField(person.offresInteressantes);

        final line = "${i + 1};" +
            "${person.phoneNumber};" +
            "$cleanNomPrenom;" +
            "$cleanEmail;" +
            "$cleanEntreprise;" +
            "$cleanCategorie;" +
            "$cleanSecteur;" +
            "$cleanOffres\n";

        content += line;
      }

      await file.writeAsString(content);
      print("📁 Fichier créé: ${file.path}"); // Pour debug
      return file;

    } catch (e) {
      print("❌ Erreur export: $e");
      return null;
    }
  }

  static String _cleanField(String field) {
    return field.replaceAll(";", ",").replaceAll("\n", " ").replaceAll("\r", " ").trim();
  }

  static Future<void> shareFile(File file) async {
    try {
      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        subject: "🏢 Groupelec - Contacts Export",
        text: "Fichier exporté depuis Groupelec QR Scanner\n📊 ${file.path.split('/').last}\n📅 ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
      );
    } catch (e) {
      print("Erreur partage: $e");
      rethrow;
    }
  }
}