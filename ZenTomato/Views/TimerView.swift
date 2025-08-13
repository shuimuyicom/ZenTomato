//
//  TimerView.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  计时器视图 - 重新设计的现代禅意界面
//

import SwiftUI

/// 计时器视图 - 全新设计
struct TimerView: View {
    // MARK: - Properties
    
    /// 计时引擎
    @ObservedObject var timerEngine: TimerEngine
    
    /// 是否显示设置面板
    @State private var showingSettings = false
    
    /// 主按钮按下状态
    @State private var isMainButtonPressed = false
    
    /// 动画触发器
    @State private var animateGradient = false
    @State private var animateRipple = false
    @State private var pulseAnimation = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 呼吸动画背景
            BreathingBackgroundView(phaseColor: timerEngine.currentPhase.color)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // 顶部标题 - 更紧凑
                    modernHeader
                        .padding(.top, 20)
                    
                    // 主要计时显示 - 核心区域
                    modernTimerDisplay
                        .padding(.vertical, 10)
                    
                    // 现代化控制区域 - 紧凑设计
                    modernControlSection
                    
                    // 时间设置卡片 - 始终显示的紧凑版本
                    modernTimeCards
                        .padding(.horizontal, 20)
                    
                    // 底部状态信息
                    modernStatusBar
                        .padding(.bottom, 20)
                }
            }
        }
        .frame(width: 380, height: 680)
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Modern Subviews
    
    /// 现代化头部
    private var modernHeader: some View {
        VStack(spacing: 4) {
            // 阶段小标签
            HStack(spacing: 6) {
                Image(systemName: timerEngine.currentPhase.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(timerEngine.currentPhase.color)
                
                Text(timerEngine.currentPhase.displayName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.zenSecondaryText)
                    .tracking(0.5)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(timerEngine.currentPhase.color.opacity(0.1))
            )
            
            // 完成进度
            if timerEngine.completedCycles > 0 {
                HStack(spacing: 4) {
                    ForEach(0..<timerEngine.configuration.cyclesBeforeLongBreak, id: \.self) { index in
                        Circle()
                            .fill(index < timerEngine.completedCycles ? 
                                  Color.zenGold : Color.zenDivider)
                            .frame(width: 5, height: 5)
                    }
                }
                .padding(.top, 4)
            }
        }
    }
    
    /// 现代化时间显示
    private var modernTimerDisplay: some View {
        VStack(spacing: 8) {
            // 时间显示 - 使用更大更突出的字体
            Text(timerEngine.formattedTimeRemaining)
                .font(.system(size: 86, weight: .ultraLight, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            timerEngine.currentPhase.color,
                            timerEngine.currentPhase.color.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .monospacedDigit()
                .shadow(color: timerEngine.currentPhase.color.opacity(0.2), radius: 20)
                .scaleEffect(pulseAnimation ? 1.02 : 1.0)
                .animation(
                    timerEngine.currentState == .running ?
                    Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true) :
                    Animation.easeInOut(duration: 0.3),
                    value: pulseAnimation
                )
            
            // 进度条 - 细线设计
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.zenDivider.opacity(0.3))
                        .frame(height: 4)
                    
                    // 进度
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [
                                    timerEngine.currentPhase.color.opacity(0.8),
                                    timerEngine.currentPhase.color
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * timerEngine.progress, height: 4)
                        .animation(.zenSmooth, value: timerEngine.progress)
                    
                    // 进度端点光晕
                    if timerEngine.progress > 0 && timerEngine.progress < 1 {
                        Circle()
                            .fill(timerEngine.currentPhase.color)
                            .frame(width: 8, height: 8)
                            .shadow(color: timerEngine.currentPhase.color.opacity(0.6), radius: 4)
                            .offset(x: geometry.size.width * timerEngine.progress - 4)
                            .animation(.zenSmooth, value: timerEngine.progress)
                    }
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 40)
            .padding(.top, 8)
        }
    }
    
    /// 现代化控制区域 - 紧凑设计
    private var modernControlSection: some View {
        HStack(spacing: 24) {
            // 跳过按钮
            ModernControlButton(
                icon: "forward.end.fill",
                action: { timerEngine.skip() },
                isDisabled: timerEngine.currentState == .idle,
                color: Color.zenSecondaryText
            )
            
            // 主控制按钮 - 更大更突出
            Button(action: {
                withAnimation(.zenBounceIn) {
                    timerEngine.toggleTimer()
                }
            }) {
                ZStack {
                    // 外圈装饰
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    mainButtonColor.opacity(0.3),
                                    mainButtonColor.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 80, height: 80)
                    
                    // 主按钮
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    mainButtonColor,
                                    mainButtonColor.opacity(0.9)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .shadow(
                            color: mainButtonColor.opacity(0.4),
                            radius: isMainButtonPressed ? 4 : 8,
                            y: isMainButtonPressed ? 2 : 4
                        )
                    
                    Image(systemName: mainButtonIcon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isMainButtonPressed ? 0.95 : 1.0)
            .onLongPressGesture(
                minimumDuration: 0,
                maximumDistance: .infinity,
                pressing: { pressing in
                    withAnimation(.zenQuick) {
                        isMainButtonPressed = pressing
                    }
                },
                perform: {}
            )
            
            // 重置按钮
            ModernControlButton(
                icon: "arrow.counterclockwise",
                action: { timerEngine.reset() },
                color: Color.zenSecondaryText
            )
        }
        .padding(.vertical, 16)
    }
    
    /// 现代化时间设置卡片
    private var modernTimeCards: some View {
        VStack(spacing: 12) {
            // 标题栏
            HStack {
                Label("时间设置", systemImage: "clock")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.zenTextGray)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.zenSmooth) {
                        showingSettings.toggle()
                    }
                }) {
                    Image(systemName: showingSettings ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color.zenSecondaryText)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 4)
            
            // 时间设置网格
            if showingSettings {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ModernTimeCard(
                        title: "工作时长",
                        value: Binding(
                            get: { Int(timerEngine.configuration.workDuration / 60) },
                            set: { timerEngine.configuration.workDuration = TimeInterval($0 * 60) }
                        ),
                        unit: "分钟",
                        color: Color.zenRed,
                        icon: "desktopcomputer"
                    )
                    
                    ModernTimeCard(
                        title: "短休息",
                        value: Binding(
                            get: { Int(timerEngine.configuration.shortBreakDuration / 60) },
                            set: { timerEngine.configuration.shortBreakDuration = TimeInterval($0 * 60) }
                        ),
                        unit: "分钟",
                        color: Color.zenGreen,
                        icon: "cup.and.saucer.fill"
                    )
                    
                    ModernTimeCard(
                        title: "长休息",
                        value: Binding(
                            get: { Int(timerEngine.configuration.longBreakDuration / 60) },
                            set: { timerEngine.configuration.longBreakDuration = TimeInterval($0 * 60) }
                        ),
                        unit: "分钟",
                        color: Color.zenBlue,
                        icon: "leaf.fill"
                    )
                    
                    ModernTimeCard(
                        title: "工作周期",
                        value: $timerEngine.configuration.cyclesBeforeLongBreak,
                        unit: "个",
                        color: Color.zenGold,
                        icon: "arrow.triangle.2.circlepath"
                    )
                }
                .transition(.zenSlide)
            } else {
                // 紧凑显示当前设置
                HStack(spacing: 16) {
                    CompactTimeInfo(
                        icon: "desktopcomputer",
                        value: Int(timerEngine.configuration.workDuration / 60),
                        color: Color.zenRed
                    )
                    
                    CompactTimeInfo(
                        icon: "cup.and.saucer.fill",
                        value: Int(timerEngine.configuration.shortBreakDuration / 60),
                        color: Color.zenGreen
                    )
                    
                    CompactTimeInfo(
                        icon: "leaf.fill",
                        value: Int(timerEngine.configuration.longBreakDuration / 60),
                        color: Color.zenBlue
                    )
                    
                    CompactTimeInfo(
                        icon: "arrow.triangle.2.circlepath",
                        value: timerEngine.configuration.cyclesBeforeLongBreak,
                        color: Color.zenGold
                    )
                }
                .transition(.zenFade)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.zenCardBackground.opacity(0.95))
                .shadow(color: Color.black.opacity(0.05), radius: 10)
        )
    }
    
    /// 现代化状态栏
    private var modernStatusBar: some View {
        HStack(spacing: 0) {
            // 今日完成
            VStack(spacing: 4) {
                Text("\(timerEngine.completedCycles)")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.zenGreen)
                
                Text("已完成")
                    .font(.system(size: 11))
                    .foregroundColor(Color.zenSecondaryText)
            }
            .frame(maxWidth: .infinity)
            
            // 分隔线
            Rectangle()
                .fill(Color.zenDivider.opacity(0.5))
                .frame(width: 1, height: 30)
            
            // 当前状态
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(timerEngine.currentState == .running ? Color.zenGold : Color.zenSecondaryText)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(timerEngine.currentState == .running ? Color.zenGold : Color.clear, lineWidth: 1)
                                .scaleEffect(animateRipple ? 3 : 1)
                                .opacity(animateRipple ? 0 : 1)
                                .animation(
                                    timerEngine.currentState == .running ?
                                    Animation.easeOut(duration: 2).repeatForever(autoreverses: false) :
                                    Animation.easeOut(duration: 0),
                                    value: animateRipple
                                )
                        )
                    
                    Text(statusText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.zenTextGray)
                }
                
                Text(nextPhaseHint)
                    .font(.system(size: 11))
                    .foregroundColor(Color.zenSecondaryText)
            }
            .frame(maxWidth: .infinity)
            
            // 分隔线
            Rectangle()
                .fill(Color.zenDivider.opacity(0.5))
                .frame(width: 1, height: 30)
            
            // 下一阶段
            VStack(spacing: 4) {
                Image(systemName: nextPhaseIcon)
                    .font(.system(size: 20))
                    .foregroundColor(nextPhaseColor)
                
                Text(nextPhaseText)
                    .font(.system(size: 11))
                    .foregroundColor(Color.zenSecondaryText)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Computed Properties
    
    /// 状态文本
    private var statusText: String {
        switch timerEngine.currentState {
        case .idle:
            return "准备就绪"
        case .running:
            return "专注中"
        case .paused:
            return "已暂停"
        case .completed:
            return "已完成"
        }
    }
    
    /// 下一阶段提示
    private var nextPhaseHint: String {
        switch timerEngine.currentPhase {
        case .work:
            return "保持专注"
        case .shortBreak:
            return "短暂休息"
        case .longBreak:
            return "深度放松"
        }
    }
    
    /// 下一阶段文本
    private var nextPhaseText: String {
        switch timerEngine.currentPhase {
        case .work:
            let cycles = timerEngine.completedCycles + 1
            if cycles % timerEngine.configuration.cyclesBeforeLongBreak == 0 {
                return "长休息"
            } else {
                return "短休息"
            }
        case .shortBreak, .longBreak:
            return "工作"
        }
    }
    
    /// 下一阶段颜色
    private var nextPhaseColor: Color {
        switch timerEngine.currentPhase {
        case .work:
            let cycles = timerEngine.completedCycles + 1
            if cycles % timerEngine.configuration.cyclesBeforeLongBreak == 0 {
                return Color.zenBlue
            } else {
                return Color.zenGreen
            }
        case .shortBreak, .longBreak:
            return Color.zenRed
        }
    }
    
    /// 下一阶段图标
    private var nextPhaseIcon: String {
        switch timerEngine.currentPhase {
        case .work:
            let cycles = timerEngine.completedCycles + 1
            if cycles % timerEngine.configuration.cyclesBeforeLongBreak == 0 {
                return "leaf.fill"
            } else {
                return "cup.and.saucer.fill"
            }
        case .shortBreak, .longBreak:
            return "desktopcomputer"
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
            return Color.zenGold
        case .paused:
            return Color.zenSecondaryText
        }
    }
    
    // MARK: - Methods
    
    /// 启动动画
    private func startAnimations() {
        animateGradient = true
        animateRipple = true
        pulseAnimation = true
    }
}

