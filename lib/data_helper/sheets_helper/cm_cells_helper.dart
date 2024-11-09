class CMMapper {
  final Map<String, Map<String, dynamic>> sheetMappings = {
    'Generator': {
      'templateFileId': '165kXvZcOPkYG6d9-5kdeGMTBDzNZjtyPrN1S9SINdmc',
      'sheetName': 'Gen',
      'cells': {
        // ... (cells for Generator)
      },
    },
    'Electric': {
      'templateFileId': '11wnDIr4gj628tT0z-QbfWliPz79I_kH7_2rOCiyjkz0',
      'sheetName': 'Ele',
      'cells': {
        // ... (cells for Electric)
      },
    },
    'AC': {
      'templateFileId': '1g3nXr3AJCL1KnmLFuCrvN7zm-zWK4GVzr1GF16aBUL8',
      'sheetName': 'AC',
      'cells': {
        // ... (cells for AC)
      },
    },
    'Civil': {
      'templateFileId': '1MVbogaeQKVjAMiQJZHycBx1MstVIjX6YFQv5T4hJbfU',
      'sheetName': 'Civil',
      'cells': {
        // ... (cells for Civil)
      },
    },
    // Add other types as needed
  };

  Map<String, dynamic> getCMMapping(String sheetType) {
    if (sheetMappings.containsKey(sheetType)) {
      return sheetMappings[sheetType]!['cells'] as Map<String, dynamic>;
    } else {
      throw Exception('Invalid sheet type');
    }
  }

  String getCMTemplateFileId(String sheetType) {
    if (sheetMappings.containsKey(sheetType)) {
      return sheetMappings[sheetType]!['templateFileId'] as String;
    } else {
      throw Exception('Invalid sheet type');
    }
  }

  String getCMSheetName(String sheetType) {
    if (sheetMappings.containsKey(sheetType)) {
      return sheetMappings[sheetType]!['sheetName'] as String;
    } else {
      throw Exception('Invalid sheet type');
    }
  }
}
