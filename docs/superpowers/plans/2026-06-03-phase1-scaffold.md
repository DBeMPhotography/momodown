# Phase 1: 项目脚手架与基础设施 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 从零初始化 Flutter 跨平台项目与 NestJS 后端服务，搭建 Material 3 主题系统、核心依赖、目录结构、以及基于 Docker 的本地开发环境，产出可编译运行的空壳 App 和可启动的后端服务。

**Architecture:** Clean Architecture + Feature-First 目录组织。所有全局基础设施收敛在 `lib/core/`，业务模块收敛在 `lib/features/`。后端采用 NestJS 模块化架构，通过 Docker Compose 一键启动 PostgreSQL 和 Redis。

**Tech Stack:** Flutter 3.22+, Dart 3, Riverpod 2.x, GoRouter, Dio, Isar, Material 3, NestJS 10, PostgreSQL 15, Redis 7, Docker

---

## File Structure (Phase 1 Output)

```
momodown/
├── android/
│   └── app/build.gradle          # minSdk 24
├── ios/
│   └── Runner/Info.plist         # 基础权限声明框架
├── lib/
│   ├── main.dart
│   ├── app.dart                  # MaterialApp + ProviderScope + 主题注入
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart    # ColorScheme + ThemeData 工厂
│   │   │   └── app_colors.dart   # 自定义语义颜色
│   │   ├── router/
│   │   │   └── app_router.dart   # GoRouter 配置
│   │   ├── network/
│   │   │   ├── dio_client.dart   # Dio 单例 + 拦截器
│   │   │   └── api_endpoints.dart
│   │   └── utils/
│   │       └── logger.dart       # 简易 Logger 包装
│   └── features/
│       └── placeholder.md        # 标记 Feature 目录占位
├── backend/
│   ├── src/
│   │   ├── app.module.ts
│   │   ├── main.ts
│   │   └── health/
│   │       ├── health.controller.ts
│   │       └── health.module.ts
│   ├── test/
│   │   └── app.e2e-spec.ts
│   ├── nest-cli.json
│   ├── package.json
│   ├── tsconfig.json
│   └── Dockerfile
├── docker-compose.yml            # PostgreSQL + Redis + pgAdmin
├── pubspec.yaml
├── analysis_options.yaml
└── test/
    └── widget_test.dart          # 验证 App 启动的 Widget 测试
```

---

## Prerequisites (执行本计划前请确认)

- [ ] Flutter SDK 3.22+ 已安装且 `flutter doctor` 无报错
- [ ] Node.js 20+ 与 pnpm 已安装
- [ ] Docker Desktop 已安装并运行
- [ ] Git 已配置用户名和邮箱

---

## Task 1: 初始化 Flutter 项目与版本配置

**Files:**
- Create: `pubspec.yaml` (由 flutter create 生成，后续修改)
- Create: `analysis_options.yaml`
- Modify: `android/app/build.gradle`

- [ ] **Step 1: 创建 Flutter 项目**

```bash
flutter create --org com.memodown --project-name momodown momodown
cd momodown
```

- [ ] **Step 2: 配置 Android 最低 SDK 版本**

修改 `android/app/build.gradle`，找到 `defaultConfig` 块：

```gradle
android {
    // ...
    defaultConfig {
        applicationId = "com.memodown.momodown"
        minSdk = 24          // 修改此行
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    // ...
}
```

- [ ] **Step 3: 配置 iOS 最低版本**

修改 `ios/Podfile`，找到第一行并取消注释修改：

```ruby
platform :ios, '13.0'
```

- [ ] **Step 4: 添加严格静态分析配置**

创建 `analysis_options.yaml`：

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    prefer_single_quotes: true
    prefer_const_constructors: true
    prefer_final_locals: true
    avoid_print: true
    always_use_package_imports: true
