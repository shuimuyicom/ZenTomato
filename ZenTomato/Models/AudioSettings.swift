//
//  AudioSettings.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  音频设置结构体
//

import Foundation

/// 音频设置
struct AudioSettings: Codable {
    /// 开始音效音量 (0.0 - 2.0)
    var windupVolume: Float = 1.0
    /// 结束音效音量 (0.0 - 2.0)
    var dingVolume: Float = 1.0
    /// 禅韵木鱼音量 (0.0 - 2.0)
    var tickingVolume: Float = 0.5
    /// 是否静音
    var isMuted: Bool = false
    /// 是否启用禅韵木鱼
    var enableTicking: Bool = true
    
    /// 默认设置
    static var `default`: AudioSettings {
        return AudioSettings()
    }
    
    /// 验证音量值是否有效
    func isVolumeValid(_ volume: Float) -> Bool {
        return volume >= 0.0 && volume <= 2.0
    }
    
    /// 验证所有设置是否有效
    var isValid: Bool {
        return isVolumeValid(windupVolume) &&
               isVolumeValid(dingVolume) &&
               isVolumeValid(tickingVolume)
    }
    
    /// 获取实际音量（考虑静音状态）
    func getEffectiveVolume(for soundType: SoundType) -> Float {
        guard !isMuted else { return 0.0 }
        
        switch soundType {
        case .windup:
            return windupVolume
        case .ding:
            return dingVolume
        case .ticking:
            return enableTicking ? tickingVolume : 0.0
        }
    }
}

// MARK: - 音效类型
enum SoundType: String, CaseIterable {
    case windup = "windup"
    case ding = "ding"
    case ticking = "zenresonance"
    
    var displayName: String {
        switch self {
        case .windup:
            return "开始音效"
        case .ding:
            return "结束音效"
        case .ticking:
            return "禅韵木鱼"
        }
    }
    
    var fileName: String {
        switch self {
        case .windup:
            return "windup.mp3"
        case .ding:
            return "ding.mp3"
        case .ticking:
            return "zenresonance.mp3"
        }
    }
}

// MARK: - UserDefaults 存储扩展
extension AudioSettings {
    private static let userDefaultsKey = "ZenTomato.AudioSettings"
    
    /// 从 UserDefaults 加载设置
    static func load() -> AudioSettings {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let settings = try? JSONDecoder().decode(AudioSettings.self, from: data) else {
            return AudioSettings.default
        }
        return settings.isValid ? settings : AudioSettings.default
    }
    
    /// 保存设置到 UserDefaults
    func save() {
        guard isValid,
              let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: AudioSettings.userDefaultsKey)
    }
}