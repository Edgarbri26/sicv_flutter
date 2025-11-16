import 'dart:convert';
import 'package:sicv_flutter/config/api_url.dart';
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/models/movement_model.dart';


class MovementService {
  final String baseUrl = ApiUrl().url;
  //final http.Client _client  MovementService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<MovementModel>> getAllMovements() async {
    final uri = Uri.parse('$baseUrl/movement');    

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );      
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body) as Map<String, dynamic>;        
        final List<dynamic> movimentListJson = responseData['data'] as List<dynamic>;

        return movimentListJson
          .map((json) => MovementModel.fromJson(json as Map<String, dynamic>))
          .toList();

      } else {
        throw Exception(
          'Error al cargar la lista de movimientos (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Error de conexión al obtener los movimientos.');
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

  Future<MovementModel> createMovement(MovementModel movement) async {
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