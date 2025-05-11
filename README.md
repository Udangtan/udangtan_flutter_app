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

## 🎨 코드 스타일 & 협업 가이드
### 1. 코드 포맷팅 (Dart Format)
- flutter는 기본적으로 dart format 명령어를 제공하여 코드 스타일을 정리가 가능합니다.
- 명령어를 이용하여 자동 포멧 설정하기:
    ```bash
    dart format .
    ```
- 📌 **VS Code에서 자동 포맷 활성화**
  - settings.json 파일 (.vscode/settings.json)을 생성하고 다음을 추가:
      ```json
      {
        "[dart]": {
          "editor.formatOnSave": true
        }
      }
      ```
- 📌 **JetBrains (Android Studio, IntelliJ) 설정**
  - **Preferences > Languages & Frameworks > Dart → Format on Save** 체크
### 2. 린트 설정 (Flutter Lints)
- `flutter_lints` 패키지를 사용하여 코드 정적 분석을 실행합니다.(해당 패키지는 flutter 프로젝트 생성 시 default로 install되어 있습니다.)
- Dart 코드 스타일을 검사하고, 잘못된 코드를 자동으로 수정해 주기 위해 사용하는 라이브러리입니다.
- **lint rule**의 경우 `analysis_options.yaml` 파일에서 확인 가능합니다. 
- `analysis_options.yaml` 기반 lint 분석을 실행합니다:
    ```bash
    flutter analyze
    ```
- [flutter 코드 컨벤션 관련 참고 사이트](https://velog.io/@knh4300/flutter-%EC%BD%94%EB%93%9C-%EC%BB%A8%EB%B2%A4%EC%85%98)
- 프로젝트 내 적용한 lint 옵션 설명
  - **camel_case_types**: 클래스나 타입 이름은 PascalCase로 작성
  - **line_longer_than_80_chars**: 한 줄의 길이는 80자를 넘지 않아야 함
  - **package_api_docs**: 패키지 라이브러리 파일에는 문서 주석이 있어야 함(생각보다 문서화가 어려워서 주석처리함(사용 안하는 lint RULE))
  - **public_member_api_docs**: 공개 클래스의 멤버에는 문서 주석을 작성해야 함(생각보다 문서화가 어려워서 주석처리함(사용 안하는 lint RULE))
  - **always_use_package_imports**: 상대 경로 대신 패키지 경로 (import 'package:...') 사용
  - **avoid_dynamic_calls**: dynamic 타입의 변수를 함수처럼 호출하는 것을 방지
  - **avoid_empty_else**: 비어 있는 else 블록을 방지 (불필요한 코드 제거)
  - **avoid_print**: release 버전에서 print 호출 불가(print() 대신 Logger 같은 패키지 사용 권장)
    - 로그 필요 시 debugPrint 사용 또는 kDebugMode 값으로 분기 처리
  - **avoid_returning_null_for_future**: Future<void>에서 null 반환 금지 (대신 return Future.value() 사용
  - **avoid_slow_async_io**: 성능 저하를 유발하는 느린 I/O 함수 (File.readAsStringSync 등) 방지
  - **avoid_type_to_string**: .toString() 사용 시, 런타임 타입을 문자열로 변환하는 것 방지
  - **avoid_types_as_parameter_names**: 함수 매개변수로 타입명을 사용하지 않도록 제한
  - **cancel_subscriptions**: StreamSubscription을 사용한 후 반드시 cancel() 호출하도록 강제
  - **close_sinks**: StreamController 사용 후 반드시 close() 호출하도록 강제
  - **empty_statements**: 의미 없는 빈 세미콜론 (;) 사용 방지
  - **hash_and_equals**: Object.hashCode와 Object.equals를 함께 재정의하도록 강제
  - **no_adjacent_strings_in_list**: 리스트에서 문자열을 연속적으로 나열할 경우 + 연산자를 사용하도록 강제
  - **always_declare_return_types**: 모든 함수에서 반환 타입을 명시하도록 강제
  - **prefer_const_constructors**: 가능한 경우 const 생성자 사용을 권장
  - **always_require_non_null_named_parameters**: 모든 필수 named parameter를 required로 설정하도록 강제
  - **avoid_types_on_closure_parameters**: 람다 함수(익명 함수)에서 타입 명시 금지 ((int a) => a + 1 → (a) => a + 1)
  - **avoid_annotating_with_dynamic**: 명시적으로 dynamic을 사용하는 것 방지
  - **avoid_escaping_inner_quotes**: "와 '를 혼합해서 사용하지 않도록 제한
  - **avoid_function_literals_in_foreach_calls**: forEach() 내부에서 익명 함수 대신 for 루프 사용 권장
  - **avoid_private_typedef_functions**: typedef 정의에서 _(private) 사용 금지
  - **combinators_ordering**: import 'package:...';에 show, hide 키워드 사용 시 정렬 순서 강제
  - **curly_braces_in_flow_control_structures**: if, for, while 문에서 중괄호 {}를 항상 사용하도록 강제
  - **annotate_overrides**: @override가 필요한 경우 반드시 명시
  - **sort_constructors_first**: 클래스에서 생성자를 맨 위에 배치
  - **unawaited_futures**: await 없이 실행되는 Future가 있으면 경고
  - **directives_ordering**: import, export, part 순서를 강제
  - **unnecessary_final**: final 키워드가 불필요한 경우 제거 권장
  - **unnecessary_parenthesis**: 불필요한 괄호 제거 ((a + b) + c → a + b + c)
  - **conditional_uri_does_not_exist**: import에 존재하지 않는 URI 사용 방지
  - **prefer_single_quotes**: 문자열에서 '(작은따옴표) 사용 권장 ("Hello" → 'Hello')
  - **await_only_futures**: await를 Future가 아닌 곳에서 사용하지 않도록 강제
  - **comment_references**: 주석에서 /// [reference] 스타일을 강제
  - **prefer_void_to_null**: void 반환 타입에서 null을 반환하는 것 방지
  - **use_key_in_widget_constructors**: StatefulWidget, StatelessWidget 생성 시 Key를 항상 포함
### 3. Git Hooks 설정 (자동 포맷 & 린트 적용)
- 커밋하기 전에 코드 스타일을 자동으로 검사하기 위해 Git Hooks를 설정합니다.
- lefthook 사용하여 커밋 전 정적 코드 분석을 실행합니다.
1. Lefthook 설치
    ```bash
    brew install lefthook
    ```
2. lefthook.yml 파일 생성 및 설정
   - 프로젝트 루트(**.lefthook.yml**)에 Lefthook 설정 추가
      ```yaml
      pre-commit:
        parallel: true
        commands:
          format:
            run: dart format --set-exit-if-changed .
          lint:
            run: flutter analyze
      ```
3. Git Hooks에 Lefthook 적용
    ```bash
    lefthook install
    ```
   - 📌 **lefthook.yaml 파일이 수정될 때 마다 lefthook install 을 입력하여 git-hook과 싱크를 맞춰주어야 정상 동작합니다.**
