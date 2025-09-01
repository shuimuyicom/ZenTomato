//
//  MainView.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  主控制面板 - 融入禅意美学的界面设计
//

import SwiftUI

/// 标签页类型
enum TabType: String, CaseIterable {
    case timer = "timer"
    case settings = "settings"
    case audio = "audio"
    
    var title: String {
        switch self {
        case .timer:
            return "专注"
        case .settings:
            return "设置"
        case .audio:
            return "音效"
        }
    }
    
    var icon: String {
        switch self {
        case .timer:
            return "timer"
        case .settings:
            return "gearshape"
        case .audio:
            return "speaker.wave.2"
        }
    }
}

/// 主视图
struct MainView: View {
    // MARK: - Properties
    
    /// 计时引擎
    @ObservedObject var timerEngine: TimerEngine
    
    /// 音频播放器
    @ObservedObject var audioPlayer: AudioPlayer
    
    /// 通知管理器
    @ObservedObject var notificationManager: NotificationManager
    
    /// 菜单栏管理器
    @ObservedObject var menuBarManager: MenuBarManager
    
    /// 当前选中的标签页
    @State private var selectedTab: TabType = .timer
    
    /// 界面过渡动画
    @Namespace private var tabAnimation
    
    /// 主按钮按下状态
    @State private var isMainButtonPressed = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            zenHeaderView
                .padding(.top, 20)
                .padding(.horizontal, 20)
            
            // 主要内容区域
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // 计时器显示和控制
                    if selectedTab == .timer {
                        zenTimerSection
                            .transition(.zenSlide)
                    }
                    
                    // 标签页内容
                    tabContentView
                        .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
            .frame(maxHeight: .infinity)
            
            // 底部标签栏
            zenTabBar
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
        .frame(width: 380, height: 680)
        .background(Color.zenGray.opacity(0.95))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Subviews
    
