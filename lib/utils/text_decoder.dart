import 'dart:convert';

class TextDecoder {
  /// Decodifica un texto que contiene caracteres especiales del español
  /// como tildes o 'ñ' que puedan venir con codificación incorrecta
  static String decodeText(String text) {
    if (text.isEmpty) {
      return text;
    }
    
    try {
      // Intenta decodificar el texto como UTF-8
      // Esto funciona si el texto fue codificado correctamente desde el servidor
      String decodedText = utf8.decode(latin1.encode(text));
      return decodedText;
    } catch (e) {
      // Si falla la decodificación, intenta un enfoque más específico para caracteres del español
      return _fixSpanishCharacters(text);
    }
  }
  
  /// Arregla manualmente los caracteres especiales del español
  static String _fixSpanishCharacters(String text) {
    // Mapa de caracteres especiales comúnmente mal codificados
    final Map<String, String> specialChars = {
      'Ã¡': 'á', 'Ã©': 'é', 'Ã­': 'í', 'Ã³': 'ó', 'Ãº': 'ú',
      'Ã': 'Á', 'Ã‰': 'É', 'Ã': 'Í', 'Ã"': 'Ó', 'Ãš': 'Ú',
      'Ã±': 'ñ', 'Ã': 'Ñ',
      'Ã¼': 'ü', 'Ãœ': 'Ü',
      'Ã¤': 'ä', 'Ã„': 'Ä',
      'Ã¶': 'ö', 'Ã–': 'Ö',
      '&amp;': '&',
      '&aacute;': 'á',
      '&eacute;': 'é',
      '&iacute;': 'í',
      '&oacute;': 'ó',
      '&uacute;': 'ú',
      '&ntilde;': 'ñ',
      '&Ntilde;': 'Ñ',
      '&Aacute;': 'Á',
      '&Eacute;': 'É',
      '&Iacute;': 'Í',
      '&Oacute;': 'Ó',
      '&Uacute;': 'Ú',
    };
    
    String result = text;
    specialChars.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    
    return result;
  }
} 