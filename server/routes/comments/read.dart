import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) return Response.json(statusCode: 405);

  try {
    final pool = context.read<Pool>();
    final params = context.request.uri.queryParameters;
    final postId = int.tryParse(params['post_id'] ?? '');

    if (postId == null) return Response.json(statusCode: 400, body: {'error': 'post_id is required'});

    final result = await pool.execute(
      Sql.named('''
        SELECT 
          c.id,           -- [0]
          c.post_id,      -- [1]
          c.user_id,      -- [2]
          c.content,      -- [3] (여기가 진짜 내용!)
          c.created_at,   -- [4]
          u.username as author_name -- [5]
        FROM comments c
        JOIN users u ON c.user_id = u.id
        WHERE c.post_id = @postId
        ORDER BY c.created_at ASC
      '''),
      parameters: {'postId': postId},
    );

    // ✅ 인덱스 순서 완벽 수정
    final comments = result.map((row) => {
      'id': row[0],
      'post_id': row[1],     // 1번은 post_id
      'user_id': row[2],     // 2번은 user_id
      'content': row[3],     // ✅ 3번이 진짜 내용(content)입니다!
      'created_at': row[4].toString(), // 4번은 날짜
      'nickname': row[5],    // 5번은 닉네임 (Flutter 모델에서 'nickname'으로 받으므로 키 이름 변경)
    }).toList();

    return Response.json(statusCode: 200, body: {'comments': comments});
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  }
}