// MARK: - Modern Supporting Components

/// 现代化控制按钮
struct ModernControlButton: View {
    let icon: String
    let action: () -> Void
    var isDisabled: Bool = false
    var color: Color = Color.zenAccent
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.zenCardBackground.opacity(0.9))
                    .frame(width: 44, height: 44)
                    .shadow(
                        color: Color.black.opacity(0.08),
                        radius: isPressed ? 2 : 4,
                        y: isPressed ? 1 : 2
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isDisabled ? Color.zenSecondaryText.opacity(0.5) : color)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.zenQuick) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
}

/// 现代化时间卡片
struct ModernTimeCard: View {
    let title: String
    @Binding var value: Int
    let unit: String
    let color: Color
    let icon: String
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 8) {
            // 图标和标题
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.zenTextGray)
            }
            
            // 值显示
            Text("\(value)")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(color)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.zenBounceIn, value: isAnimating)
            
            Text(unit)
                .font(.system(size: 10))
                .foregroundColor(Color.zenSecondaryText)
            
            // 调节按钮
            HStack(spacing: 20) {
                Button(action: {
                    if value > 1 {
                        withAnimation(.zenQuick) {
                            value -= 1
                            triggerAnimation()
                        }
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(value > 1 ? color.opacity(0.7) : Color.zenSecondaryText.opacity(0.3))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(value <= 1)
                
                Button(action: {
                    if value < 60 {
                        withAnimation(.zenQuick) {
                            value += 1
                            triggerAnimation()
                        }
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(value < 60 ? color.opacity(0.7) : Color.zenSecondaryText.opacity(0.3))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(value >= 60)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.08))
        )
    }
    
    private func triggerAnimation() {
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isAnimating = false
        }
    }
}

/// 紧凑时间信息
struct CompactTimeInfo: View {
    let icon: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            
            Text("\(value)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Color.zenTextGray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(timerEngine: TimerEngine.preview)
            .frame(width: 380, height: 680)
    }
}