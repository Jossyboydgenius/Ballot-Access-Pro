import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get googleMapsApiKey => 
    dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  
  // ... other env variables
} 