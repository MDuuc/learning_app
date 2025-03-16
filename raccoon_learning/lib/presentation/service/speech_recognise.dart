import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ValueNotifier<bool> isListeningNotifier = ValueNotifier(false);
  final ValueNotifier<String> textNotifier = ValueNotifier('Press and hold to start listening');

  SpeechService() {
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          isListeningNotifier.value = false;
        }
      },
      onError: (val) {
        isListeningNotifier.value = false;
        textNotifier.value = 'Error: $val';
      },
    );
    if (!available) {
      textNotifier.value = 'Unable to use voice recognition';
    }
  }

  Future<void> startListening(Function(String) onResult, {String localeId = 'vi_VN'}) async {
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
          localeId: localeId,
        );
      } else {
        textNotifier.value = 'Unable to use voice recognition';
      }
    }
  }

  void stopListening() {
    if (isListeningNotifier.value) {
      _speech.stop();
      isListeningNotifier.value = false;
      defaultText();
    }
  }

  void defaultText(){
    textNotifier.value = '';
    textNotifier.value= 'Press and hold to start listening';
  }

  void dispose() {
    _speech.stop();
  }
}

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

    // Compare
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

    default:
      return input; 
  }
}


