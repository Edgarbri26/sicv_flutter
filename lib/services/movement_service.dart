import 'dart:convert';
import 'package:sicv_flutter/config/api_url.dart';
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/models/movement/movement_model.dart';
import 'package:sicv_flutter/models/movement/movement_summary_model.dart';


class MovementService {
  final String baseUrl = ApiUrl().url;
  //final http.Client _client  MovementService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<MovementSummaryModel>> getAll() async {
    final uri = Uri.parse('$baseUrl/movement');    

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ...' // Si usas token, va aquí
        },
      ).timeout(const Duration(seconds: 10)); // CAMBIO 2: Timeout para no esperar eternamente
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);        
        
        // CAMBIO 3: Validación defensiva. Si 'data' es null, usamos lista vacía.
        final List<dynamic> movementListJson = (responseData['data'] as List<dynamic>?) ?? [];

        return movementListJson.map((json) {
          // CAMBIO 4: Usamos el factory del Resumen
          return MovementSummaryModel.fromJson(json as Map<String, dynamic>);
        }).toList();

      } else {
        // CAMBIO 5: Mostramos el mensaje del backend si existe
        final msg = json.decode(response.body)['message'] ?? 'Error desconocido';
        throw Exception('Error del servidor ($msg) - Código: ${response.statusCode}');
      }
    } catch (e) {
      // CAMBIO 6: IMPORTANTE
      // No ocultes el error original. Imprímelo y lánzalo para saber si es parseo o red.
      print("Error en getAll Movements: $e");
      throw Exception('Fallo al obtener movimientos: $e'); 
    } 
  }

  Future<MovementModel> getMovementById(int id) async {
    final uri = Uri.parse('$baseUrl/movement/$id');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic> movementJson = responseData['data'] as Map<String, dynamic>;

        return MovementModel.fromJson(movementJson);
      } else {
        throw Exception(
          'Error al cargar el movimiento (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Error de conexión al obtener el movimiento.');
    }
  }

  Future<MovementModel> create(MovementModel movement) async {
    final uri = Uri.parse('$baseUrl/movement');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(movement.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic> movementJson = responseData['data'] as Map<String, dynamic>;

        return MovementModel.fromJson(movementJson);
      } else {
        throw Exception(
          'Error al crear el movimiento (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Error de conexión al crear el movimiento.');
    }
  }
}