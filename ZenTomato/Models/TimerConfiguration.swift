//
//  TimerConfiguration.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  计时器配置结构体
//

import Foundation

/// 计时器配置
struct TimerConfiguration: Codable {
    /// 工作时长（秒）
    var workDuration: TimeInterval = 25 * 60
    /// 短休息时长（秒）
    var shortBreakDuration: TimeInterval = 5 * 60
    /// 长休息时长（秒）
    var longBreakDuration: TimeInterval = 15 * 60
    /// 长休息前的工作周期数
    var cyclesBeforeLongBreak: Int = 4
    /// 自动开始休息
    var autoStartBreaks: Bool = false
    /// 自动开始工作
    var autoStartWork: Bool = false
    /// 在菜单栏显示时间
    var showTimeInMenuBar: Bool = true
    
    /// 默认配置
    static var `default`: TimerConfiguration {
        return TimerConfiguration()
    }
    
    /// 验证配置是否有效
    var isValid: Bool {
        return workDuration >= 60 && workDuration <= 3600 &&
               shortBreakDuration >= 60 && shortBreakDuration <= 3600 &&
               longBreakDuration >= 60 && longBreakDuration <= 3600 &&
               cyclesBeforeLongBreak >= 1 && cyclesBeforeLongBreak <= 10
    }
    
    /// 格式化时间显示（分钟）
    static func formatMinutes(from seconds: TimeInterval) -> Int {
        return Int(seconds / 60)
    }
    
    /// 将分钟转换为秒
    static func secondsFromMinutes(_ minutes: Int) -> TimeInterval {
        return TimeInterval(minutes * 60)
    }
}

// MARK: - UserDefaults 存储扩展
extension TimerConfiguration {
    private static let userDefaultsKey = "ZenTomato.TimerConfiguration"
    
    /// 从 UserDefaults 加载配置
    static func load() -> TimerConfiguration {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let configuration = try? JSONDecoder().decode(TimerConfiguration.self, from: data) else {
            return TimerConfiguration.default
        }
        return configuration.isValid ? configuration : TimerConfiguration.default
    }
    
    /// 保存配置到 UserDefaults
    func save() {
        guard isValid,
              let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: TimerConfiguration.userDefaultsKey)
    }
}