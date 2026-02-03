# WeChat Flutter

Flutter 版微信，一个功能完整的即时通讯应用实现。

## 📋 项目概述

| 项目信息 | 详情 |
|---------|------|
| 🔗 GitHub | [fluttercandies/wechat_flutter](https://github.com/fluttercandies/wechat_flutter) |
| ⭐ Stars | 2.5k+ |
| 📅 最后更新 | 活跃维护中 |
| 📄 协议 | Apache 2.0 |
| 🎯 定位 | 仿微信 IM 应用完整实现 |

## 🛠️ 技术栈

### 核心依赖

```yaml
dependencies:
  # 状态管理
  provider: ^6.0.0        # 全局状态
  get: ^4.6.0             # 路由和依赖注入
  
  # IM SDK
  tencent_cloud_chat_sdk: ^latest  # 腾讯云 IM
  
  # UI 组件
  cached_network_image: ^3.0.0    # 图片缓存
  oktoast: ^3.3.0                  # Toast 提示
  webview_flutter: ^4.0.0          # WebView
  
  # 媒体处理
  wechat_assets_picker: ^latest    # 相册选择
  wechat_camera_picker: ^latest    # 相机拍照
  image_picker: ^1.0.0             # 图片选择
  flutter_sound: ^9.0.0            # 音频录制
  video_player: ^2.0.0             # 视频播放
  
  # 工具
  azlistview_plus: ^latest         # 字母索引列表
  lpinyin: ^2.0.0                  # 拼音转换
  connectivity_plus: ^5.0.0        # 网络状态
  shared_preferences: ^2.0.0       # 本地存储
```

### 技术特点

- **腾讯云 IM** - 基于腾讯云即时通讯 SDK
- **Provider + GetX** - 混合状态管理
- **完整 IM 功能** - 聊天、群组、通讯录、朋友圈
- **微信风格 UI** - 高度还原微信界面

## 📁 项目结构

```
lib/
├── main.dart                 # 应用入口
├── app.dart                  # MyApp 根组件
├── config/
│   ├── api.dart              # API 配置
│   ├── const.dart            # 常量定义
│   ├── contacts.dart         # 联系人配置
│   ├── dictionary.dart       # 字典数据
│   ├── keys.dart             # 存储 Key
│   ├── provider_config.dart  # Provider 配置
│   ├── storage_manager.dart  # 存储管理
│   └── strings.dart          # 字符串资源
├── http/
│   ├── api.dart              # HTTP API
│   └── req.dart              # 请求封装
├── im/
│   ├── all_im.dart           # IM 统一导出
│   ├── conversation_handle.dart  # 会话处理
│   ├── friend_handle.dart    # 好友处理
│   ├── fun_dim_group_model.dart  # 群组模型
│   ├── info_handle.dart      # 信息处理
│   ├── login_handle.dart     # 登录处理
│   ├── message_handle.dart   # 消息处理
│   ├── send_handle.dart      # 发送处理
│   └── model/
│       ├── chat_data.dart    # 聊天数据
│       ├── chat_list.dart    # 聊天列表
│       ├── contacts.dart     # 联系人模型
│       └── user_data.dart    # 用户数据
├── pages/
│   ├── chat/                 # 聊天页面
│   │   ├── chat_page.dart    # 聊天主页
│   │   ├── chat_info_page.dart   # 聊天设置
│   │   ├── chat_more_page.dart   # 更多功能
│   │   └── set_remark_page.dart  # 设置备注
│   ├── contacts/             # 通讯录
│   │   ├── contacts_page.dart    # 通讯录主页
│   │   ├── contacts_details_page.dart  # 联系人详情
│   │   ├── group_list_page.dart  # 群聊列表
│   │   ├── group_launch_page.dart    # 发起群聊
│   │   └── public_page.dart      # 公众号
│   ├── discover/             # 发现
│   │   └── discover_page.dart    # 发现主页
│   ├── group/                # 群组
│   │   ├── group_details_page.dart   # 群详情
│   │   ├── group_members_page.dart   # 群成员
│   │   └── select_members_page.dart  # 选择成员
│   ├── home/                 # 首页
│   │   ├── home_page.dart    # 消息列表
│   │   └── search_page.dart  # 搜索
│   ├── login/                # 登录
│   │   ├── login_page.dart   # 登录主页
│   │   ├── login_begin_page.dart     # 登录入口
│   │   └── select_location_page.dart # 选择地区
│   ├── mine/                 # 我的
│   │   ├── mine_page.dart    # 我的主页
│   │   ├── personal_info_page.dart   # 个人信息
│   │   └── code_page.dart    # 二维码
│   ├── more/                 # 更多
│   │   ├── add_friend_page.dart      # 添加好友
│   │   └── verification_page.dart    # 验证申请
│   ├── root/                 # 根页面
│   │   ├── root_page.dart    # 根页面
│   │   ├── root_tabbar.dart  # TabBar
│   │   └── user_page.dart    # 用户页
│   ├── settings/             # 设置
│   │   ├── language_page.dart    # 语言设置
│   │   ├── chat_background_page.dart # 聊天背景
│   │   └── select_backgroud_page.dart # 选择背景
│   ├── wallet/               # 钱包
│   │   └── pay_home_page.dart    # 支付首页
│   └── wechat_friends/       # 朋友圈
│       ├── page/
│       │   ├── wechat_friends_circle.dart  # 朋友圈主页
│       │   └── publish_dynamic.dart        # 发布动态
│       ├── ui/
│       │   ├── item_dynamic.dart   # 动态项
│       │   ├── asset_view.dart     # 资源视图
│       │   └── load_view.dart      # 加载视图
│       ├── chat_style.dart         # 聊天样式
│       └── from.dart               # 表单数据
├── provider/
│   ├── global_model.dart     # 全局状态模型
│   ├── login_model.dart      # 登录状态模型
│   └── loginc/
│       └── global_loginc.dart    # 全局逻辑
├── tools/
│   ├── wechat_flutter.dart   # 工具统一导出
│   ├── commom.dart           # 通用方法
│   ├── date.dart             # 日期处理
│   ├── shared_util.dart      # SharedPreferences 封装
│   ├── data/
│   │   ├── data.dart         # 数据定义
│   │   ├── notice.dart       # 事件通知
│   │   └── store.dart        # 状态存储
│   └── event/
│       └── im_event.dart     # IM 事件
├── ui/                       # UI 组件
│   ├── bar/
│   │   └── commom_bar.dart   # 通用导航栏
│   ├── button/
│   │   └── commom_button.dart    # 通用按钮
│   ├── chat/
│   │   ├── chat_details_body.dart    # 聊天内容
│   │   ├── chat_details_row.dart     # 聊天输入行
│   │   └── my_conversation_view.dart # 会话视图
│   ├── dialog/
│   │   ├── code_dialog.dart      # 二维码弹窗
│   │   ├── confirm_alert.dart    # 确认弹窗
│   │   ├── show_snack.dart       # Snackbar
│   │   └── voice_dialog.dart     # 语音弹窗
│   ├── edit/
│   │   ├── emoji_text.dart       # 表情文本
│   │   └── text_span_builder.dart    # 富文本构建
│   ├── item/
│   │   ├── chat_mamber.dart      # 聊天成员
│   │   ├── chat_more_icon.dart   # 更多图标
│   │   ├── chat_voice.dart       # 语音录制
│   │   ├── contact_item.dart     # 联系人项
│   │   └── contact_view.dart     # 联系人视图
│   ├── message_view/
│   │   ├── content_msg.dart      # 消息内容
│   │   ├── text_msg.dart         # 文本消息
│   │   ├── Img_msg.dart          # 图片消息
│   │   ├── sound_msg.dart        # 语音消息
│   │   ├── video_message.dart    # 视频消息
│   │   └── red_package.dart      # 红包消息
│   ├── orther/
│   │   ├── label_row.dart        # 标签行
│   │   ├── verify_input.dart     # 验证输入
│   │   └── verify_switch.dart    # 验证开关
│   ├── view/
│   │   ├── image_view.dart       # 图片视图
│   │   ├── indicator_page_view.dart  # 指示器页面
│   │   ├── list_tile_view.dart   # 列表项视图
│   │   ├── loading_view.dart     # 加载视图
│   │   ├── main_input.dart       # 主输入框
│   │   ├── null_view.dart        # 空视图
│   │   └── pop_view.dart         # 弹出视图
│   ├── w_pop/
│   │   ├── w_popup_menu.dart     # 弹出菜单
│   │   ├── menu_popup_widget.dart    # 菜单组件
│   │   ├── popup_menu_route_layout.dart  # 菜单路由
│   │   └── triangle_painter.dart     # 三角绘制
│   └── web/
│       └── web_view.dart         # WebView
└── generated/
    └── i18n.dart                 # 国际化生成
```

## 📝 学习要点

### 1. Provider + GetX 混合状态管理

```dart
/// main.dart - Provider 包裹根组件
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Data.initData();
  await StorageManager.init();
  
  runApp(ProviderConfig.getInstance().getGlobal(MyApp()));
}

/// GlobalModel - Provider 全局状态
class GlobalModel extends ChangeNotifier {
  BuildContext? context;
  String appName = '微信flutter';
  String account = '';
  String nickName = 'nickName';
  String avatar = '';
  int gender = 0;
  
  List<String> currentLanguageCode = ['zh', 'CN'];
  String currentLanguage = '中文';
  Locale? currentLocale;
  bool goToLogin = true;

  late GlobalLogic logic;

  GlobalModel() {
    this.logic = GlobalLogic(this);
  }

  void setContext(BuildContext context) {
    if (this.context == null) {
      this.context = context;
      Future.wait([
        logic.getAppName(),
        logic.getCurrentLanguageCode(),
        logic.getCurrentLanguage(),
      ]);
    }
  }
}

/// GetX 用于路由导航
Get.to<void>(ChatPage(id: id, title: title, type: type));
Get.back();
```

### 2. 事件通知系统

```dart
/// Notice - 简单的事件总线
class Notice {
  static final Map<String, List<Function>> _listeners = {};
  
  /// 添加监听
  static void addListener(String event, Function callback) {
    _listeners[event] ??= [];
    _listeners[event]!.add(callback);
  }
  
  /// 发送事件
  static void send(String event, [dynamic data]) {
    _listeners[event]?.forEach((callback) {
      callback(data);
    });
  }
  
  /// 移除监听
  static void removeListenerByEvent(String event) {
    _listeners.remove(event);
  }
}

/// 定义事件常量
class WeChatActions {
  static String msg() => 'msg';
  static String groupName() => 'groupName';
  static String voiceImg() => 'voiceImg';
  static String user() => 'user';
}

/// 使用示例 - 发送消息后通知
Notice.send(WeChatActions.msg(), messageData);

/// 使用示例 - 监听消息
Notice.addListener(WeChatActions.msg(), (v) => getChatMsgData());

/// 记得在 dispose 中移除
@override
void dispose() {
  Notice.removeListenerByEvent(WeChatActions.msg());
  super.dispose();
}
```

### 3. 消息类型处理

```dart
/// 根据消息类型渲染不同 UI
class SendMessageView extends StatefulWidget {
  const SendMessageView(this.model, {super.key});
  final V2TimMessage model;
  
  @override
  State<SendMessageView> createState() => _SendMessageViewState();
}

class _SendMessageViewState extends State<SendMessageView> {
  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    
    // 根据 elemType 分发
    switch (model.elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return TextMsg(model);
        
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return ImgMsg(model);
        
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return SoundMsg(model);
        
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return VideoMessage(model);
        
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        return _handleCustomMessage(model);
        
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        return _handleGroupTips(model);
        
      default:
        return Container();
    }
  }
  
  Widget _handleCustomMessage(V2TimMessage model) {
    final customElem = model.customElem;
    // 解析自定义消息
    return RedPackage(model);
  }
  
  Widget _handleGroupTips(V2TimMessage model) {
    final tipsElem = model.groupTipsElem;
    switch (tipsElem?.type) {
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_JOIN:
        return JoinMessage(model);
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_QUIT:
        return QuitMessage(model);
      default:
        return Container();
    }
  }
}
```

### 4. 字母索引联系人列表

```dart
/// 使用 azlistview_plus 实现字母索引
class _ContactsPageState extends State<ContactsPage> {
  final List<Contact> _contacts = [];
  
  @override
  Widget build(BuildContext context) {
    return AzListView(
      data: _contacts,
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return ContactItem(
          avatar: contact.avatar,
          title: contact.name,
          onPressed: () => _onContactTap(contact),
        );
      },
      susItemBuilder: (context, index) {
        // 分组头
        final tag = _contacts[index].getSuspensionTag();
        return Container(
          height: 30,
          color: Colors.grey[200],
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 15),
          child: Text(tag),
        );
      },
      indexBarData: SuspensionUtil.getTagIndexList(_contacts),
      indexBarOptions: IndexBarOptions(
        needRebuild: true,
        selectTextStyle: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// 联系人模型 - 实现 ISuspensionBean
class Contact extends ISuspensionBean {
  String name;
  String avatar;
  String? tagIndex;
  
  Contact({required this.name, required this.avatar});
  
  @override
  String getSuspensionTag() {
    // 使用 lpinyin 将名字转拼音
    return tagIndex ?? PinyinHelper.getFirstWordPinyin(name).substring(0, 1).toUpperCase();
  }
}
```

### 5. 聊天输入组件

```dart
/// 聊天输入行 - 语音/文字/表情/更多
class ChatDetailsRow extends StatefulWidget {
  final GestureTapCallback? voiceOnTap;
  final bool isVoice;
  final LayoutWidgetBuilder edit;
  final VoidCallback onEmojio;
  final Widget more;
  final String id;
  final int type;

  // ...
}

class ChatDetailsRowState extends State<ChatDetailsRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        color: Color(AppColors.ChatBoxBg),
        border: Border(
          top: BorderSide(color: lineColor, width: Constants.DividerWidth),
          bottom: BorderSide(color: lineColor, width: Constants.DividerWidth),
        ),
      ),
      child: Row(
        children: [
          // 语音按钮
          InkWell(
            child: Image.asset('assets/images/chat/ic_voice.webp'),
            onTap: widget.voiceOnTap,
          ),
          
          // 输入框
          Expanded(
            child: widget.isVoice 
              ? ChatVoice(voiceFile: _onVoiceRecorded)
              : widget.edit(context, BoxConstraints()),
          ),
          
          // 表情按钮
          InkWell(
            child: Image.asset('assets/images/chat/ic_Emotion.webp'),
            onTap: widget.onEmojio,
          ),
          
          // 更多/发送按钮
          widget.more,
        ],
      ),
    );
  }
  
  void _onVoiceRecorded(String path) {
    sendSoundMessages(
      widget.id,
      path,
      2,  // 时长
      widget.type,
      (value) => Notice.send(WeChatActions.msg(), value),
    );
  }
}
```

## ✨ 架构亮点

### 1. 完整的 IM 功能实现
- 单聊/群聊
- 文字/图片/语音/视频消息
- 群组管理
- 联系人管理
- 朋友圈

### 2. 模块化组织
- 按功能划分 pages
- 独立的 UI 组件库
- 统一的工具类导出

### 3. 腾讯云 IM 集成
- 完整的 SDK 封装
- 消息类型处理
- 会话管理

### 4. 微信风格 UI
- 高度还原的界面
- 自定义弹出菜单
- 联系人索引列表

## 🚀 运行指南

### 1. 克隆项目

```bash
git clone https://github.com/fluttercandies/wechat_flutter.git
cd wechat_flutter
```

### 2. 配置腾讯云 IM

1. 注册 [腾讯云](https://cloud.tencent.com/) 账号
2. 开通即时通讯 IM 服务
3. 获取 SDKAppID 和密钥
4. 配置到项目中

### 3. 安装依赖

```bash
flutter pub get
```

### 4. 运行项目

```bash
flutter run
```

## 💡 使用技巧

### 抽离通用组件

```dart
/// 通用导航栏
class ComMomBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? rightDMActions;
  
  const ComMomBar({required this.title, this.rightDMActions});
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: rightDMActions,
      backgroundColor: appBarColor,
      elevation: 0,
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

/// 通用按钮
class ComMomButton extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? width;
  final EdgeInsets? margin;
  final double? radius;
  final VoidCallback onTap;
  
  // ...
}
```

### 统一导出工具类

```dart
/// tools/wechat_flutter.dart - 一行导入所有工具
export 'dart:async';
export 'dart:io';
export 'dart:ui';

export 'package:cached_network_image/cached_network_image.dart';
export 'package:flutter/services.dart';
export 'package:oktoast/oktoast.dart';
export 'package:wechat_flutter/config/api.dart';
export 'package:wechat_flutter/config/const.dart';
export 'package:wechat_flutter/tools/data/data.dart';
export 'package:wechat_flutter/tools/shared_util.dart';
export 'package:wechat_flutter/ui/bar/commom_bar.dart';
export 'package:wechat_flutter/ui/button/commom_button.dart';
// ... 更多导出
```

## ⚠️ 注意事项

::: warning 腾讯云 IM
使用前需要注册腾讯云账号并开通 IM 服务，有免费额度
:::

::: tip 学习价值
这是一个功能完整的 IM 应用实现，非常适合学习：
- IM 应用架构
- 消息系统设计
- 实时通讯处理
:::

::: info Flutter 版本
推荐使用 Flutter 3.x 版本运行
:::
