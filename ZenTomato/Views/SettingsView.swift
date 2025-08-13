//
//  SettingsView.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  设置视图 - 禅意美学的系统设置界面
//

import SwiftUI
import UserNotifications

/// 设置视图
struct SettingsView: View {
    // MARK: - Properties
    
    /// 计时引擎
    @ObservedObject var timerEngine: TimerEngine
    
    /// 菜单栏管理器
    @ObservedObject var menuBarManager: MenuBarManager
    
    /// 通知管理器
    @ObservedObject var notificationManager: NotificationManager
    
    /// 是否开机自启动
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    
    /// 动画状态
    @State private var selectedSection: String? = nil
    @State private var animateIcon = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 背景
            BreathingBackgroundView(phaseColor: .zenBlue)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // 标题
                    zenHeader
                        .padding(.top, 30)
                    
                    // 通用设置
                    zenGeneralSettings
                    
                    // 通知设置
                    zenNotificationSettings
                    
                    // 系统集成
                    zenSystemIntegration
                    
                    // 关于部分
                    zenAboutSection
                    
                    // 重置设置
                    zenResetSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .frame(width: 380, height: 680)
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Subviews
    
    /// 禅意标题
    private var zenHeader: some View {
        VStack(spacing: 12) {
            // 动画图标
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.zenBlue.opacity(0.2),
                                Color.zenBlue.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: "gearshape.2")
                    .font(.system(size: 28))
                    .foregroundColor(Color.zenBlue)
                    .rotationEffect(.degrees(animateIcon ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 20)
                            .repeatForever(autoreverses: false),
                        value: animateIcon
                    )
            }
            
            Text("设置")
                .font(.system(size: 24, weight: .light))
                .foregroundColor(Color.zenTextGray)
                .tracking(3)
            
            Text("调整您的专注偏好")
                .font(.system(size: 12))
                .foregroundColor(Color.zenSecondaryText)
        }
    }
    
    /// 通用设置
    private var zenGeneralSettings: some View {
        ZenSettingCard(
            title: "通用设置",
            icon: "slider.horizontal.3",
            color: .zenAccent,
            isExpanded: selectedSection == "general"
        ) {
            VStack(spacing: 12) {
                // 自动开始休息
                ZenToggleItem(
                    icon: "play.circle",
                    title: "自动开始休息",
                    subtitle: "工作完成后自动开始休息计时",
                    isOn: $timerEngine.configuration.autoStartBreaks
                )
                
                // 自动开始工作
                ZenToggleItem(
                    icon: "arrow.triangle.2.circlepath",
                    title: "自动开始工作",
                    subtitle: "休息完成后自动开始工作计时",
                    isOn: $timerEngine.configuration.autoStartWork
                )
                
                // 在菜单栏显示时间
                ZenToggleItem(
                    icon: "timer",
                    title: "菜单栏显示时间",
                    subtitle: "在菜单栏显示倒计时",
                    isOn: $timerEngine.configuration.showTimeInMenuBar
                )
            }
        }
        .onTapGesture {
            withAnimation(.zenSmooth) {
                selectedSection = selectedSection == "general" ? nil : "general"
            }
        }
    }
    
    /// 通知设置
    private var zenNotificationSettings: some View {
        ZenSettingCard(
            title: "通知设置",
            icon: "bell.badge",
            color: .zenGreen,
            isExpanded: selectedSection == "notification"
        ) {
            VStack(spacing: 16) {
                // 通知权限状态
                ZenNotificationStatus(
                    status: notificationManager.authorizationStatus,
                    isAuthorized: notificationManager.isAuthorized,
                    onRequestPermission: {
                        notificationManager.requestPermission()
                    },
                    onOpenSettings: {
                        notificationManager.openSystemSettings()
                    }
                )
                
                // 通知说明
                if notificationManager.isAuthorized {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color.zenSuccess)
                        
                        Text("通知已启用，将在阶段切换时提醒您")
                            .font(.system(size: 11))
                            .foregroundColor(Color.zenSuccess)
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.zenSuccess.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .onTapGesture {
            withAnimation(.zenSmooth) {
                selectedSection = selectedSection == "notification" ? nil : "notification"
            }
        }
    }
    
    /// 系统集成
    private var zenSystemIntegration: some View {
        ZenSettingCard(
            title: "系统集成",
            icon: "laptopcomputer",
            color: .zenGold,
            isExpanded: selectedSection == "system"
        ) {
            VStack(spacing: 12) {
                // 开机自启动
                ZenToggleItem(
                    icon: "power",
                    title: "开机自启动",
                    subtitle: "系统启动时自动运行禅番茄",
                    isOn: $launchAtLogin
                )
                
                // 全局快捷键（占位）
                ZenComingSoonItem(
                    icon: "keyboard",
                    title: "全局快捷键",
                    subtitle: "即将推出"
                )
                
                // URL Scheme（占位）
                ZenComingSoonItem(
                    icon: "link",
                    title: "URL Scheme",
                    subtitle: "zentomato:// 协议支持"
                )
            }
        }
        .onTapGesture {
            withAnimation(.zenSmooth) {
                selectedSection = selectedSection == "system" ? nil : "system"
            }
        }
    }
    
    /// 关于部分
    private var zenAboutSection: some View {
        ZenSettingCard(
            title: "关于",
            icon: "info.circle",
            color: .zenBlue,
            isExpanded: selectedSection == "about"
        ) {
            VStack(spacing: 16) {
                // Logo 和版本
                HStack(spacing: 16) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color.zenBlue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("禅番茄 ZenTomato")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.zenTextGray)
                        
                        Text("版本 1.0.0")
                            .font(.system(size: 11))
                            .foregroundColor(Color.zenSecondaryText)
                    }
                    
                    Spacer()
                }
                
                // 介绍文字
                Text("融合番茄工作法与禅意美学，帮助您专注工作、平衡生活。")
                    .font(.system(size: 11))
                    .foregroundColor(Color.zenSecondaryText)
                    .lineSpacing(4)
                
                // 链接按钮
                HStack(spacing: 12) {
                    ZenLinkButton(
                        title: "官网",
                        icon: "globe",
                        action: {}
                    )
                    
                    ZenLinkButton(
                        title: "反馈",
                        icon: "envelope",
                        action: {}
                    )
                    
                    ZenLinkButton(
                        title: "评分",
                        icon: "star",
                        action: {}
                    )
                }
            }
        }
        .onTapGesture {
            withAnimation(.zenSmooth) {
                selectedSection = selectedSection == "about" ? nil : "about"
            }
        }
    }
    
    /// 重置设置
    private var zenResetSection: some View {
        VStack(spacing: 12) {
            Button(action: resetToDefaults) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16))
                    
                    Text("重置为默认设置")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(Color.zenWarning)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.zenWarning.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.zenWarning.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("此操作将重置所有设置")
                .font(.system(size: 10))
                .foregroundColor(Color.zenSecondaryText)
        }
    }
    
    // MARK: - Actions
    
    /// 重置为默认设置
    private func resetToDefaults() {
        let alert = NSAlert()
        alert.messageText = "重置设置"
        alert.informativeText = "确定要将所有设置重置为默认值吗？此操作不可撤销。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "重置")
        alert.addButton(withTitle: "取消")
        
        if alert.runModal() == .alertFirstButtonReturn {
            timerEngine.configuration = TimerConfiguration.default
            launchAtLogin = false
            menuBarManager.showTimeInMenuBar = true
        }
    }
    
    /// 启动动画
    private func startAnimations() {
        animateIcon = true
    }
}

