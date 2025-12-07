import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  // 1. DB 연결 객체 가져오기
  final pool = context.read<Pool>();
  print('/chats/rooms 요청 받음!');

  // ==========================================
  // [POST] 채팅방 생성 (채팅하기 버튼 눌렀을 때)
  // ==========================================
  if (context.request.method == HttpMethod.post) {
    try {
      final body = await context.request.json() as Map<String, dynamic>;
      final myId = body['my_id'];
      final otherId = body['other_id'];
       print('채팅방 생성 요청: 내ID=$myId, 상대ID=$otherId');
      // ID 정렬 (작은 숫자가 앞으로 오게 해서 중복 방지)
      final u1 = (myId < otherId) ? myId : otherId;
      final u2 = (myId < otherId) ? otherId : myId;

      // 이미 방이 있는지 확인
      final existing = await pool.execute(
        Sql.named('SELECT id FROM chat_rooms WHERE user1_id = @u1 AND user2_id = @u2'),
        parameters: {'u1': u1, 'u2': u2},
      );

      // 이미 있으면 그 방 ID 리턴
      if (existing.isNotEmpty) {
        return Response.json(body: {'room_id': existing.first[0]});
      }

      // 없으면 새로 생성 후 ID 리턴
      final result = await pool.execute(
        Sql.named('INSERT INTO chat_rooms (user1_id, user2_id) VALUES (@u1, @u2) RETURNING id'),
        parameters: {'u1': u1, 'u2': u2},
      );
      
      return Response.json(body: {'room_id': result.first[0]});
    } catch (e) {
      print('채팅방 생성 에러: $e'); // 서버 로그에 에러 출력
      return Response.json(statusCode: 500, body: {'error': e.toString()});
    }
  }

  // ==========================================
  // [GET] 내 채팅방 목록 조회 (채팅 탭)
  // ==========================================
  if (context.request.method == HttpMethod.get) {
    try {
      final params = context.request.uri.queryParameters;
      if (!params.containsKey('user_id')) {
        return Response.json(statusCode: 400, body: {'error': 'user_id is required'});
      }
      
      final userId = int.parse(params['user_id']!);

      final result = await pool.execute(
        Sql.named('''
          SELECT r.id, 
                 CASE WHEN r.user1_id = @me THEN u2.name ELSE u1.name END as other_name,
                 CASE WHEN r.user1_id = @me THEN u2.id ELSE u1.id END as other_id
          FROM chat_rooms r
          JOIN users u1 ON r.user1_id = u1.id
          JOIN users u2 ON r.user2_id = u2.id
          WHERE r.user1_id = @me OR r.user2_id = @me
          ORDER BY r.created_at DESC
        '''),
        parameters: {'me': userId},
      );

      final rooms = result.map((row) => {
        'room_id': row[0],
        'other_name': row[1],
        'other_id': row[2],
      }).toList();

      return Response.json(body: {'rooms': rooms});
    } catch (e) {
      print('채팅 목록 조회 에러: $e');
      return Response.json(statusCode: 500, body: {'error': e.toString()});
    }
  }

  return Response.json(statusCode: 405);
}