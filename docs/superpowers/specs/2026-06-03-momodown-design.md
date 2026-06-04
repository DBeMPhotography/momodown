# 墨墨记下 (MemoDown) — 项目架构与设计规格

> 版本：v1.0  
> 日期：2026-06-03  
> 状态：设计已确认，待转入实现规划

---

## 1. 项目概述

**App 名称**：墨墨记下（MemoDown）  
**定位**：跨平台（Android / iOS）综合类个人效率工具，聚焦「备忘 + 记账 + AI 语音输入」。  
**核心特色**：用户通过一句话语音输入，App 借助本地语音识别 + 云端大模型解析，自动生成待办事项或记账条目。

**技术栈**：
- 跨平台框架：Flutter 3.22+ (Dart 3)
- 状态管理：Riverpod 2.x
- 本地数据库：Isar 3.x
- UI 风格：Material 3，现代简洁，支持深色模式
- 后端：自建 RESTful API（推荐 NestJS / FastAPI）+ PostgreSQL + Redis

---

## 2. 整体架构设计

### 2.1 架构哲学

采用 **「Clean Architecture + Feature-First 目录组织」** 的混合模式：

- **逻辑上**严格遵循 Clean Architecture 的三层边界，确保业务规则独立于框架和 UI。
- **物理上**按 Feature 分箱组织代码，每个功能模块（auth、memo、accounting、voice）内部自包含，便于未来高频迭代和插件化扩展。

### 2.2 前端（Flutter）三层架构

| 层级 | 职责 | 技术实现 |
|---|---|---|
| **Presentation 层** | UI Widget、页面状态管理、路由、用户交互 | Riverpod Notifier / AsyncNotifier + GoRouter |
| **Domain 层** | 实体定义、业务规则、Repository 接口、UseCase | 纯 Dart 类，零外部依赖 |
| **Data 层** | Repository 实现、数据持久化、网络通信、DTO 转换 | Isar（本地）、Dio（网络） |

**关键架构决策：**

1. **Offline-First 策略**：所有用户写入操作先持久化到 Isar 本地数据库，Riverpod 状态立即响应 UI；后台 `SyncService` 将本地变更队列异步推送到服务器。网络异常时自动重试，恢复连接后批量同步。
2. **实时同步机制**：登录后建立 WebSocket / SSE 长连接，接收服务端推送的其他设备变更。冲突解决策略 v1 采用「服务器时间戳优先」，本地冲突数据标记为 `needs_review`，后续版本提供手动合并 UI。
3. **AI 语音管道**：
   - 本地 ASR（`speech_to_text` / Android SpeechRecognizer）将语音转为文字；
   - App 将文字封装为 `VoiceCommand` 领域对象，提交后端 `/voice/parse`；
   - 后端调用大模型 API（Claude / GPT / 通义千问）进行意图识别和实体抽取，返回结构化 JSON（`MemoIntent` 或 `TransactionIntent`）；
   - App 接收后通过 Riverpod 状态机自动路由到对应 Feature 的表单填充页。
4. **模块化扩展**：未来新增功能（如番茄钟、习惯打卡）时，只需在 `lib/features/` 下新建一个 Feature 目录，遵循同样的三层结构，即可「插电板式」接入，不污染现有模块。

### 2.3 推荐目录结构

