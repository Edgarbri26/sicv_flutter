// import 'dart:convert';

// import 'package:sicv_flutter/config/api_url.dart';
// import 'package:http/http.dart' as http;
// import 'package:sicv_flutter/models/moviment_model.dart';


// class MovimentService {
//   final String baseUrl = ApiUrl().url;
//   final http.Client _client;

//   MovimentService({http.Client? client}) : _client = client ?? http.Client();

//   Future<List<MovimentModel>> getAllMoviments() async {
//     final uri = Uri.parse('$baseUrl/movement');

//     try {
//       final response = await _client.get(
//         uri,
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData =
//             json.decode(response.body) as Map<String, dynamic>;

//         final List<dynamic> movimentListJson =
//             responseData['data'] as List<dynamic>;

//         return movimentListJson
//             .map((json) => MovimentModel.fromJson(json as Map<String, dynamic>))
//             .toList();
//       } else {
//         throw Exception(
//           'Error al cargar la lista de movimientos (Código: ${response.statusCode})',
//         );
//       }
//     } catch (e) {
//       print(e.toString());
//       throw Exception('Error de conexión al obtener los movimientos.');
//     }
//   }

// }
