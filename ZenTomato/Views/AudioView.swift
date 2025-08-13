//
//  AudioView.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  音效设置视图 - 禅意美学的音效控制界面
//

import SwiftUI

/// 音效设置视图
struct AudioView: View {
    // MARK: - Properties
    
    /// 音频播放器
    @ObservedObject var audioPlayer: AudioPlayer
    
    /// 动画状态
    @State private var animateWave = false
    @State private var selectedSound: SoundType? = nil
    @State private var showVolumeDetails = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 背景
            BreathingBackgroundView(phaseColor: .zenGreen)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // 标题
                    zenHeader
                        .padding(.top, 30)
                    
                    // 主开关
                    zenMainToggle
                    
                    // 音效控制
                    if !audioPlayer.settings.isMuted {
                        zenSoundControls
                            .transition(.zenScale)
                    }
                    
                    // 音效预设
                    zenPresets
                    
                    // 音效说明
                    zenDescription
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
            // 动画音波图标
            ZStack {
                // 外圈音波
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color.zenGreen.opacity(0.3 - Double(i) * 0.1), lineWidth: 1)
                        .frame(width: CGFloat(40 + i * 20), height: CGFloat(40 + i * 20))
                        .scaleEffect(animateWave ? 1.2 : 0.8)
                        .opacity(animateWave ? 0 : 1)
                        .animation(
                            Animation.easeOut(duration: 2)
                                .delay(Double(i) * 0.2)
                                .repeatForever(autoreverses: false),
                            value: animateWave
                        )
                }
                
                // 中心图标
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.zenGreen.opacity(0.2),
                                Color.zenGreen.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: audioPlayer.settings.isMuted ? "speaker.slash.fill" : "speaker.wave.3.fill")
                    .font(.system(size: 26))
                    .foregroundColor(Color.zenGreen)
            }
            
            Text("音效")
                .font(.system(size: 24, weight: .light))
                .foregroundColor(Color.zenTextGray)
                .tracking(3)
            
            Text("营造专注氛围")
                .font(.system(size: 12))
                .foregroundColor(Color.zenSecondaryText)
        }
    }
    
    /// 主开关
    private var zenMainToggle: some View {
        ZenSoundToggleCard(
            title: "音效总开关",
            subtitle: audioPlayer.settings.isMuted ? "所有音效已静音" : "音效已启用",
            icon: audioPlayer.settings.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill",
            isOn: Binding(
                get: { !audioPlayer.settings.isMuted },
                set: { audioPlayer.settings.isMuted = !$0 }
            ),
            color: audioPlayer.settings.isMuted ? .zenSecondaryText : .zenGreen
        )
    }
    
    /// 音效控制
    private var zenSoundControls: some View {
        VStack(spacing: 16) {
            // 开始音效
            ZenSoundControlCard(
                soundType: .windup,
                title: "开始音效",
                subtitle: "工作阶段开始时播放",
                icon: "play.circle.fill",
                volume: $audioPlayer.settings.windupVolume,
                isSelected: selectedSound == .windup,
                onTest: {
                    selectedSound = .windup
                    audioPlayer.testSound(.windup)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        selectedSound = nil
                    }
                }
            )
            
            // 结束音效
            ZenSoundControlCard(
                soundType: .ding,
                title: "结束音效",
                subtitle: "任何阶段结束时播放",
                icon: "bell.fill",
                volume: $audioPlayer.settings.dingVolume,
                isSelected: selectedSound == .ding,
                onTest: {
                    selectedSound = .ding
                    audioPlayer.testSound(.ding)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        selectedSound = nil
                    }
                }
            )
            
            // 背景滴答声
            ZenTickingSoundCard(
                isEnabled: $audioPlayer.settings.enableTicking,
                volume: $audioPlayer.settings.tickingVolume,
                isPlaying: audioPlayer.isTickingPlaying,
                onToggle: {
                    audioPlayer.testSound(.ticking)
                }
            )
        }
    }
    
    /// 音效预设
    private var zenPresets: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("快速预设", systemImage: "wand.and.stars")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.zenTextGray)
                Spacer()
            }
            
            HStack(spacing: 12) {
                ZenPresetButton(
                    title: "静音",
                    icon: "speaker.slash",
                    color: .zenSecondaryText,
                    action: {
                        withAnimation(.zenSmooth) {
                            audioPlayer.settings.isMuted = true
                        }
                    }
                )
                
                ZenPresetButton(
                    title: "轻柔",
                    icon: "speaker.wave.1",
                    color: .zenBlue,
                    action: {
                        withAnimation(.zenSmooth) {
                            audioPlayer.settings.isMuted = false
                            audioPlayer.settings.windupVolume = 0.5
                            audioPlayer.settings.dingVolume = 0.5
                            audioPlayer.settings.tickingVolume = 0.3
                        }
                    }
                )
                
                ZenPresetButton(
                    title: "标准",
                    icon: "speaker.wave.2",
                    color: .zenGreen,
                    action: {
                        withAnimation(.zenSmooth) {
                            audioPlayer.settings.isMuted = false
                            audioPlayer.settings.windupVolume = 1.0
                            audioPlayer.settings.dingVolume = 1.0
                            audioPlayer.settings.tickingVolume = 0.5
                        }
                    }
                )
                
                ZenPresetButton(
                    title: "响亮",
                    icon: "speaker.wave.3",
                    color: .zenGold,
                    action: {
                        withAnimation(.zenSmooth) {
                            audioPlayer.settings.isMuted = false
                            audioPlayer.settings.windupVolume = 1.5
                            audioPlayer.settings.dingVolume = 1.5
                            audioPlayer.settings.tickingVolume = 1.0
                        }
                    }
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.zenCardBackground.opacity(0.95))
                .shadow(color: Color.black.opacity(0.05), radius: 10)
        )
    }
    
    /// 音效说明
    private var zenDescription: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .foregroundColor(Color.zenInfo)
                
                Text("使用提示")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.zenTextGray)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ZenTipRow(text: "双击音量滑块可重置为默认值")
                ZenTipRow(text: "音量范围支持 0% - 200%")
                ZenTipRow(text: "滴答声仅在工作期间播放")
                ZenTipRow(text: "点击播放按钮可预听音效")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.zenInfo.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.zenInfo.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Methods
    
    /// 启动动画
    private func startAnimations() {
        animateWave = true
    }
}

