//
//  SystemSettings.swift
//  ZenTomato
//
//  Created by Ban on 2025/9/2.
//  系统设置结构体 - 管理开机启动等系统级配置
//

import Foundation

/// 系统设置
struct SystemSettings: Codable {
    /// 开机自启动
    var launchAtLogin: Bool = false
    
    /// 默认设置
    static var `default`: SystemSettings {
        return SystemSettings()
    }
    
    /// 验证设置是否有效
    var isValid: Bool {
        return true // 目前所有布尔值都是有效的
    }
}

// MARK: - UserDefaults 存储扩展
extension SystemSettings {
    private static let userDefaultsKey = "ZenTomato.SystemSettings"
    
    /// 从 UserDefaults 加载设置
    static func load() -> SystemSettings {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let settings = try? JSONDecoder().decode(SystemSettings.self, from: data) else {
            return SystemSettings.default
        }
        return settings.isValid ? settings : SystemSettings.default
    }
    
    /// 保存设置到 UserDefaults
    func save() {
        guard isValid,
              let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: SystemSettings.userDefaultsKey)
    }
}
