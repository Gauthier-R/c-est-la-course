import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  final apiKey = 'AIzaSyDKvoEuk51QOhgEi_gp_tjHGz_fXHQDY_k';
  
  final modelsToTest = [
    'gemini-1.5-flash',
    'gemini-1.5-flash-latest',
    'gemini-1.5-flash-002',
    'gemini-pro',
    'gemini-1.5-pro',
  ];

  for (final modelName in modelsToTest) {
    print('Testing $modelName...');
    try {
      final model = GenerativeModel(model: modelName, apiKey: apiKey);
      final response = await model.generateContent([Content.text('Hello')]);
      print('SUCCESS with $modelName: ${response.text}');
      break; 
    } catch (e) {
      print('FAILED $modelName: $e');
    }
  }
}