// MARK: - Supporting Components

/// 音效开关卡片
struct ZenSoundToggleCard: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.zenTextGray)
                
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(Color.zenSecondaryText)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle())
                .labelsHidden()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.zenCardBackground.opacity(0.95))
                .shadow(color: Color.black.opacity(0.05), radius: 10)
        )
    }
}

/// 音效控制卡片
struct ZenSoundControlCard: View {
    let soundType: SoundType
    let title: String
    let subtitle: String
    let icon: String
    @Binding var volume: Float
    let isSelected: Bool
    let onTest: () -> Void
    
    @State private var isSliderActive = false
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题栏
            HStack {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.zenAccent.opacity(0.15),
                                        Color.zenAccent.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundColor(Color.zenAccent)
                            .scaleEffect(isSelected ? 1.2 : 1.0)
                            .animation(.zenBounceIn, value: isSelected)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.zenTextGray)
                        
                        Text(subtitle)
                            .font(.system(size: 10))
                            .foregroundColor(Color.zenSecondaryText)
                    }
                }
                
                Spacer()
                
                // 测试按钮
                Button(action: onTest) {
                    ZStack {
                        Circle()
                            .fill(isSelected ? Color.zenAccent : Color.zenGray.opacity(0.3))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: isSelected ? "stop.fill" : "play.fill")
                            .font(.system(size: 12))
                            .foregroundColor(isSelected ? .white : Color.zenTextGray)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // 音量控制
            ZenVolumeSlider(
                volume: $volume,
                isActive: $isSliderActive,
                color: Color.zenAccent
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.zenCardBackground.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isSliderActive ? Color.zenAccent.opacity(0.3) : Color.clear,
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.black.opacity(0.03), radius: 8)
        )
        .animation(.zenQuick, value: isSliderActive)
    }
}

