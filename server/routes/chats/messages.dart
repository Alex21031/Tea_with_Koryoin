import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final pool = context.read<Pool>();

  // [POST] 메시지 전송 + 알림 생성
  if (context.request.method == HttpMethod.post) {
    try {
      final body = await context.request.json() as Map<String, dynamic>;
      final roomId = body['room_id'];
      final senderId = body['sender_id'];
      final content = body['content'];

      // 1. 메시지 저장
      await pool.execute(
        Sql.named('INSERT INTO messages (room_id, sender_id, content) VALUES (@roomId, @senderId, @content)'),
        parameters: {
          'roomId': roomId,
          'senderId': senderId,
          'content': content,
        },
      );


      return Response.json(statusCode: 201);
    } catch (e) {
      return Response.json(statusCode: 500, body: {'error': e.toString()});
    }
  }

  // [GET] 메시지 목록 조회 (기존 유지)
  if (context.request.method == HttpMethod.get) {
    final params = context.request.uri.queryParameters;
    final roomId = int.parse(params['room_id']!);

    final result = await pool.execute(
      Sql.named('''
        SELECT id, sender_id, content, created_at 
        FROM messages 
        WHERE room_id = @roomId 
        ORDER BY created_at ASC
      '''),
      parameters: {'roomId': roomId},
    );

    final messages = result.map((row) => {
      'id': row[0],
      'sender_id': row[1],
      'content': row[2],
      'created_at': row[3].toString(),
    }).toList();

    return Response.json(body: {'messages': messages});
  }

  return Response.json(statusCode: 405);
}