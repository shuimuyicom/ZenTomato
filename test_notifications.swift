#!/usr/bin/env swift

import Foundation
import UserNotifications

// 测试通知系统的脚本
class NotificationTester {
    
    func testNotifications() {
        print("🧪 开始测试通知系统...")
        
        // 测试短休息通知（5分钟）
        print("\n📱 测试短休息通知（5分钟）...")
        testBreakNotification(duration: 5 * 60, isLongBreak: false)
        
        // 等待一秒
        Thread.sleep(forTimeInterval: 1)
        
        // 测试长休息通知（15分钟）
        print("\n📱 测试长休息通知（15分钟）...")
        testBreakNotification(duration: 15 * 60, isLongBreak: true)
        
        // 等待一秒
        Thread.sleep(forTimeInterval: 1)
        
        // 测试自定义短休息通知（1分钟）
        print("\n📱 测试自定义短休息通知（1分钟）...")
        testBreakNotification(duration: 1 * 60, isLongBreak: false)
        
        print("\n✅ 通知测试完成！")
        print("请检查通知横幅中的文案是否正确：")
        print("- 短休息：标题「短休息时间到了！」，内容「短休息 (X分钟) - 短暂休息一下吧」")
        print("- 长休息：标题「长休息时间到了！」，内容「长休息 (X分钟) - 好好休息一下吧」")
        print("- 按钮文案：「开始短休息」/「开始长休息」和「继续工作」")
    }
    
    private func testBreakNotification(duration: TimeInterval, isLongBreak: Bool) {
        let content = UNMutableNotificationContent()

        // 计算分钟数
        let minutes = Int(duration / 60)

        // 使用优化后的文案逻辑
        if isLongBreak {
            content.title = "长休息时间到了！"
            content.body = "长休息 (\(minutes)分钟) - 好好休息一下吧"
        } else {
            content.title = "短休息时间到了！"
            content.body = "短休息 (\(minutes)分钟) - 短暂休息一下吧"
        }

        content.sound = .default
        content.userInfo = ["type": "breakStart", "duration": duration, "isLongBreak": isLongBreak]

        let breakType = isLongBreak ? "长休息" : "短休息"

        print("  - 休息类型: \(breakType)")
        print("  - 时长: \(minutes) 分钟")
        print("  - 通知标题: \(content.title)")
        print("  - 通知文案: \(content.body)")
        
        // 创建立即触发的通知
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        // 发送通知
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("  ❌ 发送通知失败: \(error)")
            } else {
                print("  ✅ 通知已发送")
            }
        }
    }
}

// 请求通知权限并运行测试
UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
    if granted {
        print("✅ 通知权限已获取")
        let tester = NotificationTester()
        tester.testNotifications()
    } else {
        print("❌ 通知权限被拒绝")
        if let error = error {
            print("错误: \(error)")
        }
    }
}

// 保持脚本运行一段时间以便观察通知
RunLoop.main.run(until: Date().addingTimeInterval(5))