```

- [ ] **Step 5: 验证项目可编译**

```bash
flutter pub get
flutter analyze
flutter build apk --debug
```

Expected: `flutter analyze` 无错误，`flutter build apk` 成功生成 debug APK。

- [ ] **Step 6: 首次提交**

```bash
git init
git add .
git commit -m "chore: initialize Flutter project with momodown"
```

---

## Task 2: 集成核心 Flutter 依赖

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/core/utils/logger.dart`

- [ ] **Step 1: 在 pubspec.yaml 中添加核心依赖**

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management & Routing
  flutter_riverpod: ^2.5.1
  go_router: ^14.1.4

  # Network
  dio: ^5.4.3
  retrofit: ^4.1.0

  # Local Database
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1

  # Security & Storage
  flutter_secure_storage: ^9.2.2

  # Notifications
  flutter_local_notifications: ^17.1.2

  # Voice
  speech_to_text: ^6.6.0

  # Code Generation Helpers
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

  # UI
  google_fonts: ^6.2.1
  flutter_screenutil: ^5.9.3
  shimmer: ^3.0.0

  # Utils
  intl: ^0.19.0
  logger: ^2.3.0
  uuid: ^4.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

  # Code Generation
  build_runner: ^2.4.11
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  isar_generator: ^3.1.0+1
  retrofit_generator: ^8.1.0
```

- [ ] **Step 2: 安装依赖**

```bash
flutter pub get
```

Expected: 所有依赖成功解析，无版本冲突。

- [ ] **Step 3: 创建 Logger 工具类**

创建 `lib/core/utils/logger.dart`：

```dart
import 'package:logger/logger.dart';

final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);
```

- [ ] **Step 4: 验证分析器通过**

```bash
flutter analyze
```

Expected: 无错误，无警告（`avoid_print` 不会触发因为我们用了 Logger）。

- [ ] **Step 5: 提交**

```bash
git add pubspec.yaml pubspec.lock lib/core/utils/logger.dart analysis_options.yaml
git commit -m "chore: add core dependencies and logger utility"
```

---

## Task 3: 搭建 Material 3 主题系统（含深色模式）

**Files:**
- Create: `lib/core/theme/app_colors.dart`
- Create: `lib/core/theme/app_theme.dart`
- Modify: `lib/app.dart`

- [ ] **Step 1: 定义语义化颜色常量**

创建 `lib/core/theme/app_colors.dart`：

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Colors (清新绿系，符合效率工具调性)
  static const Color brandPrimary = Color(0xFF4CAF50);
  static const Color brandPrimaryContainer = Color(0xFFD8F5D9);
  static const Color brandOnPrimary = Color(0xFFFFFFFF);
  static const Color brandSecondary = Color(0xFF81C784);
  static const Color brandSecondaryContainer = Color(0xFFE8F5E9);

  // Functional Colors
  static const Color error = Color(0xFFB3261E);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color info = Color(0xFF1976D2);

  // Neutral (Material 3 Tonals)
  static const Color surface = Color(0xFFF8FAF8);
  static const Color onSurface = Color(0xFF1A1C1A);
  static const Color surfaceVariant = Color(0xFFDEE5DD);
  static const Color outline = Color(0xFF727972);

  // Dark Mode Overrides
  static const Color darkSurface = Color(0xFF1A1C1A);
  static const Color darkOnSurface = Color(0xFFE0E4E0);
  static const Color darkSurfaceVariant = Color(0xFF414941);
}
```

- [ ] **Step 2: 创建 ThemeData 工厂**

