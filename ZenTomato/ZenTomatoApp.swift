//
//  ZenTomatoApp.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  主应用入口 - 菜单栏应用
//

import SwiftUI
import AppKit

@main
struct ZenTomatoApp: App {
    // 使用 NSApplicationDelegateAdaptor 来管理应用生命周期
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // 创建一个空的场景，因为我们使用菜单栏
        Settings {
            EmptyView()
        }
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    
    /// 菜单栏管理器
    var menuBarManager: MenuBarManager?
    
    /// 计时引擎
    let timerEngine = TimerEngine()
    
    /// 音频播放器
    let audioPlayer = AudioPlayer()
    
    /// 通知管理器
    let notificationManager = NotificationManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 隐藏主窗口和 Dock 图标
        NSApp.setActivationPolicy(.accessory)
        
        // 初始化菜单栏
        menuBarManager = MenuBarManager(
            timerEngine: timerEngine,
            audioPlayer: audioPlayer,
            notificationManager: notificationManager
        )
        menuBarManager?.setupMenuBar()
        
        // 请求通知权限
        notificationManager.requestPermission()
        
        // 设置观察者
        setupObservers()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // 清理资源
        timerEngine.stop()
        audioPlayer.stopAllSounds()
    }
    
    /// 设置通知观察者
    private func setupObservers() {
        // 监听计时器阶段开始
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePhaseStarted(_:)),
            name: .timerPhaseStarted,
            object: nil
        )
        
        // 监听计时器阶段完成
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePhaseCompleted(_:)),
            name: .timerPhaseCompleted,
            object: nil
        )
    }
    
    @objc private func handlePhaseStarted(_ notification: Notification) {
        guard let phase = notification.userInfo?["phase"] as? TimerPhase else { return }
        
        // 播放开始音效
        if phase == .work {
            audioPlayer.playWindupSound()
            audioPlayer.startTickingSound()
        } else {
            audioPlayer.stopTickingSound()
        }
    }
    
    @objc private func handlePhaseCompleted(_ notification: Notification) {
        guard let phase = notification.userInfo?["phase"] as? TimerPhase else { return }
        
        // 播放结束音效
        audioPlayer.playDingSound()
        audioPlayer.stopTickingSound()
        
        // 发送通知
        switch phase {
        case .work:
            let nextPhase = timerEngine.completedCycles % timerEngine.configuration.cyclesBeforeLongBreak == 0 
                ? TimerPhase.longBreak 
                : TimerPhase.shortBreak
            notificationManager.sendBreakStartNotification(
                duration: nextPhase == .longBreak 
                    ? timerEngine.configuration.longBreakDuration 
                    : timerEngine.configuration.shortBreakDuration
            )
        case .shortBreak, .longBreak:
            notificationManager.sendBreakEndNotification()
        }
    }
}

// MARK: - Preview Helpers
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Text("ZenTomato - 菜单栏应用")
            .frame(width: 300, height: 200)
    }
}
