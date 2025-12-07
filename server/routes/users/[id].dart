// routes/users/[id].dart
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response.json(statusCode: 405, body: {'error': 'Method not allowed'});
  }

  try {
    final pool = context.read<Pool>();
    final userId = int.tryParse(id);

    if (userId == null) {
      return Response.json(statusCode: 400, body: {'error': 'Invalid User ID'});
    }

    // 비밀번호와 토큰은 제외하고 조회
    final result = await pool.execute(
      Sql.named('''
        SELECT id, email, name, username, certificate_path, role, created_at
        FROM users WHERE id = @id
      '''),
      parameters: {'id': userId},
    );

    if (result.isEmpty) {
      return Response.json(statusCode: 404, body: {'error': 'User not found'});
    }

    final user = result.first;
    return Response.json(
      statusCode: 200,
      body: {
        'user': {
          'id': user[0],
          'email': user[1],
          'name': user[2],
          'username': user[3],
          'certificate_path': user[4],
          'role': user[5],
          'created_at': user[6].toString(),
        }
      },
    );
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  }
}