创建 `lib/core/theme/app_theme.dart`：

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return _baseTheme(Brightness.light).copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppColors.brandPrimary,
        onPrimary: AppColors.brandOnPrimary,
        primaryContainer: AppColors.brandPrimaryContainer,
        secondary: AppColors.brandSecondary,
        secondaryContainer: AppColors.brandSecondaryContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceVariant: AppColors.surfaceVariant,
        outline: AppColors.outline,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brandPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: AppColors.brandOnPrimary,
        elevation: 2,
      ),
    );
  }

  static ThemeData get darkTheme {
    return _baseTheme(Brightness.dark).copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brandPrimary,
        onPrimary: AppColors.brandOnPrimary,
        primaryContainer: Color(0xFF1B5E20),
        secondary: AppColors.brandSecondary,
        secondaryContainer: Color(0xFF2E4C31),
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        surfaceVariant: AppColors.darkSurfaceVariant,
        outline: AppColors.outline,
        error: Color(0xFFF2B8B5),
      ),
      scaffoldBackgroundColor: AppColors.darkSurface,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkOnSurface,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.darkSurfaceVariant.withOpacity(0.3),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brandPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: AppColors.brandOnPrimary,
        elevation: 2,
      ),
    );
  }

  static ThemeData _baseTheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
    );
  }
}
```

- [ ] **Step 3: 创建 App 根 Widget**

创建 `lib/app.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class MomoDownApp extends ConsumerWidget {
  const MomoDownApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: '墨墨记下',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
```

- [ ] **Step 4: 修改 main.dart**

修改 `lib/main.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MomoDownApp(),
    ),
  );
}
```

- [ ] **Step 5: 验证主题切换正常工作**

编写 Widget 测试 `test/widget_test.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momodown/app.dart';

void main() {
  testWidgets('App renders with Material 3 theme', (WidgetTester tester) async {
    await tester.pumpWidget(const MomoDownApp());

    // Verify MaterialApp uses Material 3
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.useMaterial3, isTrue);
    expect(materialApp.darkTheme?.useMaterial3, isTrue);

    // Verify app title
    expect(materialApp.title, '墨墨记下');
  });

  testWidgets('App supports system theme mode', (WidgetTester tester) async {
    await tester.pumpWidget(const MomoDownApp());

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.system);
  });
}
```

运行测试：

```bash
flutter test
```

Expected: 2 tests passed。

- [ ] **Step 6: 提交**

```bash
git add lib/app.dart lib/main.dart lib/core/theme/ test/widget_test.dart
git commit -m "feat: setup Material 3 theme system with dark mode support"
```

---

## Task 4: 配置 GoRouter 集中路由

**Files:**
- Create: `lib/core/router/app_router.dart`
- Create: `lib/core/constants/app_constants.dart`
- Create: `lib/features/placeholder.md`

- [ ] **Step 1: 定义路由路径常量**

创建 `lib/core/constants/app_constants.dart`：

```dart
class AppConstants {
  AppConstants._();

  // Route Names
  static const String routeHome = '/';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
}
```

- [ ] **Step 2: 配置 GoRouter**

创建 `lib/core/router/app_router.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppConstants.routeHome,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: AppConstants.routeHome,
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('墨墨记下 - 首页占位'),
        ),
      ),
    ),
    GoRoute(
      path: AppConstants.routeLogin,
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('登录页占位'),
        ),
      ),
    ),
    GoRoute(
      path: AppConstants.routeRegister,
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('注册页占位'),
        ),
      ),
    ),
  ],
);
```

- [ ] **Step 3: 创建 Feature 目录占位**

创建 `lib/features/placeholder.md`：

```markdown
# Features Directory

This directory contains all business features following Clean Architecture + Feature-First organization.

Planned features:
- auth/
- memo/
- accounting/
- voice/
- sync/
```

- [ ] **Step 4: 验证路由跳转正常**

在 `test/widget_test.dart` 中追加路由测试：

```dart
import 'package:go_router/go_router.dart';
import 'package:momodown/core/constants/app_constants.dart';

