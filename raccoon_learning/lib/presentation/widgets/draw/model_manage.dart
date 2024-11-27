import 'package:flutter/material.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
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

  Future<bool> _getModelStatus() async {
    // Retrieve the model download status from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_modelKey) ?? false;
  }

  Future<void> ensureModelDownloaded(String languageCode, BuildContext context) async {
    final isDownloaded = await _isModelDownloaded(languageCode);
    if (!isDownloaded) {
      // Notify user about download
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloading model for $languageCode...')),
      );

      // Download the model
      final downloadSuccess = await _modelManager.downloadModel(languageCode);
      if (downloadSuccess) {
        await _saveModelStatus(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Model downloaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Model download failed.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Model already downloaded.')),
      );
    }
  }
}
