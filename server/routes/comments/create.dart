import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  // 1. POST 요청만 허용
  if (context.request.method != HttpMethod.post) {
    return Response.json(statusCode: 405, body: {'error': 'Method not allowed'});
  }

  try {
    final pool = context.read<Pool>();
    
    // JSON 파싱 에러 방지를 위한 안전한 처리
    final String bodyString = await context.request.body();
    if (bodyString.isEmpty) {
        return Response.json(statusCode: 400, body: {'error': '데이터가 비어있습니다.'});
    }
    final body = jsonDecode(bodyString) as Map<String, dynamic>;

    // 2. 데이터 추출
    final postId = body['post_id'] as int?;
    final userId = body['user_id'] as int?;
    final content = body['content'] as String?;

    // 3. 필수 데이터 검증
    if (postId == null || userId == null || content == null || content.trim().isEmpty) {
      return Response.json(statusCode: 400, body: {'error': '필수 정보가 누락되었습니다.'});
    }

    // 4. DB 저장 및 ID 반환 (RETURNING id)
    final insertResult = await pool.execute(
      Sql.named('''
        INSERT INTO comments (post_id, user_id, content, created_at) 
        VALUES (@postId, @userId, @content, NOW())
        RETURNING id
      '''),
      parameters: {
        'postId': postId,
        'userId': userId,
        'content': content,
      },
    );

    if (insertResult.isEmpty) {
        throw Exception('댓글 저장 후 ID를 가져오지 못했습니다.');
    }
    
    // 생성된 댓글 ID (여기서 13 같은 숫자가 나옴)
    final newCommentId = insertResult.first[0] as int;

    // 5. 게시글의 댓글 수 증가
    await pool.execute(
      Sql.named('UPDATE posts SET comment_count = comment_count + 1 WHERE id = @postId'),
      parameters: {'postId': postId},
    );

    // ==========================================================
    // ✅ [핵심 수정] 성공 응답 반환 코드가 여기에 있어야 합니다!
    // ==========================================================
    return Response.json(
      statusCode: 201, 
      body: {
        'success': true, 
        'message': '댓글 작성 성공',
        'comment_id': newCommentId, // 13이 여기 들어갑니다
        'post_id': postId
      }
    );

  } catch (e) {
    print('🚨 댓글 작성 중 오류 발생: $e'); 
    return Response.json(
        statusCode: 500, 
        body: {'success': false, 'error': e.toString()}
    );
  }
}