// Add to existing test file
testWidgets('GoRouter navigates to login page', (WidgetTester tester) async {
  await tester.pumpWidget(const MomoDownApp());

  // Verify initial route is home
  expect(find.text('墨墨记下 - 首页占位'), findsOneWidget);

  // Navigate to login
  final context = tester.element(find.byType(MaterialApp));
  GoRouter.of(context).go(AppConstants.routeLogin);
  await tester.pumpAndSettle();

  expect(find.text('登录页占位'), findsOneWidget);
});
```

运行测试：

```bash
flutter test
```

Expected: 3 tests passed。

- [ ] **Step 5: 提交**

```bash
git add lib/core/router/ lib/core/constants/ lib/features/ test/widget_test.dart
git commit -m "feat: setup GoRouter with placeholder routes and constants"
```

---

## Task 5: 搭建 Dio 网络客户端与拦截器

**Files:**
- Create: `lib/core/network/api_endpoints.dart`
- Create: `lib/core/network/dio_client.dart`

- [ ] **Step 1: 定义 API 端点常量**

创建 `lib/core/network/api_endpoints.dart`：

```dart
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL (开发环境使用本地后端或 ngrok 地址)
  static const String baseUrl = 'http://localhost:3000/api';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';

  // Memo
  static const String memos = '/memos';

  // Accounting
  static const String transactions = '/transactions';

  // Voice
  static const String parseVoice = '/voice/parse';

  // Sync
  static const String sync = '/sync';
}
```

- [ ] **Step 2: 创建 Dio 单例与拦截器**

创建 `lib/core/network/dio_client.dart`：

```dart
import 'package:dio/dio.dart';
import '../utils/logger.dart';
import 'api_endpoints.dart';

class DioClient {
  DioClient._();

  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => appLogger.d(obj.toString()),
      ),
      _ErrorInterceptor(),
    ]);

    return dio;
  }

  static void dispose() {
    _instance?.close();
    _instance = null;
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    appLogger.e(
      'DioError: ${err.requestOptions.method} ${err.requestOptions.path}',
      error: err.message,
      stackTrace: err.stackTrace,
    );

    // TODO: Token refresh logic will be added in Auth phase
    // TODO: Global error handling / snackbar will be added later

    handler.next(err);
  }
}
```

- [ ] **Step 3: 验证 Dio 配置**

编写单元测试 `test/unit/dio_client_test.dart`：

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momodown/core/network/api_endpoints.dart';
import 'package:momodown/core/network/dio_client.dart';

void main() {
  group('DioClient', () {
    test('instance returns singleton', () {
      final dio1 = DioClient.instance;
      final dio2 = DioClient.instance;
      expect(identical(dio1, dio2), isTrue);
    });

    test('baseUrl matches ApiEndpoints', () {
      final dio = DioClient.instance;
      expect(dio.options.baseUrl, ApiEndpoints.baseUrl);
    });

    test('default headers are set', () {
      final dio = DioClient.instance;
      expect(dio.options.headers['Content-Type'], 'application/json');
      expect(dio.options.headers['Accept'], 'application/json');
    });

    test('timeouts are configured', () {
      final dio = DioClient.instance;
      expect(dio.options.connectTimeout, const Duration(seconds: 10));
      expect(dio.options.receiveTimeout, const Duration(seconds: 10));
    });
  });
}
```

运行测试：

```bash
flutter test test/unit/dio_client_test.dart
```

Expected: 4 tests passed。

- [ ] **Step 4: 提交**

```bash
git add lib/core/network/ test/unit/
git commit -m "feat: setup Dio HTTP client with logging and error interceptors"
```

---

## Task 6: 初始化 NestJS 后端项目

**Files:**
- Create: `backend/package.json`
- Create: `backend/nest-cli.json`
- Create: `backend/tsconfig.json`
- Create: `backend/src/main.ts`
- Create: `backend/src/app.module.ts`
- Create: `backend/src/health/health.controller.ts`
- Create: `backend/src/health/health.module.ts`
- Create: `backend/test/app.e2e-spec.ts`
- Create: `backend/Dockerfile`

