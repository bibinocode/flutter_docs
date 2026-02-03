# AppFlowy - 开源 Notion 替代品

## 项目概览

| 项目信息 | 详情 |
|---------|------|
| **GitHub** | [AppFlowy-IO/AppFlowy](https://github.com/AppFlowy-IO/AppFlowy) |
| **Star** | 60k+ |
| **平台** | Android, iOS, macOS, Windows, Linux, Web |
| **状态管理** | BLoC Pattern |
| **主要功能** | 笔记、文档、数据库、协作 |

## 技术栈

### 核心技术
- **Flutter** + **Dart**
- **Rust** (后端核心 - appflowy_backend)
- **状态管理**: flutter_bloc + freezed
- **数据存储**: SQLite (通过 Rust)
- **富文本编辑**: 自研 AppFlowy Editor

### 依赖包
```yaml
dependencies:
  flutter_bloc: ^8.1.5          # 状态管理
  freezed_annotation: ^2.4.1    # 不可变模型
  equatable: ^2.0.5             # 值对象比较
  dartz: ^0.10.1                # 函数式编程
  get_it: ^7.6.7                # 依赖注入
  go_router: ^14.0.0            # 路由管理
  
  # 自研包
  appflowy_editor: ^3.0.0       # 富文本编辑器
  appflowy_backend: ^0.0.1      # Rust FFI
```

## 项目结构

```
frontend/appflowy_flutter/
├── lib/
│   ├── core/                   # 核心功能
│   │   ├── config/            # 应用配置
│   │   └── notification/      # 通知系统
│   ├── plugins/                # 插件系统
│   │   ├── document/          # 文档插件
│   │   │   ├── bloc/         # BLoC 层
│   │   │   ├── presentation/ # UI 层
│   │   │   └── domain/       # 领域层
│   │   ├── database/          # 数据库插件
│   │   └── blank/             # 空白页插件
│   ├── workspace/              # 工作区管理
│   │   ├── application/       # 应用层
│   │   │   └── workspace_bloc.dart
│   │   ├── domain/            # 领域层
│   │   └── presentation/      # 展示层
│   ├── user/                   # 用户模块
│   │   ├── application/
│   │   ├── domain/
│   │   └── presentation/
│   ├── mobile/                 # 移动端适配
│   │   └── presentation/
│   ├── shared/                 # 共享组件
│   │   └── widgets/
│   ├── startup/                # 启动配置
│   │   ├── startup.dart
│   │   └── deps_resolver.dart
│   └── main.dart
├── rust-lib/                   # Rust 核心库
│   └── appflowy_backend/
└── packages/                   # 内部包
    └── appflowy_editor/        # 编辑器
```

## 学习要点

### 1. BLoC 状态管理模式

AppFlowy 采用标准的 BLoC 模式：

```dart
// 1. 定义 Event
@freezed
class DocumentEvent with _$DocumentEvent {
  const factory DocumentEvent.initial() = Initial;
  const factory DocumentEvent.restore() = Restore;
  const factory DocumentEvent.update(Document document) = Update;
  const factory DocumentEvent.delete() = Delete;
}

// 2. 定义 State
@freezed
class DocumentState with _$DocumentState {
  const factory DocumentState({
    required Document? document,
    required bool isLoading,
    required Option<String> error,
  }) = _DocumentState;
  
  factory DocumentState.initial() => DocumentState(
    document: null,
    isLoading: true,
    error: none(),
  );
}

// 3. 实现 BLoC
class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DocumentService _service;
  
  DocumentBloc(this._service) : super(DocumentState.initial()) {
    on<Initial>(_onInitial);
    on<Update>(_onUpdate);
    on<Delete>(_onDelete);
  }
  
  Future<void> _onInitial(Initial event, Emitter<DocumentState> emit) async {
    final result = await _service.loadDocument();
    result.fold(
      (error) => emit(state.copyWith(error: some(error))),
      (document) => emit(state.copyWith(
        document: document, 
        isLoading: false,
      )),
    );
  }
}

// 4. 使用 BlocProvider
BlocProvider(
  create: (context) => DocumentBloc(getIt<DocumentService>())
    ..add(const DocumentEvent.initial()),
  child: DocumentPage(),
)

// 5. 使用 BlocBuilder/BlocConsumer
BlocBuilder<DocumentBloc, DocumentState>(
  builder: (context, state) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }
    return DocumentEditor(document: state.document!);
  },
)
```

### 2. 插件化架构

AppFlowy 采用插件化架构，每种视图都是一个插件：

```dart
// 插件接口
abstract class AppFlowyPlugin {
  String get name;
  WidgetBuilder get builder;
  WidgetBuilder get settingsBuilder;
  
  void dispose();
}

// 文档插件
class DocumentPlugin implements AppFlowyPlugin {
  @override
  String get name => 'Document';
  
  @override
  WidgetBuilder get builder => (context) {
    return BlocProvider(
      create: (_) => DocumentBloc()..add(const Initial()),
      child: const DocumentPage(),
    );
  };
}

// 数据库插件
class DatabasePlugin implements AppFlowyPlugin {
  final ViewPB view;
  
  DatabasePlugin(this.view);
  
  @override
  WidgetBuilder get builder => (context) {
    return DatabaseView(
      view: view,
      databaseController: DatabaseController(view: view),
    );
  };
}

// 插件注册
class PluginRegistry {
  final Map<String, AppFlowyPlugin> _plugins = {};
  
  void register(AppFlowyPlugin plugin) {
    _plugins[plugin.name] = plugin;
  }
  
  AppFlowyPlugin? get(String name) => _plugins[name];
}
```

### 3. Rust FFI 集成

AppFlowy 使用 Rust 处理核心逻辑：

```dart
// Dart 端 - 定义 FFI 接口
class AppFlowyBackend {
  static Future<void> init(String dataDir) async {
    final result = await invoke('init', {'data_dir': dataDir});
    if (!result.success) {
      throw BackendException(result.error);
    }
  }
  
  static Future<Document> getDocument(String docId) async {
    final result = await invoke('get_document', {'doc_id': docId});
    return Document.fromJson(result.data);
  }
}

// Rust 端 - 实现逻辑
#[tauri::command]
async fn get_document(doc_id: String) -> Result<Document, Error> {
    let doc = DocumentService::get(&doc_id).await?;
    Ok(doc)
}
```

### 4. 领域驱动设计 (DDD)

AppFlowy 采用分层架构：

```dart
// Domain 层 - 实体和接口
abstract class IDocumentRepository {
  Future<Either<Failure, Document>> getDocument(String id);
  Future<Either<Failure, Unit>> saveDocument(Document doc);
}

// Application 层 - 用例
class GetDocumentUseCase {
  final IDocumentRepository _repository;
  
  GetDocumentUseCase(this._repository);
  
  Future<Either<Failure, Document>> call(String id) {
    return _repository.getDocument(id);
  }
}

// Infrastructure 层 - 实现
class DocumentRepository implements IDocumentRepository {
  final AppFlowyBackend _backend;
  
  DocumentRepository(this._backend);
  
  @override
  Future<Either<Failure, Document>> getDocument(String id) async {
    try {
      final doc = await _backend.getDocument(id);
      return right(doc);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
```

### 5. 依赖注入

```dart
// 使用 get_it 进行依赖注入
final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // 后端服务
  getIt.registerLazySingleton<AppFlowyBackend>(
    () => AppFlowyBackend(),
  );
  
  // Repository
  getIt.registerLazySingleton<IDocumentRepository>(
    () => DocumentRepository(getIt()),
  );
  
  // Use Cases
  getIt.registerFactory(
    () => GetDocumentUseCase(getIt()),
  );
  
  // BLoC
  getIt.registerFactoryParam<DocumentBloc, String, void>(
    (docId, _) => DocumentBloc(
      getIt(),
      docId: docId,
    ),
  );
}
```

### 6. 协作编辑

AppFlowy 支持实时协作：

```dart
// 协作管理器
class CollaborationManager {
  final WebSocketChannel _channel;
  final StreamController<Operation> _operationController;
  
  Stream<Operation> get operations => _operationController.stream;
  
  void applyOperation(Operation op) {
    _channel.sink.add(jsonEncode(op.toJson()));
  }
  
  void listen() {
    _channel.stream.listen((data) {
      final op = Operation.fromJson(jsonDecode(data));
      _operationController.add(op);
    });
  }
}
```

## 架构亮点

1. **插件化**: 易于扩展新的视图类型
2. **Rust 后端**: 高性能数据处理
3. **DDD 分层**: 清晰的代码组织
4. **BLoC 模式**: 可测试的状态管理
5. **自研编辑器**: 完全可控的富文本编辑

## 适合学习

- 大型 Flutter 项目架构
- BLoC 状态管理最佳实践
- Flutter + Rust 混合开发
- 插件化系统设计
- 富文本编辑器开发
- 协作编辑实现

## 运行项目

```bash
# 克隆项目
git clone https://github.com/AppFlowy-IO/AppFlowy.git
cd AppFlowy

# 安装 Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 编译 Rust 后端
cd frontend/appflowy_tauri/src-tauri
cargo build

# 运行 Flutter 前端
cd frontend/appflowy_flutter
flutter pub get
flutter run
```

::: warning 注意事项
1. 需要安装 Rust 工具链
2. 首次编译 Rust 较慢
3. 需要足够的磁盘空间
:::

::: tip 学习建议
1. 从 workspace 模块开始理解整体架构
2. 研究 Document 插件理解 BLoC 模式
3. 查看 appflowy_editor 学习富文本编辑
4. 深入 Rust 后端了解数据持久化
:::
