# 🐾 PetFriend - Flutter 기반 반려동물 친구 매칭 서비스

## 📌 프로젝트 소개
PetFriend는 반려동물을 키우는 보호자들이 성향이 맞는 친구를 찾아 함께 활동할 수 있도록 돕는 서비스입니다.

## 🔧 기술 스택
- **Frontend/UI:** Flutter (Dart)
- **Backend/Database:** Supabase (PostgreSQL, Supabase Auth, Supabase Functions)
- **State Management:** Riverpod
- **Real-time Features:** Supabase Realtime (채팅, 매칭 시스템)
- **Location Services:** geolocator (위치 기반 필터링)
- **UI Library:** shadcn_flutter (ShadCN 스타일 UI)

## 📜 주요 기능
- 🐶 **반려동물 프로필 등록 및 관리**
- 🏡 **성향 기반 친구 매칭**
- 💬 **보호자 간 실시간 채팅**
- 📍 **위치 기반 보호자 검색**
- 🚨 **신고 및 차단 기능**

## 🛠️ 프로젝트 실행 방법
### 1. flutter 프로젝트 clone
Flutter SDK가 설치되어 있는지 확인 후, 프로젝트를 클론합니다:
```bash
git clone git@github.com:Udangtan/udangtan_flutter_app.git
cd udangtan_flutter_app
flutter pub get
```