- [ ] **Step 1: 创建 NestJS 项目骨架**

在 `backend/` 目录下创建 `package.json`：

```json
{
  "name": "momodown-backend",
  "version": "0.1.0",
  "description": "墨墨记下后端 API 服务",
  "author": "",
  "private": true,
  "license": "UNLICENSED",
  "scripts": {
    "build": "nest build",
    "format": "prettier --write \"src/**/*.ts\" \"test/**/*.ts\"",
    "start": "nest start",
    "start:dev": "nest start --watch",
    "start:debug": "nest start --debug --watch",
    "start:prod": "node dist/main",
    "lint": "eslint \"{src,apps,libs,test}/**/*.ts\" --fix",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:cov": "jest --coverage",
    "test:debug": "node --inspect-brk -r tsconfig-paths/register -r ts-node/register node_modules/.bin/jest --runInBand",
    "test:e2e": "jest --config ./test/jest-e2e.json"
  },
  "dependencies": {
    "@nestjs/common": "^10.3.0",
    "@nestjs/core": "^10.3.0",
    "@nestjs/platform-express": "^10.3.0",
    "@nestjs/swagger": "^7.3.0",
    "@nestjs/terminus": "^10.2.0",
    "reflect-metadata": "^0.2.1",
    "rxjs": "^7.8.1"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.3.0",
    "@nestjs/schematics": "^10.1.0",
    "@nestjs/testing": "^10.3.0",
    "@types/express": "^4.17.21",
    "@types/jest": "^29.5.11",
    "@types/node": "^20.10.0",
    "@types/supertest": "^6.0.2",
    "@typescript-eslint/eslint-plugin": "^6.15.0",
    "@typescript-eslint/parser": "^6.15.0",
    "eslint": "^8.56.0",
    "eslint-config-prettier": "^9.1.0",
    "eslint-plugin-prettier": "^5.1.0",
    "jest": "^29.7.0",
    "prettier": "^3.1.1",
    "source-map-support": "^0.5.21",
    "supertest": "^6.3.3",
    "ts-jest": "^29.1.0",
    "ts-loader": "^9.5.0",
    "ts-node": "^10.9.2",
    "tsconfig-paths": "^4.2.0",
    "typescript": "^5.3.3"
  },
  "jest": {
    "moduleFileExtensions": ["js", "json", "ts"],
    "rootDir": "src",
    "testRegex": ".*\\.spec\\.ts$",
    "transform": {
      "^.+\\.(t|j)s$": "ts-jest"
    },
    "collectCoverageFrom": ["**/*.(t|j)s"],
    "coverageDirectory": "../coverage",
    "testEnvironment": "node"
  }
}
```

- [ ] **Step 2: 创建 NestJS 配置文件**

创建 `backend/nest-cli.json`：

```json
{
  "$schema": "https://json.schemastore.org/nest-cli",
  "collection": "@nestjs/schematics",
  "sourceRoot": "src",
  "compilerOptions": {
    "deleteOutDir": true
  }
}
```

创建 `backend/tsconfig.json`：

```json
{
  "compilerOptions": {
    "module": "commonjs",
    "declaration": true,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "allowSyntheticDefaultImports": true,
    "target": "ES2021",
    "sourceMap": true,
    "outDir": "./dist",
    "baseUrl": "./",
    "incremental": true,
    "skipLibCheck": true,
    "strictNullChecks": false,
    "noImplicitAny": false,
    "strictBindCallApply": false,
    "forceConsistentCasingInFileNames": false,
    "noFallthroughCasesInSwitch": false
  }
}
```

- [ ] **Step 3: 创建入口文件和根模块**

创建 `backend/src/main.ts`：

```typescript
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix('api');
  app.enableCors({
    origin: '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    credentials: true,
  });
  await app.listen(3000);
  console.log(`🚀 墨墨记下后端服务已启动: http://localhost:3000/api`);
}
bootstrap();
```

创建 `backend/src/app.module.ts`：

```typescript
import { Module } from '@nestjs/common';
import { HealthModule } from './health/health.module';

