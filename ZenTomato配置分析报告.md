# ZenTomato应用初始化配置分析报告

## 概述

本报告详细分析了ZenTomato应用的所有初始化配置和默认设置值，为后续的统一默认值调整提供参考。

## 1. 权限相关默认值

### 通知权限
- **默认请求状态**: 应用启动时自动请求
- **权限选项**: `.alert`, `.sound`, `.badge`
- **初始状态**: `isAuthorized = false`, `authorizationStatus = .notDetermined`
- **文件位置**: `ZenTomato/ViewModels/NotificationManager.swift` (第19-22行, 第64-76行)

### 系统权限
- **开机启动权限**: 在 `ZenTomato.entitlements` 中配置
- **沙盒权限**: `com.apple.security.app-sandbox = true`
- **Apple Events权限**: `com.apple.security.automation.apple-events = true`
- **文件位置**: `ZenTomato/ZenTomato.entitlements`

## 2. 核心功能默认值

### 番茄钟时间设置
**文件位置**: `ZenTomato/Models/TimerConfiguration.swift` (第14-20行)

```swift
var workDuration: TimeInterval = 25 * 60        // 25分钟 (1500秒)
var shortBreakDuration: TimeInterval = 5 * 60   // 5分钟 (300秒)
var longBreakDuration: TimeInterval = 15 * 60   // 15分钟 (900秒)
var cyclesBeforeLongBreak: Int = 4               // 4个工作周期后长休息
```

### 自动化设置
**文件位置**: `ZenTomato/Models/TimerConfiguration.swift` (第22-26行)

```swift
var autoStartBreaks: Bool = false        // 自动开始休息
var autoStartWork: Bool = false          // 自动开始工作
var showTimeInMenuBar: Bool = true       // 菜单栏显示时间
```

## 3. 用户体验默认值

### 音效设置
**文件位置**: `ZenTomato/Models/AudioSettings.swift` (第27-35行)

```swift
var windupVolume: Float = 1.0      // 开始音效音量 (100%)
var dingVolume: Float = 1.0        // 结束音效音量 (100%)
var tickingVolume: Float = 0.5     // 禅韵木鱼音量 (50%)
var isMuted: Bool = false          // 是否静音
var enableTicking: Bool = true     // 启用禅韵木鱼
```

### 白噪音设置
**文件位置**: `ZenTomato/Models/AudioSettings.swift` (第38-41行)

```swift
var whiteNoiseSettings: [WhiteNoiseType: WhiteNoiseSetting] = [
    .zenResonance: WhiteNoiseSetting(isEnabled: true, volume: 0.5),   // 禅韵木鱼：启用
    .woodenFish: WhiteNoiseSetting(isEnabled: false, volume: 0.5)     // 纯净木鱼：禁用
]
```

### 主题配色
**文件位置**: `ZenTomato/Extensions/Color+Zen.swift` (第15-39行)

```swift
static let zenRed = Color(hex: "#CC3333")           // 工作状态红色
static let zenGreen = Color(hex: "#66B366")         // 休息状态绿色
static let zenBlue = Color(hex: "#6699CC")          // 专注状态蓝色
static let zenGold = Color(hex: "#E6B34D")          // 完成状态金色
static let zenGray = Color(hex: "#F2F2F2")          // 背景灰色
static let zenTextGray = Color(hex: "#4D4D4D")      // 深灰文字色
static let zenSecondaryText = Color(hex: "#8E8E93") // 次要文字色
static let zenCardBackground = Color(hex: "#FFFFFF") // 卡片背景色
static let zenDivider = Color(hex: "#E5E5EA")       // 分隔线颜色
```

### 语言设置
**文件位置**: `ZenTomato/Models/TimerPhase.swift` (第21-30行)

- **默认语言**: 中文 (硬编码)
- **阶段名称**: "专注工作", "短休息", "长休息"

## 4. 系统集成默认值

### 开机启动设置
**文件位置**: `ZenTomato/Models/SystemSettings.swift` (第14行)

```swift
var launchAtLogin: Bool = false    // 开机自启动：默认关闭
```

### 应用行为设置
**文件位置**: `ZenTomato/ZenTomatoApp.swift`, `ZenTomato/Views/MainView.swift`

```swift
NSApp.setActivationPolicy(.accessory)  // 菜单栏应用，不显示在Dock
.frame(width: 380, height: 680)        // 界面尺寸：380x680像素
```

## 5. 音频文件配置

### 音效文件映射
**文件位置**: `ZenTomato/Models/AudioSettings.swift` (第96-155行)

```swift
enum SoundType: String, CaseIterable {
    case windup = "windup"              // windup.mp3
    case ding = "ding"                  // ding.mp3
    case ticking = "zenresonance"       // zenresonance.mp3
}

enum WhiteNoiseType: String, CaseIterable {
    case zenResonance = "zenresonance"  // zenresonance.mp3
    case woodenFish = "woodenfish"      // woodenfish.mp3
}
```

## 6. 数据存储配置

### UserDefaults存储键值
- **计时器配置**: `"ZenTomato.TimerConfiguration"`
- **音频设置**: `"ZenTomato.AudioSettings"`
- **系统设置**: `"ZenTomato.SystemSettings"`

### 存储机制
- 所有配置都通过UserDefaults本地存储
- 启动时自动加载，无效配置自动回退到默认值
- 配置变更时实时保存

## 7. 配置文件分布总结

| 配置类别 | 文件位置 | 主要内容 |
|---------|---------|---------|
| 核心计时功能 | `Models/TimerConfiguration.swift` | 工作/休息时长、自动化设置 |
| 音效设置 | `Models/AudioSettings.swift` | 音量、音效开关、白噪音 |
| 系统集成 | `Models/SystemSettings.swift` | 开机启动等系统级设置 |
| 主题配色 | `Extensions/Color+Zen.swift` | 界面颜色主题 |
| 系统权限 | `ZenTomato.entitlements` | 沙盒、通知等权限配置 |
| 应用启动 | `ZenTomatoApp.swift` | 应用行为和初始化逻辑 |

## 8. 调整建议

### 快速调整要点
1. **时间设置**: 修改 `TimerConfiguration.swift` 中的时长常量
2. **音效默认**: 调整 `AudioSettings.swift` 中的音量和开关状态
3. **主题色彩**: 更新 `Color+Zen.swift` 中的十六进制颜色值
4. **系统集成**: 修改 `SystemSettings.swift` 中的布尔值默认状态

### 注意事项
- 所有默认值修改后需要清除应用数据或UserDefaults才能生效
- 音频文件名修改需要同步更新枚举中的rawValue
- 权限配置修改需要重新签名应用

---

**生成时间**: 2025年9月2日  
**应用版本**: 基于当前代码库分析  
**分析范围**: 完整的初始化配置和默认设置值