    /// 禅意标题栏
    private var zenHeaderView: some View {
        HStack {
            // Logo和标题
            HStack(spacing: 12) {
                // 应用主图标 - macOS 标准圆角矩形样式
                ZStack {
                    // 背景圆角矩形渐变 - 符合 macOS 应用图标规范
                    RoundedRectangle(cornerRadius: 36 * 0.2237, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    timerEngine.currentPhase.color.opacity(0.8),
                                    timerEngine.currentPhase.color
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)

                    // 应用主图标，使用 macOS 标准圆角
                    if let appIcon = NSImage(named: "AppIcon") {
                        Image(nsImage: appIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                            .clipShape(RoundedRectangle(cornerRadius: 28 * 0.2237, style: .continuous))
                            .shadow(color: Color.black.opacity(0.15), radius: 1.5, x: 0, y: 0.5)
                    } else {
                        // 回退到系统图标
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("禅番茄")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.zenTextGray)
                    
                    Text(timerEngine.currentPhase.displayName)
                        .font(.system(size: 11))
                        .foregroundColor(Color.zenSecondaryText)
                }
            }
            
            Spacer()
            
            // 快捷操作按钮
            HStack(spacing: 8) {
                // 关于按钮
                Button(action: showAbout) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 18))
                        .foregroundColor(Color.zenSecondaryText)
                        .frame(width: 32, height: 32)
                        .background(Color.zenCardBackground.opacity(0.8))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                
                // 退出按钮
                Button(action: quitApp) {
                    Image(systemName: "power")
                        .font(.system(size: 18))
                        .foregroundColor(Color.zenSecondaryText)
                        .frame(width: 32, height: 32)
                        .background(Color.zenCardBackground.opacity(0.8))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    /// 禅意计时器部分 - 重新设计为更紧凑的现代布局
    private var zenTimerSection: some View {
        VStack(spacing: 20) {
            // 时间显示 - 更大更突出
            VStack(spacing: 6) {
                Text(timerEngine.formattedTimeRemaining)
                    .font(.system(size: 72, weight: .ultraLight, design: .rounded))
                    .foregroundColor(timerEngine.currentPhase.color)
                    .monospacedDigit()
                

                
                // 状态信息 - 更精简
                HStack(spacing: 20) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.zenGreen)
                            .frame(width: 5, height: 5)
                        Text("已完成 \(timerEngine.completedCycles) 次专注")
                            .font(.system(size: 11))
                            .foregroundColor(Color.zenSecondaryText)
                    }
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(timerEngine.currentState == .running ? Color.zenGold : Color.zenSecondaryText)
                            .frame(width: 5, height: 5)
                        Text(timerEngine.currentState == .running ? "专注中" : "准备就绪")
                            .font(.system(size: 11))
                            .foregroundColor(Color.zenSecondaryText)
                    }
                }
                .padding(.top, 8)
            }
            
            // 控制按钮组 - 全新设计系统，确保所有状态清晰可见
            HStack(spacing: 12) {
                // 跳过按钮 - 次要操作，温和的设计
                ZenControlButton(
                    title: "跳过",
                    icon: "forward.end.fill",
                    style: .secondary,
                    isEnabled: timerEngine.currentState != .idle,
                    action: { timerEngine.skip() }
                )
                
                // 主控制按钮 - 核心操作，最突出的设计
                ZenControlButton(
                    title: mainButtonText,
                    icon: mainButtonIcon,
                    style: .primary(color: mainButtonColor),
                    isEnabled: true,
                    isLarge: true,
                    action: { timerEngine.toggleTimer() }
                )
                
                // 重置按钮 - 次要操作，温和但清晰
                ZenControlButton(
                    title: "重置",
                    icon: "arrow.counterclockwise",
                    style: .secondary,
                    isEnabled: true,
                    action: { timerEngine.reset() }
                )
            }
            .padding(.top, 16)
        }
        .padding(.horizontal, 20)
    }
    
    /// 标签页内容视图
    @ViewBuilder
    private var tabContentView: some View {
        VStack(spacing: 20) {
            switch selectedTab {
            case .timer:
                zenTimerSettings
            case .settings:
                zenSettingsContent
            case .audio:
                zenAudioContent
            }
        }
    }
    
    /// 计时器设置内容
    private var zenTimerSettings: some View {
        VStack(spacing: 16) {
            // 时间设置卡片
            VStack(spacing: 12) {
                HStack {
                    Label("时间设置", systemImage: "clock")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.zenTextGray)
                    Spacer()
                }
                
                VStack(spacing: 10) {
                    TimeSettingRow(
                        title: "工作时长",
                        value: Binding(
                            get: { Int(timerEngine.configuration.workDuration / 60) },
                            set: { timerEngine.configuration.workDuration = TimeInterval($0 * 60) }
                        ),
                        unit: "分钟",
                        color: .zenRed
                    )
                    
                    TimeSettingRow(
                        title: "短休息",
                        value: Binding(
                            get: { Int(timerEngine.configuration.shortBreakDuration / 60) },
                            set: { timerEngine.configuration.shortBreakDuration = TimeInterval($0 * 60) }
                        ),
                        unit: "分钟",
                        color: .zenGreen
                    )
                    
                    TimeSettingRow(
                        title: "长休息",
                        value: Binding(
                            get: { Int(timerEngine.configuration.longBreakDuration / 60) },
                            set: { timerEngine.configuration.longBreakDuration = TimeInterval($0 * 60) }
                        ),
                        unit: "分钟",
                        color: .zenBlue
                    )
                    
                    TimeSettingRow(
                        title: "工作周期",
                        value: $timerEngine.configuration.cyclesBeforeLongBreak,
                        unit: "个",
                        color: .zenGold
                    )
                }
            }
            .padding(16)
            .background(Color.zenCardBackground.opacity(0.95))
            .cornerRadius(16)
        }
    }
    
    /// 设置内容
    private var zenSettingsContent: some View {
        VStack(spacing: 16) {
            // 通用设置卡片
            VStack(spacing: 12) {
                HStack {
                    Label("通用设置", systemImage: "gearshape")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.zenTextGray)
                    Spacer()
                }
                
                VStack(spacing: 8) {
                    ZenToggleRow(
                        icon: "play.circle",
                        title: "自动开始休息",
                        isOn: $timerEngine.configuration.autoStartBreaks
                    )
                    
                    ZenToggleRow(
                        icon: "arrow.triangle.2.circlepath",
                        title: "自动开始工作",
                        isOn: $timerEngine.configuration.autoStartWork
                    )
                    
                    ZenToggleRow(
                        icon: "timer",
                        title: "菜单栏显示时间",
                        isOn: $timerEngine.configuration.showTimeInMenuBar
                    )
                }
            }
            .padding(16)
            .background(Color.zenCardBackground.opacity(0.95))
            .cornerRadius(16)
            
            // 系统集成卡片
            VStack(spacing: 12) {
                HStack {
                    Label("系统集成", systemImage: "laptopcomputer")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.zenTextGray)
                    Spacer()
                }
                
                VStack(spacing: 8) {
                    ZenToggleRow(
                        icon: "power",
                        title: "开机自启动",
                        isOn: .constant(false)
                    )
                }
            }
            .padding(16)
            .background(Color.zenCardBackground.opacity(0.95))
            .cornerRadius(16)
        }
    }
    
    /// 音效内容
    private var zenAudioContent: some View {
        VStack(spacing: 16) {
            // 音效设置卡片
            VStack(spacing: 12) {
                HStack {
                    Label("音效设置", systemImage: "speaker.wave.2")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.zenTextGray)
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { !audioPlayer.settings.isMuted },
                        set: { audioPlayer.settings.isMuted = !$0 }
                    ))
                    .toggleStyle(SwitchToggleStyle())
                    .labelsHidden()
                }
                
                if !audioPlayer.settings.isMuted {
                    VStack(spacing: 12) {
                        ZenVolumeRow(
                            icon: "play.circle",
                            title: "开始音效",
                            volume: $audioPlayer.settings.windupVolume
                        )
                        
                        ZenVolumeRow(
                            icon: "bell",
                            title: "结束音效",
                            volume: $audioPlayer.settings.dingVolume
                        )
                        
                        ZenVolumeRow(
                            icon: "metronome",
                            title: "滴答声",
                            volume: $audioPlayer.settings.tickingVolume
                        )
                    }
                }
            }
            .padding(16)
            .background(Color.zenCardBackground.opacity(0.95))
            .cornerRadius(16)
        }
    }
    
    /// 禅意标签栏
    private var zenTabBar: some View {
        HStack(spacing: 0) {
            ForEach(TabType.allCases, id: \.self) { tab in
                zenTabButton(for: tab)
            }
        }
        .padding(4)
        .background(Color.zenCardBackground.opacity(0.6))
        .cornerRadius(16)
    }

    /// 单个标签按钮
    private func zenTabButton(for tab: TabType) -> some View {
        Button(action: {
            withAnimation(.zenSmooth) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20))
                    .foregroundColor(selectedTab == tab ? timerEngine.currentPhase.color : Color.zenSecondaryText)

                Text(tab.title)
                    .font(.system(size: 10))
                    .foregroundColor(selectedTab == tab ? Color.zenTextGray : Color.zenSecondaryText)
            }
            .frame(maxWidth: .infinity, minHeight: 50) // 增加最小高度，确保足够的点击区域
            .padding(.vertical, 16) // 增加垂直内边距，从12增加到16
            .padding(.horizontal, 8) // 添加水平内边距，增加左右点击区域
            .contentShape(Rectangle()) // 确保整个区域都可以点击，包括透明部分
            .background(tabButtonBackground(for: tab))
        }
        .buttonStyle(PlainButtonStyle())
    }

    /// 标签按钮背景
    private func tabButtonBackground(for tab: TabType) -> some View {
        ZStack {
            if selectedTab == tab {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.zenCardBackground.opacity(0.8))
                    .matchedGeometryEffect(id: "tab", in: tabAnimation)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// 主按钮文字
    private var mainButtonText: String {
        switch timerEngine.currentState {
        case .idle, .completed:
            return "开始"
        case .running:
            return "暂停"
        case .paused:
            return "继续"
        }
    }
    
    /// 主按钮图标
    private var mainButtonIcon: String {
        switch timerEngine.currentState {
        case .idle, .completed:
            return "play.fill"
        case .running:
            return "pause.fill"
        case .paused:
            return "play.fill"
        }
    }
    
    /// 主按钮颜色
    private var mainButtonColor: Color {
        switch timerEngine.currentState {
        case .idle, .completed:
            return timerEngine.currentPhase.color
        case .running:
            return Color.zenRed  // 运行时用红色，表示可以暂停
        case .paused:
            return Color.zenGreen  // 暂停时用绿色，表示可以继续
        }
    }
    
    // MARK: - Actions
    
    /// 显示关于窗口
    private func showAbout() {
        NSApp.orderFrontStandardAboutPanel(nil)
    }
    
    /// 退出应用
    private func quitApp() {
        NSApp.terminate(nil)
    }
}

// MARK: - Supporting Views

/// 时间设置行
struct TimeSettingRow: View {
    let title: String
    @Binding var value: Int
    let unit: String
    let color: Color
    
    var body: some View {
        HStack {
            Label(title, systemImage: "timer")
                .font(.system(size: 12))
                .foregroundColor(Color.zenTextGray)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: { if value > 1 { value -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(color.opacity(0.8))
                }
                .buttonStyle(PlainButtonStyle())
                
                Text("\(value)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Button(action: { value += 1 }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(color.opacity(0.8))
                }
                .buttonStyle(PlainButtonStyle())
                
                Text(unit)
                    .font(.system(size: 11))
                    .foregroundColor(Color.zenSecondaryText)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.zenGray.opacity(0.5))
        .cornerRadius(8)
    }
}

/// 禅意开关行
struct ZenToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.system(size: 12))
                .foregroundColor(Color.zenTextGray)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle())
                .labelsHidden()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.zenGray.opacity(0.5))
        .cornerRadius(8)
    }
}

