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

        // 监听通知响应 - 跳过休息请求
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSkipBreakRequested(_:)),
            name: .skipBreakRequested,
            object: nil
        )

        // 监听通知响应 - 立即开始请求
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStartWorkRequested(_:)),
            name: .startWorkRequested,
            object: nil
        )

        // 监听通知响应 - 延长休息请求
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleExtendBreakRequested(_:)),
            name: .extendBreakRequested,
            object: nil
        )

        // 监听通知响应 - 通知被点击
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotificationTapped(_:)),
            name: .notificationTapped,
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
            // 注意：此时 completedCycles 还未增加，所以需要用 (completedCycles + 1) 来判断
            let nextCycleCount = timerEngine.completedCycles + 1
            let isLongBreak = nextCycleCount > 0 &&
                             nextCycleCount % timerEngine.configuration.cyclesBeforeLongBreak == 0
            notificationManager.sendBreakStartNotification(
                duration: isLongBreak
                    ? timerEngine.configuration.longBreakDuration
                    : timerEngine.configuration.shortBreakDuration,
                isLongBreak: isLongBreak
            )
        case .shortBreak, .longBreak:
            notificationManager.sendBreakEndNotification()
        }
    }

    /// 处理跳过休息请求
    @objc private func handleSkipBreakRequested(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let notificationType = userInfo["type"] as? String else { return }

        switch notificationType {
        case "breakStart":
            // 用户选择跳过休息，直接开始下一个工作周期
            timerEngine.currentPhase = .work
            timerEngine.start()

        case "breakEnd":
            // 用户选择延长休息，暂时不做任何操作
            // 可以在这里添加延长休息的逻辑
            break

        default:
            break
        }
    }

    /// 处理立即开始请求
    @objc private func handleStartWorkRequested(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let notificationType = userInfo["type"] as? String else { return }

        switch notificationType {
        case "breakStart":
            // 用户选择立即开始休息
            timerEngine.start()

        case "breakEnd":
            // 用户选择立即开始工作
            timerEngine.currentPhase = .work
            timerEngine.start()

        default:
            break
        }
    }

    /// 处理延长休息请求
    @objc private func handleExtendBreakRequested(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let notificationType = userInfo["type"] as? String else { return }

        switch notificationType {
        case "breakEnd":
            // 用户选择延长休息，可以添加延长休息的逻辑
            // 目前暂时不做任何操作，保持当前休息状态
            print("用户选择延长休息")
            break

        default:
            break
        }
    }

    /// 处理通知被点击
    @objc private func handleNotificationTapped(_ notification: Notification) {
        // 用户点击了通知本身，显示应用界面
        DispatchQueue.main.async { [weak self] in
            self?.menuBarManager?.showPopover()
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
