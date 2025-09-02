# 禅番茄 (ZenTomato) - macOS 番茄钟应用

## 项目概述

禅番茄是一款专为 macOS 设计的番茄钟应用，将传统番茄工作法与禅意美学完美融合。应用采用原生 SwiftUI 开发，提供菜单栏常驻、智能计时、沉浸式音效和优雅通知等核心功能。

## 功能特性

### ✅ 已实现功能

#### 1. 核心计时系统
- ✅ 可配置的工作时长（1-60分钟）
- ✅ 可配置的短休息时长（1-60分钟）
- ✅ 可配置的长休息时长（1-60分钟）
- ✅ 智能周期管理（每4个番茄后长休息）
- ✅ 开始/暂停/停止/跳过控制
- ✅ 实时倒计时显示
- ✅ 进度环可视化

#### 2. 菜单栏集成
- ✅ 菜单栏常驻图标
- ✅ 可选的倒计时显示
- ✅ 点击显示控制面板（380x680像素）
- ✅ 状态图标变化（工作/休息）

#### 3. 用户界面
- ✅ 禅意极简设计风格
- ✅ 呼吸动画背景
- ✅ 三个标签页（计时/设置/声音）
- ✅ 响应式交互动画
- ✅ 主题色彩系统

#### 4. 音效系统
- ✅ 开始音效（windup）
- ✅ 结束音效（ding）
- ✅ 背景滴答声（可选）
- ✅ 独立音量控制（0-200%）
- ✅ 静音功能

#### 5. 通知系统
- ✅ 系统通知权限管理
- ✅ 阶段切换通知
- ✅ 交互式通知（跳过休息）

#### 6. 设置功能
- ✅ 自动开始休息/工作选项
- ✅ 菜单栏显示时间开关
- ✅ 音效设置
- ✅ 重置默认设置

### 🚧 待完善功能

1. **系统集成**
   - 全局快捷键支持
   - 开机自启动
   - URL Scheme 支持

2. **本地化**
   - 中英文界面切换
   - 本地化通知内容

3. **数据持久化**
   - 统计数据记录
   - 历史记录查看

4. **音频资源**
   - 真实的音效文件（当前为静音占位符）
   - 多种音效主题选择

5. **应用图标**
   - 设计并添加应用图标
   - 菜单栏图标优化

## 技术架构

### 技术栈
- **语言**: Swift 5.0+
- **UI框架**: SwiftUI
- **响应式编程**: Combine
- **最低系统要求**: macOS 11.0 (Big Sur)

### 架构模式
- **MVVM** (Model-View-ViewModel)
- **响应式数据流**
- **组件化设计**

### 项目结构
```
ZenTomato/
├── Models/              # 数据模型
│   ├── TimerState.swift
│   ├── TimerPhase.swift
│   ├── TimerConfiguration.swift
│   └── AudioSettings.swift
├── ViewModels/          # 视图模型
│   ├── TimerEngine.swift
│   ├── AudioPlayer.swift
│   ├── NotificationManager.swift
│   └── MenuBarManager.swift
├── Views/               # 视图组件
│   ├── MainView.swift
│   ├── TimerView.swift
│   ├── SettingsView.swift
│   └── AudioView.swift
├── Extensions/          # 扩展
│   ├── Color+Zen.swift
│   └── Animation+Zen.swift
└── Resources/           # 资源文件
    ├── windup.mp3
    ├── ding.mp3
    └── ticking.mp3
```

## 构建和运行

### 前置要求
- macOS 11.0 或更高版本
- Xcode 14.0 或更高版本
- Apple Developer 账号（用于代码签名）

### 构建步骤

1. 克隆项目
```bash
git clone [项目地址]
cd ZenTomato
```

2. 打开 Xcode 项目
```bash
open ZenTomato.xcodeproj
```

3. 选择开发团队
   - 在 Xcode 中选择项目
   - 在 "Signing & Capabilities" 中选择您的开发团队

4. 构建并运行
   - 按 `Cmd + R` 或点击运行按钮

## 使用说明

### 基本操作
1. **启动应用**：应用启动后会在菜单栏显示图标
2. **打开控制面板**：点击菜单栏图标
3. **开始计时**：点击主控制按钮
4. **调整时长**：在计时器