// MARK: - Supporting Components

/// 禅意设置卡片
struct ZenSettingCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let isExpanded: Bool
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.1))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundColor(color)
                    }
                    
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.zenTextGray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color.zenSecondaryText)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .animation(.zenQuick, value: isExpanded)
            }
            .padding(16)
            
            // 内容
            if isExpanded {
                content
                    .padding(16)
                    .padding(.top, -8)
                    .transition(.zenFade)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.zenCardBackground.opacity(0.95))
                .shadow(color: Color.black.opacity(0.05), radius: 10)
        )
    }
}

/// 禅意开关项
struct ZenToggleItem: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(isOn ? Color.zenAccent : Color.zenSecondaryText)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.zenTextGray)
                
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(Color.zenSecondaryText)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle())
                .labelsHidden()
                .scaleEffect(0.8)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isOn ? Color.zenAccent.opacity(0.05) : Color.zenGray.opacity(0.3))
        )
        .animation(.zenQuick, value: isOn)
    }
}

/// 即将推出项
struct ZenComingSoonItem: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color.zenSecondaryText.opacity(0.5))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.zenTextGray.opacity(0.5))
                
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(Color.zenSecondaryText.opacity(0.5))
            }
            
            Spacer()
            
            Text("Coming Soon")
                .font(.system(size: 9))
                .foregroundColor(Color.zenSecondaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.zenGray.opacity(0.5))
                .cornerRadius(4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.zenGray.opacity(0.2))
        )
        .opacity(0.6)
    }
}

/// 通知状态组件
struct ZenNotificationStatus: View {
    let status: UNAuthorizationStatus
    let isAuthorized: Bool
    let onRequestPermission: () -> Void
    let onOpenSettings: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: status.icon)
                .font(.system(size: 20))
                .foregroundColor(status.color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("通知权限")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.zenTextGray)
                
                Text(status.displayName)
                    .font(.system(size: 10))
                    .foregroundColor(Color.zenSecondaryText)
            }
            
            Spacer()
            
            if !isAuthorized {
                Button(action: {
                    if status == .notDetermined {
                        onRequestPermission()
                    } else {
                        onOpenSettings()
                    }
                }) {
                    Text(status == .notDetermined ? "请求权限" : "打开设置")
                        .font(.system(size: 11))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.zenGreen)
                        .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.zenGray.opacity(0.3))
        )
    }
}

/// 链接按钮
struct ZenLinkButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                
                Text(title)
                    .font(.system(size: 9))
            }
            .foregroundColor(isHovered ? Color.zenAccent : Color.zenSecondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.zenGray.opacity(isHovered ? 0.5 : 0.3))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.zenQuick) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            timerEngine: TimerEngine.preview,
            menuBarManager: MenuBarManager(
                timerEngine: TimerEngine.preview,
                audioPlayer: AudioPlayer.preview,
                notificationManager: NotificationManager.preview
            ),
            notificationManager: NotificationManager.preview
        )
        .frame(width: 380, height: 680)
    }
}