import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) return Response.json(statusCode: 405);
  
  try {
    final pool = context.read<Pool>();
    final params = context.request.uri.queryParameters;
    final postId = params['id'];

    if (postId == null) return Response.json(statusCode: 400);

    final result = await pool.execute(
      Sql.named('''
        SELECT 
          p.id, p.user_id, p.title, p.content, p.category, 
          p.created_at, p.views, p.likes, u.username,
          (SELECT COUNT(*)::int FROM comments c WHERE c.post_id = p.id) as comment_count
        FROM posts p
        JOIN users u ON p.user_id = u.id
        WHERE p.id = @id
      '''),
      parameters: {'id': int.parse(postId)},
    );

    if (result.isEmpty) return Response.json(statusCode: 404, body: {'error': 'Post not found'});

    final row = result.first;
    final post = {
      'id': row[0],
      'user_id': row[1],
      'title': row[2],
      'content': row[3],
      'category': row[4],
      'created_at': (row[5] as DateTime).toIso8601String(),
      'views': row[6] ?? 0,
      'likes': row[7] ?? 0,
      'author_name': row[8],
      'comment_count': row[9] ?? 0,
    };

    return Response.json(body: {'post': post});
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  }
}