```
momodown/
├── android/                    # Android 原生配置
├── ios/                        # iOS 原生配置
├── lib/
│   ├── main.dart
│   ├── app.dart                # MaterialApp / 主题注入 / ProviderScope
│   ├── core/                   # 全局基础设施
│   │   ├── constants/          # 常量、枚举、路由名称
│   │   ├── theme/              # Material 3 ColorScheme、Typography、深色模式适配
│   │   ├── router/             # GoRouter 集中配置、路由守卫
│   │   ├── network/            # Dio 单例、拦截器（Token 刷新、统一错误处理）
│   │   ├── services/           # 全局服务
│   │   │   ├── sync_engine.dart      # 实时同步引擎
│   │   │   ├── websocket_manager.dart # WebSocket 连接管理
│   │   │   └── local_notification_service.dart
│   │   └── utils/              # 扩展方法、日期/金额格式化、验证器
│   ├── features/               # 按功能模块划分
│   │   ├── auth/               # 登录注册
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart    # 接口
│   │   │   │   └── usecases/
│   │   │   │       ├── login.dart
│   │   │   │       └── register.dart
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── user_dto.dart
│   │   │   │   │   └── token_response.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_api.dart           # Dio 网络请求
│   │   │   │   │   └── auth_local_data_source.dart  # SecureStorage
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── auth_notifier.dart
│   │   │       ├── pages/
│   │   │       │   ├── login_page.dart
│   │   │       │   └── register_page.dart
│   │   │       └── widgets/
│   │   ├── memo/               # 备忘 / 待办 / 提醒
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── memo.dart
│   │   │   │   │   └── reminder.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── memo_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── create_memo.dart
│   │   │   │       ├── update_memo.dart
│   │   │   │       └── delete_memo.dart
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── memo_dto.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── memo_api.dart
│   │   │   │   │   └── memo_dao.dart         # Isar 本地操作
│   │   │   │   └── repositories/
│   │   │   │       └── memo_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── memo_list_notifier.dart
│   │   │       ├── pages/
│   │   │       │   ├── memo_list_page.dart
│   │   │       │   └── memo_detail_page.dart
│   │   │       └── widgets/
│   │   │           ├── memo_card.dart
│   │   │           └── reminder_picker.dart
│   │   ├── accounting/         # 记账模块
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── transaction.dart
│   │   │   │   │   └── category.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── transaction_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── add_transaction.dart
│   │   │   │       └── get_monthly_summary.dart
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── accounting_api.dart
│   │   │   │   │   └── accounting_dao.dart
│   │   │   │   └── repositories/
│   │   │   │       └── transaction_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── pages/
│   │   │       │   ├── accounting_page.dart
│   │   │       │   └── add_transaction_sheet.dart
│   │   │       └── widgets/
│   │   ├── voice/              # 语音输入 & AI 解析（核心特色）
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── voice_command.dart
│   │   │   │   │   └── parsed_intent.dart    # MemoIntent / TransactionIntent
│   │   │   │   ├── repositories/
│   │   │   │   │   └── voice_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       └── parse_voice_command.dart
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── voice_api.dart        # 提交后端解析
│   │   │   │   │   └── local_stt_service.dart # 本地语音识别封装
│   │   │   │   └── repositories/
│   │   │   │       └── voice_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── voice_input_notifier.dart
│   │   │       ├── pages/
│   │   │       │   └── voice_input_page.dart
│   │   │       └── widgets/
│   │   │           ├── voice_button.dart
│   │   │           ├── recording_animation.dart
│   │   │           └── parsing_result_view.dart
│   │   └── sync/               # 实时同步引擎（跨 Feature 基础设施）
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   │   ├── sync_queue_item.dart
│   │       │   │   └── sync_conflict.dart
│   │       │   └── repositories/
│   │       │       └── sync_repository.dart
│   │       ├── data/
│   │       │   ├── datasources/
│   │       │   │   ├── sync_api.dart
│   │       │   │   └── sync_dao.dart
│   │       │   └── repositories/
│   │       │       └── sync_repository_impl.dart
│   │       └── presentation/
│   │           └── widgets/
│   │               └── sync_status_indicator.dart
│   └── shared/                 # 跨 Feature 的轻量共享层
│       ├── widgets/            # 通用 UI 组件
│       │   ├── empty_state.dart
│       │   ├── loading_shimmer.dart
│       │   └── error_retry_widget.dart
│       └── models/             # 基础共享模型
│           ├── paginated_list.dart
│           └── api_response.dart
├── backend/                    # 自建后端服务（独立目录）
│   ├── src/
│   │   ├── auth/               # JWT 认证、注册登录 API
│   │   ├── memo/               # 备忘 CRUD API
│   │   ├── accounting/         # 记账 API
│   │   ├── voice/              # 语音命令接收 -> 调用 AI 服务 -> 返回结构化意图
│   │   ├── sync/               # WebSocket / SSE 同步服务、变更推送
│   │   └── ai/                 # 大模型调用封装（支持多模型切换、Prompt 模板管理）
│   ├── prisma/                 # 数据库 Schema（如用 Node.js）
│   ├── docker-compose.yml      # 本地开发一键起 PostgreSQL + Redis
│   └── Dockerfile
├── test/                       # 单元测试、Widget 测试、集成测试
│   ├── unit/
│   ├── widget/
│   └── integration/
├── docs/                       # API 文档、UI 原型、数据库设计图
├── assets/
│   ├── images/
│   ├── fonts/
│   └── lottie/                 # 动画资源
└── pubspec.yaml
```

