# 墨墨记下 (MemoDown) — Phase 1: 项目脚手架与基础设施

> 执行模式：Subagent-Driven（子代理驱动）  
> 指挥官：用户（DBeM）  
> 规划来源：`docs/superpowers/plans/2026-06-03-phase1-scaffold.md`

---

## 前置检查（开始 Phase 1 前请确认）

- [ ] Flutter SDK 3.22+ 已安装且 `flutter doctor` 无报错
- [ ] Node.js 20+ 与 pnpm / npm 已安装
- [ ] Docker Desktop 已安装并运行
- [ ] Git 已配置用户名和邮箱

---

## Task 1: 初始化 Flutter 项目与版本配置

- [ ] Step 1: 创建 Flutter 项目 `momodown`
- [ ] Step 2: 配置 Android `minSdk = 24`
- [ ] Step 3: 配置 iOS `platform :ios, '13.0'`
- [ ] Step 4: 添加 `analysis_options.yaml` 严格静态分析配置
- [ ] Step 5: 验证 `flutter analyze` 零错误 + `flutter build apk --debug` 成功
- [ ] Step 6: 首次 Git 提交

---

## Task 2: 集成核心 Flutter 依赖

- [ ] Step 1: 在 `pubspec.yaml` 中添加核心依赖（Riverpod, GoRouter, Dio, Isar 等）
- [ ] Step 2: 运行 `flutter pub get`
- [ ] Step 3: 创建 `lib/core/utils/logger.dart`
- [ ] Step 4: 验证 `flutter analyze` 通过
- [ ] Step 5: Git 提交

---

## Task 3: 搭建 Material 3 主题系统（含深色模式）

- [ ] Step 1: 创建 `lib/core/theme/app_colors.dart`（语义化颜色常量）
- [ ] Step 2: 创建 `lib/core/theme/app_theme.dart`（ThemeData 工厂：light/dark）
- [ ] Step 3: 创建 `lib/app.dart`（MaterialApp.router + ProviderScope）
- [ ] Step 4: 修改 `lib/main.dart`
- [ ] Step 5: 编写 Widget 测试验证主题与深色模式，运行 `flutter test`
- [ ] Step 6: Git 提交

---

## Task 4: 配置 GoRouter 集中路由

- [ ] Step 1: 创建 `lib/core/constants/app_constants.dart`（路由路径常量）
- [ ] Step 2: 创建 `lib/core/router/app_router.dart`（GoRouter 配置 + 占位页面）
- [ ] Step 3: 创建 `lib/features/placeholder.md`
- [ ] Step 4: 编写路由跳转 Widget 测试，运行 `flutter test`
- [ ] Step 5: Git 提交

---

## Task 5: 搭建 Dio 网络客户端与拦截器

- [ ] Step 1: 创建 `lib/core/network/api_endpoints.dart`
- [ ] Step 2: 创建 `lib/core/network/dio_client.dart`（单例 + LogInterceptor + ErrorInterceptor）
- [ ] Step 3: 编写单元测试 `test/unit/dio_client_test.dart`
- [ ] Step 4: 运行 `flutter test test/unit/dio_client_test.dart`
- [ ] Step 5: Git 提交

---

## Task 6: 初始化 NestJS 后端项目

- [ ] Step 1: 创建 `backend/package.json`
- [ ] Step 2: 创建 `backend/nest-cli.json` + `backend/tsconfig.json`
- [ ] Step 3: 创建 `backend/src/main.ts` + `backend/src/app.module.ts`
- [ ] Step 4: 创建 Health Check 模块（controller + module）
- [ ] Step 5: 创建 `backend/Dockerfile`
- [ ] Step 6: 创建 E2E 测试骨架 `backend/test/app.e2e-spec.ts`
- [ ] Step 7: `npm install` + `npm run build` + `npm run start:dev`，验证 `/api/health` 返回 `{"status":"ok"}`
- [ ] Step 8: Git 提交

---

## Task 7: 配置 Docker Compose 本地开发环境

- [ ] Step 1: 创建 `docker-compose.yml`（PostgreSQL + Redis + pgAdmin）
- [ ] Step 2: 创建 `.env.example`
- [ ] Step 3: 启动 `docker-compose up -d`
- [ ] Step 4: 验证 postgres 健康检查 + redis-cli ping 返回 PONG
- [ ] Step 5: Git 提交

---

## Task 8: 最终集成验证与 Phase 1 收尾

- [ ] Step 1: 运行全量 Flutter 测试 `flutter test` + `flutter analyze`
- [ ] Step 2: 验证 Flutter App 在模拟器/真机启动（显示首页占位）
- [ ] Step 3: 验证后端 `npm run start:prod` + Health Check
- [ ] Step 4: 创建/更新 `README.md`
- [ ] Step 5: Phase 1 最终 Git 提交

---

## Phase 1 完成标准（全部打勾才算完成）

- [ ] `flutter analyze` 零错误
- [ ] `flutter test` 全部通过（≥ 7 个测试）
- [ ] `flutter run` 可在 iOS/Android 模拟器启动
- [ ] 后端 `npm run build` 成功
- [ ] `curl http://localhost:3000/api/health` 返回 `{"status":"ok"}`
- [ ] `docker-compose ps` 显示 postgres、redis、pgadmin 运行中
- [ ] Git 仓库包含 ≥ 8 个有意义的提交
