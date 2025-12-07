# 🧩 프로젝트 소개

Flutter 프론트엔드 + Dart Frog 백엔드 기반으로 개발한 커뮤니티 & 채팅 서비스 프로젝트입니다.

- 회원 인증 (JWT)
- 게시물 CRUD + 좋아요
- 댓글 시스템
- 채팅 Rooms + Messages
- 전문가 의뢰 기능
- 프로필/유저 관리

---

# 🔧 기술 스택  

## 🚀 Frontend (Flutter)
- Flutter 3.x
- Dart
- Provider
- REST API

## 🛠 Backend (Dart Frog)
- Dart Frog framework
- Middleware
- Request Context
- JWT Authentication
- REST API Architecture

---

# 📦 Backend 구조 (Dart Frog)

server/
└─ routes/
├─ auth/
│ ├─ signup.dart
│ └─ update.dart
├─ chats/
│ ├─ messages.dart
│ └─ rooms.dart
├─ comments/
│ ├─ create.dart
│ └─ read.dart
├─ expert/
│ └─ request.dart
├─ posts/
│ ├─ create.dart
│ ├─ delete.dart
│ ├─ index.dart
│ ├─ like.dart
│ ├─ read_one.dart
└─ users/
├─ [id].dart
└─ _middleware.dart
---
# 📁 Flutter 구조
lib/
├─ models/
├─ providers/
├─ screens/
└─ services/
└─ api_service.dart

---

# 🧪 주요 기능

### 🔐 Auth
- Signup
- Update user info
- JWT 인증

### 📝 Post
- Create
- Read
- Like
- Delete

### 💬 Chat
- 채팅방 목록
- 메시지 읽기/전송

### 💡 Expert
- 전문가 요청

### 👤 Users
- 유저 조회
- 프로필

---