### 2.4 后端架构概览

- **API 网关层**：NestJS / FastAPI 提供 RESTful API，统一处理认证、限流、日志。
- **业务层**：按 Feature 划分 Service（`AuthService`、`MemoService`、`VoiceService`），与前端目录保持同构。
- **AI 代理层**：`AiService` 封装大模型调用，通过 Prompt Template 将用户自然语言转为结构化 JSON Schema。支持多模型热切换（如通义千问用于日常、Claude 用于复杂意图）。
- **数据层**：PostgreSQL 作为主库持久化用户数据；Redis 用于会话缓存（JWT Blacklist）、实时同步消息队列。
- **实时通信**：WebSocket 或 SSE 长连接，推送多端数据变更。

---

## 3. 核心功能模块拆解（MVP 阶段）

MVP 原则：**只保留「能完整跑通一个用户场景」的最小功能集**，非核心功能明确延后。

### 3.1 认证模块（Auth）

**MVP 实现：**
- 邮箱注册 / 登录（含密码强度校验）
- JWT AccessToken + RefreshToken 双令牌机制
- Token 本地安全存储（`flutter_secure_storage`）
- Dio 拦截器自动附加 Token 及静默刷新
- 全局路由守卫：未登录态拦截至登录页

**V2+ 延后：**
- 手机号 + 验证码登录
- 微信 OAuth 快捷登录
- 忘记密码 / 重置密码
- 多设备管理与在线状态展示

### 3.2 备忘 / 待办模块（Memo）

**MVP 实现：**
- 创建 / 编辑 / 删除文本备忘（标题 + 内容）
- 设置单次提醒时间（日期时间选择器）
- 备忘列表页（按创建时间倒序）
- 备忘详情页
- 本地 Isar 存储 + 后台同步
- 本地通知提醒（`flutter_local_notifications`）

**V2+ 延后：**
- 图片 / 语音附件
- 富文本编辑（Markdown / 简单排版）
- 标签系统与颜色分类
- 全文搜索
- 重复提醒规则（每天 / 每周 / 自定义）

### 3.3 记账模块（Accounting）— MVP 简化版

**MVP 实现：**
- 一笔记账：金额（数字键盘）、收支类型（收入/支出）、分类（预设枚举：餐饮、交通、购物等）、备注
- 收支记录列表（按日期分组）
- 当月汇总卡片：总收入 / 总支出 / 结余（基于 Isar 本地查询）
- 通过语音输入自动填充记账表单

**V2+ 延后：**
- 多账本管理
- 预算设定与超支提醒
- 资产账户（微信/支付宝/现金/银行卡）
- 图表统计（饼图、折线图趋势）
- 数据导出（Excel / CSV）

### 3.4 语音输入模块（Voice）— 核心亮点

**MVP 实现：**
- 长按浮动按钮 / 底部栏麦克风图标进入录音状态
- 调用设备本地语音识别 API（iOS `speech_to_text` / Android `SpeechRecognizer`）
- 实时展示转写文字，支持取消手势
- 用户确认后，将文本 + 上下文（当前时间、位置可选）打包为 JSON
- 提交后端 `/voice/parse` API
- 后端调用 LLM 解析，返回统一意图格式：
  ```json
  {
    "intent_type": "memo" | "transaction",
    "confidence": 0.95,
    "payload": {
      // memo: { title, content, reminder_at }
      // transaction: { amount, type, category, note, occurred_at }
    }
  }
  ```
- App 根据 `intent_type` 自动路由并预填充对应表单
- 用户二次确认后保存

**V2+ 延后：**
- 离线本地意图识别（TinyML / 规则引擎兜底）
- 连续对话式语音交互
- 语音唤醒（免手点）
- 多意图拆分：一句话中包含多个操作自动拆分执行

