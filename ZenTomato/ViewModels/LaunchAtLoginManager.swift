//
//  LaunchAtLoginManager.swift
//  ZenTomato
//
//  Created by Ban on 2025/9/2.
//  开机启动管理器 - 使用 ServiceManagement 框架管理开机自启动
//

import Foundation
import ServiceManagement
import Combine

/// 开机启动管理器
class LaunchAtLoginManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 系统设置
    @Published var settings: SystemSettings {
        didSet {
            settings.save()
            // 当设置改变时，同步更新系统的开机启动状态
            updateLaunchAtLoginStatus()
        }
    }
    
    /// 开机启动状态（实时从系统读取）
    @Published var isLaunchAtLoginEnabled: Bool = false
    
    // MARK: - Private Properties
    
    /// 应用的 Bundle Identifier
    private let bundleIdentifier = "com.shuimuyi.ZenTomato"
    
    // MARK: - Initialization
    
    init() {
        self.settings = SystemSettings.load()
        // 初始化时检查系统实际状态
        checkCurrentLaunchAtLoginStatus()
        // 对于 macOS 13.0+，如果设置和系统状态不一致，以设置为准
        // 对于 macOS 12.4-12.x，状态检查已使用存储的设置，无需额外同步
        if #available(macOS 13.0, *) {
            if settings.launchAtLogin != isLaunchAtLoginEnabled {
                updateLaunchAtLoginStatus()
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// 切换开机启动状态
    func toggleLaunchAtLogin() {
        settings.launchAtLogin.toggle()
    }
    
    /// 设置开机启动状态
    /// - Parameter enabled: 是否启用开机启动
    /// - Returns: 操作是否成功
    @discardableResult
    func setLaunchAtLogin(_ enabled: Bool) -> Bool {
        let success = updateSystemLaunchAtLoginStatus(enabled)
        if success {
            settings.launchAtLogin = enabled
            // 对于 macOS 13.0+，从系统重新读取状态
            // 对于 macOS 12.4-12.x，状态已同步到存储设置
            checkCurrentLaunchAtLoginStatus()
        }
        return success
    }
    
    /// 检查当前开机启动状态
    func checkCurrentLaunchAtLoginStatus() {
        isLaunchAtLoginEnabled = isCurrentlyEnabledInSystem()
    }
    
    // MARK: - Private Methods
    
    /// 更新开机启动状态（根据当前设置）
    private func updateLaunchAtLoginStatus() {
        let success = updateSystemLaunchAtLoginStatus(settings.launchAtLogin)
        if success {
            checkCurrentLaunchAtLoginStatus()
        } else {
            // 如果系统更新失败，回滚设置
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let currentSystemStatus = self.isCurrentlyEnabledInSystem()
                if self.settings.launchAtLogin != currentSystemStatus {
                    self.settings.launchAtLogin = currentSystemStatus
                }
            }
        }
    }
    
    /// 更新系统的开机启动状态
    /// - Parameter enabled: 是否启用
    /// - Returns: 操作是否成功
    private func updateSystemLaunchAtLoginStatus(_ enabled: Bool) -> Bool {
        // 使用现代的 SMAppService API (macOS 13.0+)
        if #available(macOS 13.0, *) {
            do {
                let service = SMAppService.mainApp
                if enabled {
                    try service.register()
                    print("✅ 开机启动设置成功: 已启用")
                } else {
                    try service.unregister()
                    print("✅ 开机启动设置成功: 已禁用")
                }
                return true
            } catch {
                print("⚠️ 开机启动设置失败: \(error.localizedDescription)")
                return false
            }
        } else {
            // 回退到旧的 API (macOS 13.0 以下)
            let success = SMLoginItemSetEnabled(bundleIdentifier as CFString, enabled)

            if !success {
                print("⚠️ 开机启动设置失败: \(enabled ? "启用" : "禁用")")
            } else {
                print("✅ 开机启动设置成功: \(enabled ? "已启用" : "已禁用")")
            }

            return success
        }
    }
    
    /// 检查应用是否在系统中被设置为开机启动
    /// - Returns: 是否已启用开机启动
    private func isCurrentlyEnabledInSystem() -> Bool {
        // 使用现代的 SMAppService API (macOS 13.0+)
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            return service.status == .enabled
        } else {
            // 对于 macOS 12.4-12.x：由于 SMCopyAllJobDictionaries 已废弃且没有可靠的替代方案，
            // 我们使用存储的设置状态作为状态源，这样避免了使用废弃的 API
            // 这种方法在大多数情况下是可靠的，因为设置状态会在每次更改时同步到系统
            return settings.launchAtLogin
        }
    }
}

// MARK: - Error Handling
extension LaunchAtLoginManager {
    
    /// 开机启动相关错误
    enum LaunchAtLoginError: LocalizedError {
        case permissionDenied
        case systemError
        case bundleNotFound
        
        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "没有权限修改开机启动设置"
            case .systemError:
                return "系统错误，无法修改开机启动设置"
            case .bundleNotFound:
                return "找不到应用程序包"
            }
        }
    }
}
