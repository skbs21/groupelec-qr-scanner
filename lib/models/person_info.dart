class PersonInfo {
  final String qrData;
  final String phoneNumber;
  final String typeContact;
  final String secteurActivite;
  final String offresInteressantes;
  final ParsedData parsedData;

  PersonInfo({
    required this.qrData,
    required this.phoneNumber,
    required this.typeContact,
    required this.secteurActivite,
    required this.offresInteressantes,
    required this.parsedData,
  });
}

class ParsedData {
  String nomPrenom;
  String email;
  String entreprise;

  ParsedData({
    this.nomPrenom = "",
    this.email = "",
    this.entreprise = "",
  });
}