### 3.5 实时同步模块（Sync）

**MVP 实现：**
- 登录成功后自动全量拉取云端数据到本地 Isar
- 任何本地 CUD 操作生成 `SyncQueueItem`（含操作类型、表名、记录 ID、时间戳）
- 网络可用时，`SyncEngine` 按序批量推送队列到后端
- 接收服务端 WebSocket 推送的其他设备变更，写入本地
- 冲突解决 v1：服务器时间戳优先，本地被覆盖数据写入 `ConflictLog`，标记 `needs_review`

**V2+ 延后：**
- 增量同步（Delta Sync）优化大数据量场景
- 离线冲突手动合并 UI（三向对比）
- 多端实时协作（共享账本 / 共享待办）

### 3.6 设置模块（Settings）

**MVP 实现：**
- 深色 / 浅色 / 跟随系统 主题切换
- 退出登录并清理本地数据

**V2+ 延后：**
- 数据导出 / 导入（JSON / Excel）
- 通知偏好设置（声音、震动、免打扰时段）
- 生物识别锁屏（指纹 / FaceID）
- 语言切换

---

## 4. 开发路线图（MVP → 打包）

预估总工期：**6-8 周**（单人全职开发）。

### Phase 1：项目脚手架与基础设施（Week 1）

- [ ] `flutter create momodown` 初始化项目
- [ ] 配置 Android（`minSdk 24`）和 iOS（`iOS 13+`）最小支持版本
- [ ] 配置 `analysis_options.yaml`（严格模式，推荐 `very_good_analysis`）
- [ ] 搭建 Material 3 主题系统：定义 `ColorScheme`、`Typography`、深色模式适配
- [ ] 集成核心依赖：`flutter_riverpod`、`go_router`、`dio`、`isar`、`isar_flutter_libs`、`freezed_annotation`、`json_serializable`、`flutter_secure_storage`、`flutter_local_notifications`、`speech_to_text`
- [ ] 搭建 `lib/core/` 基础设施：Dio 单例（含 LogInterceptor）、全局 Router、自定义 ErrorHandler
- [ ] 后端项目脚手架：NestJS `nest new backend` 或 FastAPI 项目结构，配置 TypeScript / Pydantic、数据库连接、基础中间件（CORS、Helmet、压缩）
- [ ] 本地开发环境 Docker Compose：PostgreSQL + Redis + pgAdmin

### Phase 2：本地数据层与认证模块（Week 1-2）

- [ ] 设计并定义 Isar Schema：`User`、`Memo`、`Transaction`、`SyncQueueItem`
- [ ] 后端数据库 Schema 设计与迁移（Prisma / Alembic）
- [ ] 实现 Auth Feature 完整链路：
  - UI：`LoginPage`、`RegisterPage`（Material 3 风格）
  - State：`AuthNotifier`（Riverpod AsyncNotifier）
  - Domain：`User` 实体、`AuthRepository` 接口
  - Data：`AuthRepositoryImpl` → `AuthApi`（Dio）+ `AuthLocalDataSource`（SecureStorage）
- [ ] JWT 管理：登录后持久化 AccessToken + RefreshToken；Dio 拦截器自动附加 Token；401 时静默刷新
- [ ] 全局路由守卫：监听 `authStateChanges`，未登录态重定向至 `/login`

### Phase 3：备忘模块与语音输入原型（Week 2-3）

- [ ] Memo Feature 完整数据流：
  - `MemoListPage` + `MemoDetailPage`
  - `MemoRepository`（本地 Isar + 远程 API 双实现）
  - 创建 / 编辑 / 删除备忘录
- [ ] 提醒功能：`flutter_local_notifications` 集成，支持设置具体提醒时间
- [ ] 语音输入原型：
  - 集成 `speech_to_text`，处理权限申请（麦克风）
  - 录音 UI：长按按钮、波纹动画、取消手势区域
  - 转写结果展示，用户确认后提交后端
- [ ] 后端 `/voice/parse` 初版 API：接收文本 → 调用 LLM API → 返回硬编码或简化意图