@Module({
  imports: [HealthModule],
})
export class AppModule {}
```

- [ ] **Step 4: 创建 Health Check 模块**

创建 `backend/src/health/health.controller.ts`：

```typescript
import { Controller, Get } from '@nestjs/common';
import {
  HealthCheck,
  HealthCheckService,
} from '@nestjs/terminus';

@Controller('health')
export class HealthController {
  constructor(private health: HealthCheckService) {}

  @Get()
  @HealthCheck()
  check() {
    return this.health.check([]);
  }
}
```

创建 `backend/src/health/health.module.ts`：

```typescript
import { Module } from '@nestjs/common';
import { TerminusModule } from '@nestjs/terminus';
import { HealthController } from './health.controller';

@Module({
  imports: [TerminusModule],
  controllers: [HealthController],
})
export class HealthModule {}
```

- [ ] **Step 5: 创建 Dockerfile**

创建 `backend/Dockerfile`：

```dockerfile
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine

WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./

EXPOSE 3000

CMD ["node", "dist/main"]
```

- [ ] **Step 6: 创建 E2E 测试骨架**

创建 `backend/test/jest-e2e.json`：

```json
{
  "moduleFileExtensions": ["js", "json", "ts"],
  "rootDir": ".",
  "testEnvironment": "node",
  "testRegex": ".e2e-spec.ts$",
  "transform": {
    "^.+\\.(t|j)s$": "ts-jest"
  }
}
```

创建 `backend/test/app.e2e-spec.ts`：

```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from './../src/app.module';

describe('AppController (e2e)', () => {
  let app: INestApplication;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('/api/health (GET)', () => {
    return request(app.getHttpServer())
      .get('/api/health')
      .expect(200)
      .expect((res) => {
        expect(res.body.status).toBe('ok');
      });
  });

  afterEach(async () => {
    await app.close();
  });
});
```

- [ ] **Step 7: 安装后端依赖并验证**

```bash
cd backend
npm install
npm run build
npm run start:dev
```

在另一个终端验证健康检查：

```bash
curl http://localhost:3000/api/health
```

Expected: `{"status":"ok","info":{},"error":{},"details":{}}`

停止 dev 服务器（Ctrl+C）。

- [ ] **Step 8: 提交**

```bash
cd ..
git add backend/
git commit -m "chore: initialize NestJS backend with health check module"
```

---

## Task 7: 配置 Docker Compose 本地开发环境

**Files:**
- Create: `docker-compose.yml`
- Create: `.env.example`

- [ ] **Step 1: 创建 Docker Compose 配置**

在项目根目录创建 `docker-compose.yml`：

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: momodown-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: momodown
      POSTGRES_PASSWORD: momodown_dev
      POSTGRES_DB: momodown
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U momodown -d momodown"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: momodown-redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 5

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: momodown-pgadmin
    restart: unless-stopped
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@momodown.com
      PGADMIN_DEFAULT_PASSWORD: admin
    ports:
      - "5050:80"
    depends_on:
      postgres:
        condition: service_healthy

volumes:
  postgres_data:
  redis_data:
```

- [ ] **Step 2: 创建环境变量模板**

创建 `.env.example`：

```bash
# Database
DATABASE_URL=postgresql://momodown:momodown_dev@localhost:5432/momodown

# Redis
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

# AI API Keys (选择你使用的供应商)
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
QWEN_API_KEY=
```

- [ ] **Step 3: 启动本地基础设施**

```bash
docker-compose up -d
```

验证服务状态：

```bash
docker-compose ps
```

Expected: `postgres`、`redis`、`pgadmin` 三个容器均显示 `Up (healthy)` 或 `Up`。

验证数据库连接：

```bash
docker exec -it momodown-postgres psql -U momodown -d momodown -c "\dt"
```

