import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// SpeechService class to handle speech-to-text functionality
class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ValueNotifier<bool> isListeningNotifier = ValueNotifier(false); // Notifier for listening state
  final ValueNotifier<String> textNotifier = ValueNotifier('Press and hold to start listening'); // Notifier for recognized text
  final ValueNotifier<String> localeIdNotifier = ValueNotifier('vi_VN'); // Notifier for current language (default: Vietnamese)

  SpeechService() {
    _initSpeech();
  }

  // Initialize the speech-to-text service
  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          isListeningNotifier.value = false;
        }
      },
      onError: (val) {
        isListeningNotifier.value = false;
        textNotifier.value = 'Listening failed';
      },
    );
    if (!available) {
      textNotifier.value = 'Unable to use voice recognition';
    }
  }

  // Start listening for speech input with the specified language
  Future<void> startListening(Function(String) onResult) async {
    if (!isListeningNotifier.value) {
      bool available = await _speech.initialize();
      if (available) {
        isListeningNotifier.value = true;
        textNotifier.value = 'Listening...';
        _speech.listen(
          onResult: (val) {
            String result = val.recognizedWords.isNotEmpty ? val.recognizedWords : 'Listening...';
            result = normalizeVoiceText(result);
            textNotifier.value = result;
            onResult(result);
          },
          localeId: localeIdNotifier.value, // Use the current localeId (VN or EN)
        );
      } else {
        textNotifier.value = 'Unable to use voice recognition';
      }
    }
  }

  // Stop listening for speech input
  void stopListening() {
    if (isListeningNotifier.value) {
      _speech.stop();
      isListeningNotifier.value = false;
      defaultText();
    }
  }

  // Reset the text to the default message
  void defaultText() {
    textNotifier.value = '';
    textNotifier.value = 'Press and hold to start listening';
  }

  // Update the language for speech recognition
  void updateLanguage(bool isVN) {
    localeIdNotifier.value = isVN ? 'vi_VN' : 'en_US';
  }

  // Dispose of the speech service
  void dispose() {
    _speech.stop();
  }
}

// Normalize the recognized text (e.g., convert spoken numbers to digits)
String normalizeVoiceText(String input) {
  switch (input.toLowerCase().trim()) {
    case 'một':
    case 'mot':  
      return '1';

    case 'hai':
    case 'hay': 
    case 'hài': 
    case 'hái': 
    case 'haii':
    case 'hi':  
      return '2';

    case 'ba':
    case 'bà':
    case 'bã': 
    case 'baaa': 
      return '3';

    case 'bốn':
    case 'bon': 
    case 'bôn': 
    case 'bốnn': 
    case 'bong':  
      return '4';

    case 'năm':
    case 'lam': 
    case 'nắm': 
    case 'nam': 
    case 'lăm':  
      return '5';

    case 'sáu':
    case 'sao': 
    case 'sấu': 
    case 'sấuu': 
    case 'xáu':  
      return '6';

    case 'bảy':
    case 'bay': 
    case 'bẫy': 
    case 'bẩy': 
    case 'bầy':  
      return '7';

    case 'tám':
    case 'tam': 
    case 'tắm': 
    case 'támn': 
      return '8';

    case 'chín':
    case 'chin': 
    case 'chím': 
    case 'chinn':  
      return '9';

    case 'mười':
    case 'muoi': 
    case 'mườiii': 
    case 'mưới':  
      return '10';

    // Compare symbols
    case 'dấu bằng':
    case 'bằng':
    case 'bằngg':
    case 'bàn':  
    case 'bang':  
      return '=';

    case 'dấu lớn hơn':
    case 'lớn hơn':
    case 'lớn':
    case 'lơn':
    case 'lớnn':
    case 'lớn hơnn':
    case 'lướn':
      return '>';

    case 'dấu nhỏ hơn':
    case 'nhỏ hơn':
    case 'nhỏ':
    case 'nho':
    case 'nhó':
    case 'nhỏn':
    case 'nhở':
    case 'nhõ':
      return '<';

      // English numbers (1 to 12)
    case 'one':
    case 'one number':
      return '1';
    case 'two':
    case 'two number':
      return '2';
    case 'three':
    case 'three number':
      return '3';
    case 'four':
    case 'four number':
    case 'phone number':
      return '4';
    case 'five':
    case 'five number':
      return '5';
    case 'six':
    case 'six number':
      return '6';
    case 'seven':
    case 'seven number':
      return '7';
    case 'eight':
    case 'eight number':
    case 'it':
      return '8';
    case 'nine':
    case 'nine number':
      return '9';
    case 'ten':
    case 'ten number':
      return '10';
    case 'eleven':
    case 'eleven number':
      return '11';
    case 'twelve':
    case 'twelve number':
      return '12';

    // English comparison symbols (already added in previous response, included here for completeness)
    case 'equals':
    case 'equal':
      return '=';
    case 'greater than':
    case 'bigger than':
    case 'bigger':


      return '>';
    case 'less than':
    case 'smaller than':
    case 'smaller':


      return '<';

    default:
      return input; 
  }
}