### Phase 4：记账模块与实时同步（Week 3-4）

- [ ] Accounting Feature：
  - 收支分类预设枚举（餐饮、交通、购物、工资等）
  - `AddTransactionSheet`（底部弹出表单，数字键盘优化）
  - 收支列表（按日期倒序分组）
  - 当月汇总卡片（收入 / 支出 / 结余）
- [ ] 同步引擎 `SyncService`：
  - 任何 Isar 写操作后自动生成 `SyncQueueItem`
  - 定时器 + 网络状态监听触发同步
  - 批量上传变更记录，接收服务端确认后清理队列
- [ ] WebSocket 长连接：
  - 登录后建立连接，订阅用户私有频道
  - 接收服务端推送的变更事件，写入本地 Isar
- [ ] 冲突解决 v1：服务端时间戳优先，本地生成 `ConflictLog`

### Phase 5：AI 深度集成与打磨（Week 5）

- [ ] 后端 AI 模块完善：
  - Prompt Engineering：设计稳定的 System Prompt，要求 LLM 严格按 JSON Schema 输出
  - 支持意图分类：`create_memo`、`create_transaction`、`unknown`
  - 实体抽取：时间（NLP 时间解析）、金额、分类、备注
- [ ] 语音输入体验优化：
  - 录音动画（Lottie 或 CustomPainter 声波效果）
  - 网络超时 / 解析失败的重试与降级提示
  - 解析结果预览页：高亮识别出的关键信息（时间、金额），用户可手动修正
- [ ] 空状态、加载态、错误态 UI 统一（参考竞品截图风格）
- [ ] 性能优化：Isar 查询索引、列表懒加载（`ListView.builder`）

### Phase 6：测试、构建与打包（Week 6-7）

- [ ] **单元测试**：Domain 层 UseCase、Repository 核心逻辑（Mock 数据源）
- [ ] **Widget 测试**：`LoginPage`、`MemoListPage`、`AddTransactionSheet` 的渲染和交互流
- [ ] **集成测试**：完整用户场景端到端测试（注册 → 语音创建备忘 → 设置提醒 → 记账 → 同步）
- [ ] iOS 配置：
  - Apple Developer 证书与 Provisioning Profile
  - `Info.plist` 权限声明（麦克风、通知）
  - 真机调试、Release 模式性能测试
- [ ] Android 配置：
  - 生成签名密钥：`keytool -genkey -v -keystore upload-keystore.jks`
  - `android/app/build.gradle` 发布配置、`proguard-rules.pro`
  - 权限声明：`RECORD_AUDIO`、`INTERNET`、`RECEIVE_BOOT_COMPLETED`
- [ ] 品牌物料：
  - App 图标（`flutter_launcher_icons`）
  - 启动屏（`flutter_native_splash`）
- [ ] 构建 Release 包：
  - Android：`flutter build apk --release` / `flutter build appbundle --release`
  - iOS：`flutter build ipa --release`
- [ ] 内测分发：TestFlight（iOS）、Firebase App Distribution（Android）

---

## 5. 本地开发环境配置清单

### 5.1 必需环境

| 组件 | 版本 / 要求 | 说明与验证命令 |
|---|---|---|
| **Flutter SDK** | 3.22+（Stable Channel） | `flutter doctor` 需全部通过（特别是 Android toolchain 和 Xcode） |
| **Dart SDK** | 随 Flutter 捆绑 | 需支持 Dart 3（记录模式、类修饰符） |
| **Android Studio** | 最新稳定版 | 用于 Android 模拟器 + SDK 管理 + Gradle 同步 |
| **Android SDK** | API 34+，最低 API 24 | 包含：Command Line Tools、Platform Tools、Build Tools、Android Emulator |
| **Xcode** | 15+ | macOS 必备，包含 iOS 模拟器、Swift 工具链、`xcrun` |
| **CocoaPods** | 1.15+ | iOS 依赖管理：`sudo gem install cocoapods` |
| **Git** | 2.40+ | 版本控制 |

### 5.2 后端开发环境（Node.js / NestJS 方案）