Expected: 无表（空数据库），命令成功执行。

验证 Redis：

```bash
docker exec -it momodown-redis redis-cli ping
```

Expected: `PONG`

- [ ] **Step 4: 提交**

```bash
git add docker-compose.yml .env.example
git commit -m "chore: add Docker Compose for local PostgreSQL, Redis and pgAdmin"
```

---

## Task 8: 最终集成验证与 Phase 1 收尾

**Files:**
- Modify: `README.md`

- [ ] **Step 1: 运行全量 Flutter 测试**

```bash
flutter test
flutter analyze
```

Expected: 所有测试通过，分析器零错误。

- [ ] **Step 2: 验证 Flutter App 可运行在模拟器**

```bash
# 确保有模拟器或真机连接
flutter devices
flutter run
```

Expected: App 启动，显示「墨墨记下 - 首页占位」文字，支持系统深色模式切换。

- [ ] **Step 3: 验证后端服务可独立启动**

```bash
cd backend
npm run build
npm run start:prod
```

在另一个终端：

```bash
curl http://localhost:3000/api/health
```

Expected: `{"status":"ok"...}`

停止 prod 服务（Ctrl+C）。

- [ ] **Step 4: 创建项目 README**

创建/更新 `README.md`：

```markdown
# 墨墨记下 (MemoDown)

跨平台个人效率工具：备忘 + 记账 + AI 语音输入。

## 技术栈

- **前端**: Flutter 3.22+, Riverpod, GoRouter, Dio, Isar
- **后端**: NestJS 10, PostgreSQL, Redis
- **AI**: 大模型意图识别 (Claude / GPT / 通义千问)

## 快速开始

### 1. 启动本地基础设施

```bash
docker-compose up -d
```

### 2. 启动后端

```bash
cd backend
npm install
npm run start:dev
```

### 3. 启动前端

```bash
flutter pub get
flutter run
```

## 开发规范

- 遵循 Clean Architecture + Feature-First 目录结构
- 所有业务逻辑必须可单元测试
- 提交前运行 `flutter analyze` 和 `flutter test`
```

- [ ] **Step 5: Phase 1 最终提交**

```bash
git add README.md
git commit -m "docs: add project README with quickstart guide"
```

---

## Self-Review Checklist

**1. Spec coverage:**
- [x] Flutter 项目初始化与版本配置（Task 1）
- [x] 核心依赖集成：Riverpod, GoRouter, Dio, Isar, secure_storage, local_notifications, speech_to_text（Task 2）
- [x] Material 3 主题系统 + 深色模式（Task 3）
- [x] GoRouter 集中路由配置（Task 4）
- [x] Dio HTTP 客户端 + 拦截器（Task 5）
- [x] NestJS 后端骨架 + Health Check（Task 6）
- [x] Docker Compose 本地开发环境（Task 7）
- [x] 集成验证与文档（Task 8）

**2. Placeholder scan:**
- [x] 无 TBD/TODO 占位步骤
- [x] 所有代码块包含完整可运行代码
- [x] 所有命令包含预期输出

**3. Type consistency:**
- [x] `DioClient.instance` 单例模式在全文中一致
- [x] `AppConstants` 路由常量与 `app_router.dart` 使用一致
- [x] `ApiEndpoints.baseUrl` 与 NestJS `main.ts` 的 3000 端口一致

---

## Phase 1 完成标准

- [ ] `flutter analyze` 零错误
- [ ] `flutter test` 全部通过（至少 7 个测试）
- [ ] `flutter run` 可在 iOS/Android 模拟器启动
- [ ] 后端 `npm run build` 成功
- [ ] `curl http://localhost:3000/api/health` 返回 `{"status":"ok"}`
- [ ] `docker-compose ps` 显示 postgres、redis、pgadmin 运行中
- [ ] Git 仓库包含至少 8 个有意义的提交
