//
//  TimerEngine.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  核心计时引擎 - 管理番茄钟的计时逻辑和状态转换
//

import Foundation
import Combine
import SwiftUI

/// 计时引擎
class TimerEngine: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 当前计时器状态
    @Published var currentState: TimerState = .idle
    
    /// 剩余时间（秒）
    @Published var timeRemaining: TimeInterval = 0
    
    /// 当前阶段
    @Published var currentPhase: TimerPhase = .work
    
    /// 已完成的工作周期数
    @Published var completedCycles: Int = 0
    
    /// 计时器配置
    @Published var configuration: TimerConfiguration {
        didSet {
            configuration.save()
            resetTimer()
        }
    }
    
    // MARK: - Private Properties
    
    /// 计时器
    private var timer: Timer?
    
    /// 当前阶段的开始时间
    private var phaseStartTime: Date?
    
    /// 暂停时的剩余时间
    private var pausedTimeRemaining: TimeInterval = 0
    
    /// 取消令牌集合
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    /// 当前阶段的总时长
    var currentPhaseDuration: TimeInterval {
        switch currentPhase {
        case .work:
            return configuration.workDuration
        case .shortBreak:
            return configuration.shortBreakDuration
        case .longBreak:
            return configuration.longBreakDuration
        }
    }
    
    /// 格式化的时间显示 (MM:SS)
    var formattedTimeRemaining: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// 进度百分比 (0.0 - 1.0)
    var progress: Double {
        guard currentPhaseDuration > 0 else { return 0 }
        return 1.0 - (timeRemaining / currentPhaseDuration)
    }
    
    /// 是否应该进入长休息
    private var shouldTakeLongBreak: Bool {
        return completedCycles > 0 && 
               completedCycles % configuration.cyclesBeforeLongBreak == 0
    }
    
    // MARK: - Initialization
    
    init() {
        self.configuration = TimerConfiguration.load()
        resetTimer()
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// 开始计时
    func start() {
        guard currentState != .running else { return }
        
        let isResumingFromPause = (currentState == .paused)
        
        if isResumingFromPause {
            // 从暂停恢复
            timeRemaining = pausedTimeRemaining
        } else {
            // 开始新的计时
            timeRemaining = currentPhaseDuration
        }
        
        currentState = .running
        phaseStartTime = Date()
        startTimer()
        
        // 根据是否从暂停恢复发送不同的通知
        if isResumingFromPause {
            // 发送恢复通知
            NotificationCenter.default.post(
                name: .timerResumed,
                object: nil,
                userInfo: ["phase": currentPhase]
            )
        } else {
            // 发送阶段开始通知
            NotificationCenter.default.post(
                name: .timerPhaseStarted,
                object: nil,
                userInfo: ["phase": currentPhase]
            )
        }
    }
    
    /// 暂停计时
    func pause() {
        guard currentState == .running else { return }
        
        currentState = .paused
        pausedTimeRemaining = timeRemaining
        stopTimer()
        
        // 发送暂停通知
        NotificationCenter.default.post(name: .timerPaused, object: nil)
    }
    
    /// 停止计时
    func stop() {
        currentState = .idle
        stopTimer()
        resetTimer()
        
        // 发送停止通知
        NotificationCenter.default.post(name: .timerStopped, object: nil)
    }
    
    /// 跳过当前阶段
    func skip() {
        guard currentState == .running || currentState == .paused else { return }
        
        stopTimer()
        completeCurrentPhase()
    }
    
    /// 重置计时器
    func reset() {
        // 先停止计时器
        currentState = .idle
        stopTimer()
        
        // 重置状态到工作阶段
        completedCycles = 0
        currentPhase = .work
        
        // 重置时间为工作时长
        timeRemaining = currentPhaseDuration
        pausedTimeRemaining = 0
        
        // 发送停止通知
        NotificationCenter.default.post(name: .timerStopped, object: nil)
    }
    
    /// 切换计时器状态（开始/暂停）
    func toggleTimer() {
        switch currentState {
        case .idle, .completed:
            start()
        case .running:
            pause()
        case .paused:
            start()
        }
    }
    
    // MARK: - Private Methods
    
    /// 设置绑定
    private func setupBindings() {
        // 监听配置变化
        $configuration
            .dropFirst()
            .sink { [weak self] _ in
                self?.resetTimer()
            }
            .store(in: &cancellables)
    }
    
    /// 重置计时器到初始状态
    private func resetTimer() {
        timeRemaining = currentPhaseDuration
        pausedTimeRemaining = 0
    }
    
    /// 启动定时器
    private func startTimer() {
        stopTimer() // 确保没有重复的定时器
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    /// 停止定时器
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// 更新计时器
    private func updateTimer() {
        guard currentState == .running else { return }
        
        if timeRemaining > 0 {
            timeRemaining -= 0.1
            
            // 每秒发送一次更新通知
            if Int(timeRemaining * 10) % 10 == 0 {
                NotificationCenter.default.post(
                    name: .timerTick,
                    object: nil,
                    userInfo: ["timeRemaining": timeRemaining]
                )
            }
        } else {
            // 计时结束
            completeCurrentPhase()
        }
    }
    
    /// 完成当前阶段
    private func completeCurrentPhase() {
        stopTimer()
        currentState = .completed
        
        // 发送阶段完成通知
        NotificationCenter.default.post(
            name: .timerPhaseCompleted,
            object: nil,
            userInfo: ["phase": currentPhase]
        )
        
        // 根据当前阶段决定下一阶段
        switch currentPhase {
        case .work:
            completedCycles += 1
            if shouldTakeLongBreak {
                currentPhase = .longBreak
            } else {
                currentPhase = .shortBreak
            }
            
            // 自动开始休息（如果配置了）
            if configuration.autoStartBreaks {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.start()
                }
            }
            
        case .shortBreak, .longBreak:
            currentPhase = .work
            
            // 自动开始工作（如果配置了）
            if configuration.autoStartWork {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.start()
                }
            }
        }
        
        // 重置计时器为新阶段
        resetTimer()
        
        // 如果没有自动开始，则回到空闲状态
        if !configuration.autoStartBreaks && !configuration.autoStartWork {
            currentState = .idle
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let timerPhaseStarted = Notification.Name("ZenTomato.timerPhaseStarted")
    static let timerPhaseCompleted = Notification.Name("ZenTomato.timerPhaseCompleted")
    static let timerPaused = Notification.Name("ZenTomato.timerPaused")
    static let timerResumed = Notification.Name("ZenTomato.timerResumed")
    static let timerStopped = Notification.Name("ZenTomato.timerStopped")
    static let timerTick = Notification.Name("ZenTomato.timerTick")
}

// MARK: - Preview Helper

extension TimerEngine {
    /// 创建预览用的计时引擎
    static var preview: TimerEngine {
        let engine = TimerEngine()
        engine.configuration.workDuration = 5 // 5秒用于预览测试
        engine.configuration.shortBreakDuration = 3
        engine.configuration.longBreakDuration = 5
        return engine
    }
}