| 组件 | 版本 / 要求 |
|---|---|
| **Node.js** | 20 LTS+ |
| **pnpm**（推荐）或 yarn / npm | pnpm 8+ |
| **PostgreSQL** | 15+ |
| **Redis** | 7+ |
| **Docker** | 24+ |
| **Docker Compose** | 2.20+ |

> **本地启动命令**：`docker-compose up -d`（启动 PostgreSQL + Redis + pgAdmin）

### 5.3 IDE 与插件

- **推荐 IDE**：VS Code（轻量、插件丰富）或 Android Studio（Flutter 深度集成）
- **必装 VS Code 插件**：
  - `Dart`（官方）
  - `Flutter`（官方）
  - `Riverpod Snippets`（快速生成 Provider 模板）
  - `Flutter Tree` 或 `Awesome Flutter Snippets`
  - `Error Lens`（实时显示代码错误）
- **调试工具**：Isar Inspector（独立桌面应用，可视化查看本地数据库内容）
- **推荐设置**：
  ```json
  {
    "editor.formatOnSave": true,
    "editor.rulers": [80, 120],
    "dart.lineLength": 100,
    "dart.previewFlutterUiGuides": true
  }
  ```

### 5.4 账号与第三方服务（开发前准备）

| 服务 | 用途 | 优先级 | 备注 |
|---|---|---|---|
| **Apple Developer**（$99/年） | iOS 真机调试 + TestFlight 分发 | P0 | 打包 iOS 必需 |
| **Google Play Developer**（$25 一次性） | Android 应用商店上架 | P1 | MVP 内测可延后 |
| **大模型 API Key** | 后端 AI 意图解析 | P0 | 推荐至少准备 2 个供应商（如通义千问 + Claude）用于对比和容灾 |
| **云服务器 / 域名** | 后端部署 + HTTPS | P1 | 内测阶段可用局域网 / ngrok / 云开发函数 |
| **Firebase 项目** | Crashlytics 崩溃分析、App Distribution | P2 | 可选，但推荐早期接入 |

---

## 6. 关键技术决策记录（ADR）

| 决策 | 选项 | 选择 | 理由 |
|---|---|---|---|
| 状态管理 | Riverpod / Bloc / GetX | **Riverpod** | 编译时安全、依赖注入原生支持、与 Flutter 3 深度整合 |
| 本地数据库 | Isar / Hive / Drift / SQFlite | **Isar** | 高性能（比 Hive 快 10x+）、类型安全、内置复合索引、支持 Full-Text Search（未来扩展） |
| 路由 | Navigator 2.0 / GoRouter / AutoRoute | **GoRouter** | 声明式、深度链接友好、与 Riverpod 配合简洁 |
| 后端语言 | NestJS / FastAPI / Go Gin | **NestJS 或 FastAPI** | 生态成熟、AI 库（Python）或企业级架构（Node.js）友好，待项目初始化时最终确认 |
| 语音识别 | 云端 ASR / 本地 STT | **本地 STT** | 降低延迟、保护隐私、减少流量；仅 NLP 理解走云端 |
| 同步策略 | 实时同步 / 手动同步 | **实时同步** | 用户体验更佳，技术实现通过 WebSocket + 本地队列可控 |

---

## 7. 风险与缓解

| 风险 | 影响 | 缓解措施 |
|---|---|---|
| **本地语音识别准确率**（方言、噪音环境） | 高 | 设计「语音 → 文字 → 用户确认」流程，允许手动修正后再提交 AI；后期可接入云端 ASR 作为备选 |
| **AI 意图解析稳定性**（LLM 输出格式不一致） | 高 | 严格的 System Prompt + JSON Schema 约束 + 后端输出校验，失败时返回 `unknown` 类型让用户手动选择 |
| **实时同步冲突** | 中 | MVP 采用服务器优先策略，后期引入三向合并 UI |
| **iOS 审核**（麦克风权限说明、AI 功能披露） | 中 | 提前在 `Info.plist` 中详细说明麦克风用途；在 App 描述中明确 AI 功能由云端处理 |
| **跨平台 UI 一致性** | 低 | 严格遵循 Material 3 设计规范，自定义组件库保证双端一致 |

---

*本规格文档已获确认，下一步：转入 `writing-plans` 阶段，生成可执行的详细实现计划。*