/// 禅意音量行
struct ZenVolumeRow: View {
    let icon: String
    let title: String
    @Binding var volume: Float
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.system(size: 12))
                .foregroundColor(Color.zenTextGray)
            
            Slider(value: $volume, in: 0...2)
                .controlSize(.small)
            
            Text("\(Int(volume * 100))%")
                .font(.system(size: 11))
                .foregroundColor(Color.zenSecondaryText)
                .frame(width: 35)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.zenGray.opacity(0.5))
        .cornerRadius(8)
    }
}

// MARK: - Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(
            timerEngine: TimerEngine.preview,
            audioPlayer: AudioPlayer.preview,
            notificationManager: NotificationManager.preview,
            menuBarManager: MenuBarManager(
                timerEngine: TimerEngine.preview,
                audioPlayer: AudioPlayer.preview,
                notificationManager: NotificationManager.preview
            )
        )
    }
}

// MARK: - 禅意控制按钮组件

/// 控制按钮样式类型
enum ZenControlButtonStyle {
    case primary(color: Color)
    case secondary
    case destructive
}

/// 禅意控制按钮 - 专为主界面控制设计的优雅按钮
struct ZenControlButton: View {
    let title: String
    let icon: String?
    let style: ZenControlButtonStyle
    let isEnabled: Bool
    var isLarge: Bool = false
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            if isEnabled {
                // 添加触觉反馈
                NSHapticFeedbackManager.defaultPerformer.perform(
                    .levelChange,
                    performanceTime: .default
                )
                action()
            }
        }) {
            HStack(spacing: isLarge ? 8 : 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: isLarge ? 18 : 14, weight: .semibold))
                        .scaleEffect(isPressed ? 0.9 : 1.0)
                }
                
                Text(title)
                    .font(.system(
                        size: isLarge ? 16 : 14,
                        weight: isLarge ? .bold : .semibold,
                        design: .rounded
                    ))
            }
            .foregroundColor(foregroundColor)
            .padding(.horizontal, isLarge ? 28 : 18)
            .padding(.vertical, isLarge ? 14 : 10)
            .background(backgroundView)
            .overlay(overlayBorder)
            .cornerRadius(isLarge ? 14 : 10)
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowY
            )
            .scaleEffect(scaleAmount)
            .animation(.zenQuick, value: isPressed)
            .animation(.zenSmooth, value: isHovered)
            .animation(.zenSmooth, value: isEnabled)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
        .onHover { hovering in
            if isEnabled {
                isHovered = hovering
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if isEnabled && !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
    
    // MARK: - 样式计算属性
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            if !isEnabled {
                return Color.zenSecondaryText.opacity(0.5)
            }
            return isHovered ? Color.zenTextGray : Color.zenTextGray.opacity(0.9)
        case .destructive:
            return isEnabled ? Color(hex: "#FF3B30") : Color.zenSecondaryText.opacity(0.5)
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary(let color):
            // 主按钮 - 渐变背景，强调重要性
            ZStack {
                // 底层渐变
                LinearGradient(
                    colors: [
                        color.opacity(0.9),
                        color
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 高光层
                if isHovered && isEnabled {
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                }
            }
            
        case .secondary:
            // 次要按钮 - 半透明背景
            ZStack {
                // 基础背景
                Color.zenCardBackground
                    .opacity(isEnabled ? (isHovered ? 0.95 : 0.85) : 0.5)
                
                // 悬停时的微妙渐变
                if isHovered && isEnabled {
                    LinearGradient(
                        colors: [
                            Color.zenBlue.opacity(0.05),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            
        case .destructive:
            // 破坏性操作按钮
            Color(hex: "#FF3B30")
                .opacity(isEnabled ? (isHovered ? 0.15 : 0.1) : 0.05)
        }
    }
    
    @ViewBuilder
    private var overlayBorder: some View {
        switch style {
        case .primary:
            // 主按钮不需要边框
            EmptyView()
            
        case .secondary:
            // 次要按钮 - 细微边框增强轮廓
            RoundedRectangle(cornerRadius: isLarge ? 14 : 10)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.zenDivider.opacity(isHovered ? 0.6 : 0.4),
                            Color.zenDivider.opacity(isHovered ? 0.4 : 0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
            
        case .destructive:
            // 破坏性按钮 - 红色边框警示
            RoundedRectangle(cornerRadius: isLarge ? 14 : 10)
                .strokeBorder(
                    Color(hex: "#FF3B30").opacity(isEnabled ? 0.3 : 0.1),
                    lineWidth: 1.5
                )
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary(let color):
            return color.opacity(isPressed ? 0.2 : (isHovered ? 0.5 : 0.35))
        case .secondary:
            return Color.black.opacity(isPressed ? 0.05 : (isHovered ? 0.15 : 0.1))
        case .destructive:
            return Color(hex: "#FF3B30").opacity(isPressed ? 0.1 : (isHovered ? 0.25 : 0.15))
        }
    }
    
    private var shadowRadius: CGFloat {
        if !isEnabled { return 0 }
        
        switch style {
        case .primary:
            return isPressed ? 4 : (isHovered ? 10 : 6)
        case .secondary:
            return isPressed ? 2 : (isHovered ? 6 : 3)
        case .destructive:
            return isPressed ? 2 : (isHovered ? 5 : 3)
        }
    }
    
    private var shadowY: CGFloat {
        if !isEnabled { return 0 }
        return isPressed ? 1 : (isHovered ? 4 : 2)
    }
    
    private var scaleAmount: CGFloat {
        if !isEnabled { return 1.0 }
        if isPressed { return 0.96 }
        if isHovered { return 1.02 }
        return 1.0
    }
}