import 'package:flutter/material.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:raccoon_learning/presentation/widgets/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ModelManage {
  final DigitalInkRecognizerModelManager _modelManager =
      DigitalInkRecognizerModelManager();
  final String _modelKey = 'digital_ink_model_downloaded';
  Future<bool> _isModelDownloaded(String languageCode) async {
    // Check if the model is already downloaded
    return await _modelManager.isModelDownloaded(languageCode);
  }
  Future<void> _saveModelStatus(bool isDownloaded) async {
    // Save the model download status locally using SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_modelKey, isDownloaded);
  }
  Future<void> ensureModelDownloaded(String languageCode, BuildContext context) async {
    final isDownloaded = await _isModelDownloaded(languageCode);
    if (!isDownloaded) {
      // Notify user about download
       flutter_toast('Downloading model...', Colors.green);
      // Download the model
      final downloadSuccess = await _modelManager.downloadModel(languageCode);
      if (downloadSuccess) {
        await _saveModelStatus(true);
        flutter_toast('Model downloaded successfully!', Colors.green);

      } else {
        flutter_toast('Model download failed.', Colors.red);
      }
    }
  }
}