/// 滴答声控制卡片
struct ZenTickingSoundCard: View {
    @Binding var isEnabled: Bool
    @Binding var volume: Float
    let isPlaying: Bool
    let onToggle: () -> Void
    
    @State private var isSliderActive = false
    @State private var animateMetronome = false
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题栏和开关
            HStack {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.zenBlue.opacity(0.15),
                                        Color.zenBlue.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "metronome.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color.zenBlue)
                            .rotationEffect(.degrees(animateMetronome ? 10 : -10))
                            .animation(
                                isEnabled ?
                                Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true) :
                                Animation.easeInOut(duration: 0.5),
                                value: animateMetronome
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("背景滴答声")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.zenTextGray)
                        
                        Text("工作期间的节奏声")
                            .font(.system(size: 10))
                            .foregroundColor(Color.zenSecondaryText)
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .toggleStyle(SwitchToggleStyle())
                    .labelsHidden()
                    .onChange(of: isEnabled) { _, newValue in
                        animateMetronome = newValue
                        if !newValue && isPlaying {
                            onToggle()
                        }
                    }
            }
            
            // 音量控制（仅在启用时显示）
            if isEnabled {
                HStack {
                    ZenVolumeSlider(
                        volume: $volume,
                        isActive: $isSliderActive,
                        color: Color.zenBlue
                    )
                    
                    // 播放/停止按钮
                    Button(action: onToggle) {
                        ZStack {
                            Circle()
                                .fill(isPlaying ? Color.zenBlue : Color.zenGray.opacity(0.3))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                                .font(.system(size: 12))
                                .foregroundColor(isPlaying ? .white : Color.zenTextGray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .transition(.zenFade)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.zenCardBackground.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isSliderActive && isEnabled ? Color.zenBlue.opacity(0.3) : Color.clear,
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.black.opacity(0.03), radius: 8)
        )
        .animation(.zenQuick, value: isSliderActive)
        .animation(.zenSmooth, value: isEnabled)
        .onAppear {
            animateMetronome = isEnabled
        }
    }
}

/// 音量滑块
struct ZenVolumeSlider: View {
    @Binding var volume: Float
    @Binding var isActive: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "speaker")
                .font(.system(size: 12))
                .foregroundColor(Color.zenSecondaryText)
            
            Slider(
                value: $volume,
                in: 0...2,
                step: 0.1,
                onEditingChanged: { editing in
                    isActive = editing
                }
            )
            .controlSize(.small)
            .accentColor(color)
            .onTapGesture(count: 2) {
                withAnimation(.zenSmooth) {
                    volume = 1.0
                }
            }
            
            Image(systemName: "speaker.wave.3")
                .font(.system(size: 12))
                .foregroundColor(Color.zenSecondaryText)
            
            Text("\(Int(volume * 100))%")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(isActive ? color : Color.zenTextGray)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

/// 预设按钮
struct ZenPresetButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 10))
                    .foregroundColor(Color.zenSecondaryText)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
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

/// 提示行
struct ZenTipRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.zenInfo)
                .frame(width: 4, height: 4)
                .offset(y: 5)
            
            Text(text)
                .font(.system(size: 11))
                .foregroundColor(Color.zenSecondaryText)
                .lineSpacing(2)
        }
    }
}

// MARK: - Preview

struct AudioView_Previews: PreviewProvider {
    static var previews: some View {
        AudioView(audioPlayer: AudioPlayer.preview)
            .frame(width: 380, height: 680)
    }
}