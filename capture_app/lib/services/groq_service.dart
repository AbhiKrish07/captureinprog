import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/capture.dart';

class GroqService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  /// Formats the user's captures into a system prompt for the AI to understand as its "knowledge base"
  static String _buildSystemPrompt(List<Capture> captures) {
    StringBuffer sb = StringBuffer();
    sb.writeln("You are Capture AI, a helpful 'Second Brain' assistant.");
    sb.writeln("You have access to the user's saved notes, voice memos, and documents.");
    sb.writeln("Here is the context of what the user has stored in their Capture database:\n");
    
    if (captures.isEmpty) {
      sb.writeln("The database is currently empty.");
    } else {
      for (var capture in captures) {
        sb.writeln("---");
        sb.writeln("Type: ${capture.type}");
        sb.writeln("Title: ${capture.title ?? 'Untitled'}");
        sb.writeln("Content: ${capture.content}");
      }
      sb.writeln("---");
    }
    
    sb.writeln("\nWhen the user asks you a question, use this context to provide accurate answers. Keep your answers concise but helpful.");
    return sb.toString();
  }

  /// Sends a message to the Groq API, using the database captures as system context
  static Future<String> sendMessage(String userMessage, List<Capture> captures) async {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    
    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_GROQ_API_KEY_HERE') {
      return "Please configure your Groq API Key in the .env file.";
    }

    final systemPrompt = _buildSystemPrompt(captures);

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile', // using a versatile model, alternatively 'llama3-8b-8192'
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return "Error from AI API: ${response.statusCode}\n${response.body}";
      }
    } catch (e) {
      return "Failed to connect to AI API: $e";
    }
  }
}
