//
//  NotificationManager.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  通知管理器 - 处理系统通知的发送和权限管理
//

import Foundation
import UserNotifications
import SwiftUI

/// 通知管理器
class NotificationManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    /// 是否已授权通知权限
    @Published var isAuthorized: Bool = false
    
    /// 权限状态
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    // MARK: - Private Properties
    
    /// 通知中心
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Constants
    
    /// 通知标识符
    private enum NotificationIdentifier {
        static let breakStart = "zen.tomato.break.start"
        static let breakEnd = "zen.tomato.break.end"
        static let workStart = "zen.tomato.work.start"
    }
    
    /// 通知动作标识符
    private enum NotificationAction {
        static let skip = "zen.tomato.action.skip"
        static let startNow = "zen.tomato.action.start"
    }
    
    /// 通知类别标识符
    private enum NotificationCategory {
        static let timerAlert = "zen.tomato.category.timer"
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        checkAuthorizationStatus()
        setupNotificationCategories()
    }
    
    // MARK: - Public Methods
    
    /// 请求通知权限
    func requestPermission() {
        // 请求通知权限，系统会根据用户设置决定显示样式（横幅或警告）
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                self?.checkAuthorizationStatus()

                if let error = error {
                    print("通知权限请求失败: \(error)")
                }
            }
        }
    }
    
    /// 发送休息开始通知
    func sendBreakStartNotification(duration: TimeInterval, isLongBreak: Bool = false) {
        let content = UNMutableNotificationContent()

        // 计算分钟数
        let minutes = Int(duration / 60)

        // 根据休息类型显示相应文案，包含具体时间
        if isLongBreak {
            content.title = "长休息时间到了！"
            content.body = "长休息 (\(minutes)分钟) - 好好休息一下吧"
        } else {
            content.title = "短休息时间到了！"
            content.body = "短休息 (\(minutes)分钟) - 短暂休息一下吧"
        }

        content.sound = .default
        // 根据休息类型设置不同的通知类别，以显示相应的按钮文案
        content.categoryIdentifier = isLongBreak
            ? "\(NotificationCategory.timerAlert).long"
            : "\(NotificationCategory.timerAlert).short"
        content.userInfo = ["type": "breakStart", "duration": duration, "isLongBreak": isLongBreak]

        // 添加动作按钮
        content.interruptionLevel = .timeSensitive

        sendNotification(content: content, identifier: NotificationIdentifier.breakStart)
    }
    
    /// 发送休息结束通知
    func sendBreakEndNotification() {
        let content = UNMutableNotificationContent()
        content.title = "休息结束！"
        content.body = "休息结束，准备开始新的专注时光！"
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.timerAlert
        content.userInfo = ["type": "breakEnd"]

        // 添加动作按钮
        content.interruptionLevel = .timeSensitive

        sendNotification(content: content, identifier: NotificationIdentifier.breakEnd)
    }
    
    /// 发送工作开始通知
    func sendWorkStartNotification() {
        let content = UNMutableNotificationContent()
        content.title = "开始工作！"
        content.body = "保持专注，全力以赴"
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.timerAlert
        content.userInfo = ["type": "workStart"]
        
        sendNotification(content: content, identifier: NotificationIdentifier.workStart)
    }
    
    /// 移除所有待发送的通知
    func removeAllPendingNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    /// 移除所有已发送的通知
    func removeAllDeliveredNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    /// 打开系统设置
    func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
    }
    
    // MARK: - Private Methods
    
    /// 检查授权状态
    private func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    /// 设置通知类别和动作
    private func setupNotificationCategories() {
        // 创建通用休息开始通知的动作
        let skipBreakAction = UNNotificationAction(
            identifier: NotificationAction.skip,
            title: "继续工作",
            options: []
        )

        let startBreakAction = UNNotificationAction(
            identifier: NotificationAction.startNow,
            title: "开始休息",
            options: [.foreground]
        )

        // 创建短休息专用动作
        let startShortBreakAction = UNNotificationAction(
            identifier: NotificationAction.startNow,
            title: "开始短休息",
            options: [.foreground]
        )

        // 创建长休息专用动作
        let startLongBreakAction = UNNotificationAction(
            identifier: NotificationAction.startNow,
            title: "开始长休息",
            options: [.foreground]
        )

        // 创建短休息类别
        let shortBreakCategory = UNNotificationCategory(
            identifier: "\(NotificationCategory.timerAlert).short",
            actions: [startShortBreakAction, skipBreakAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        // 创建长休息类别
        let longBreakCategory = UNNotificationCategory(
            identifier: "\(NotificationCategory.timerAlert).long",
            actions: [startLongBreakAction, skipBreakAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        // 创建通用休息类别（兼容性保留）
        let generalBreakCategory = UNNotificationCategory(
            identifier: NotificationCategory.timerAlert,
            actions: [startBreakAction, skipBreakAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        // 注册所有类别
        notificationCenter.setNotificationCategories([
            shortBreakCategory,
            longBreakCategory,
            generalBreakCategory
        ])
    }
    
    /// 发送通知
    private func sendNotification(content: UNMutableNotificationContent, identifier: String) {
        guard isAuthorized else {
            print("通知未授权，无法发送通知")
            return
        }
        
        // 创建触发器（立即发送）
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        // 创建请求
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        // 添加通知请求
        notificationCenter.add(request) { error in
            if let error = error {
                print("发送通知失败: \(error)")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    /// 处理前台通知展示
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // 即使应用在前台也显示通知
        completionHandler([.banner, .sound, .badge])
    }
    
    /// 处理通知响应
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        switch response.actionIdentifier {
        case NotificationAction.skip:
            // 发送跳过休息的通知
            NotificationCenter.default.post(
                name: .skipBreakRequested,
                object: nil,
                userInfo: userInfo
            )
            
        case NotificationAction.startNow:
            // 发送立即开始的通知
            NotificationCenter.default.post(
                name: .startWorkRequested,
                object: nil,
                userInfo: userInfo
            )
            
        case UNNotificationDefaultActionIdentifier:
            // 用户点击了通知本身
            NotificationCenter.default.post(
                name: .notificationTapped,
                object: nil,
                userInfo: userInfo
            )
            
        default:
            break
        }
        
        completionHandler()
    }
}

// MARK: - Notification Names Extension

extension Notification.Name {
    static let skipBreakRequested = Notification.Name("ZenTomato.skipBreakRequested")
    static let startWorkRequested = Notification.Name("ZenTomato.startWorkRequested")
    static let notificationTapped = Notification.Name("ZenTomato.notificationTapped")
}

// MARK: - Preview Helper

extension NotificationManager {
    /// 创建预览用的通知管理器
    static var preview: NotificationManager {
        return NotificationManager()
    }
}

// MARK: - 权限状态显示扩展

extension UNAuthorizationStatus {
    var displayName: String {
        switch self {
        case .notDetermined:
            return "未决定"
        case .denied:
            return "已拒绝"
        case .authorized:
            return "已授权"
        case .provisional:
            return "临时授权"
        case .ephemeral:
            return "临时授权"
        @unknown default:
            return "未知"
        }
    }
    
    var icon: String {
        switch self {
        case .notDetermined:
            return "questionmark.circle"
        case .denied:
            return "xmark.circle"
        case .authorized:
            return "checkmark.circle"
        case .provisional, .ephemeral:
            return "clock.circle"
        @unknown default:
            return "exclamationmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .notDetermined:
            return .gray
        case .denied:
            return .red
        case .authorized:
            return .green
        case .provisional, .ephemeral:
            return .orange
        @unknown default:
            return .gray
        }
    }
}