//
//  AudioSettings.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  音频设置结构体
//

import Foundation

/// 白噪音设置
struct WhiteNoiseSetting: Codable {
    /// 是否启用
    var isEnabled: Bool
    /// 音量 (0.0 - 1.0)
    var volume: Float

    /// 默认设置
    static var `default`: WhiteNoiseSetting {
        return WhiteNoiseSetting(isEnabled: false, volume: 0.5)
    }
}

/// 音频设置
struct AudioSettings: Codable {
    /// 开始音效音量 (0.0 - 1.0)
    var windupVolume: Float = 1.0
    /// 结束音效音量 (0.0 - 1.0)
    var dingVolume: Float = 1.0
    /// 禅韵木鱼音量 (0.0 - 1.0)
    var tickingVolume: Float = 0.5
    /// 是否静音（全局静音开关）
    var isMuted: Bool = false
    /// 是否启用开始结束音效
    var enableStartEndSounds: Bool = true
    /// 是否启用禅韵木鱼
    var enableTicking: Bool = true

    /// 白噪音设置
    var whiteNoiseSettings: [WhiteNoiseType: WhiteNoiseSetting] = [
        .zenResonance: WhiteNoiseSetting(isEnabled: true, volume: 0.5),
        .woodenFish: WhiteNoiseSetting(isEnabled: false, volume: 0.5)
    ]
    
    /// 默认设置
    static var `default`: AudioSettings {
        return AudioSettings()
    }
    
    /// 验证音量值是否有效
    func isVolumeValid(_ volume: Float) -> Bool {
        return volume >= 0.0 && volume <= 1.0
    }
    
    /// 验证所有设置是否有效
    var isValid: Bool {
        let basicValid = isVolumeValid(windupVolume) &&
                        isVolumeValid(dingVolume) &&
                        isVolumeValid(tickingVolume)

        let whiteNoiseValid = whiteNoiseSettings.values.allSatisfy { setting in
            isVolumeValid(setting.volume)
        }

        return basicValid && whiteNoiseValid
    }

    /// 获取实际音量（考虑独立开关）
    func getEffectiveVolume(for soundType: SoundType) -> Float {
        switch soundType {
        case .windup:
            return enableStartEndSounds ? windupVolume : 0.0
        case .ding:
            return enableStartEndSounds ? dingVolume : 0.0
        case .ticking:
            return enableTicking ? tickingVolume : 0.0
        }
    }

    /// 获取白噪音实际音量（考虑启用状态）
    func getEffectiveVolume(for whiteNoiseType: WhiteNoiseType) -> Float {
        guard let setting = whiteNoiseSettings[whiteNoiseType], setting.isEnabled else { return 0.0 }
        return setting.volume
    }

    /// 获取启用的白噪音类型列表
    var enabledWhiteNoiseTypes: [WhiteNoiseType] {
        return whiteNoiseSettings.compactMap { (type, setting) in
            setting.isEnabled ? type : nil
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

// MARK: - 白噪音类型
enum WhiteNoiseType: String, CaseIterable, Codable {
    case zenResonance = "zenresonance"
    case woodenFish = "woodenfish"

    var displayName: String {
        switch self {
        case .zenResonance:
            return "禅韵木鱼"
        case .woodenFish:
            return "纯净木鱼"
        }
    }

    var fileName: String {
        switch self {
        case .zenResonance:
            return "zenresonance.mp3"
        case .woodenFish:
            return "woodenfish.mp3"
        }
    }

    var icon: String {
        switch self {
        case .zenResonance:
            return "bell.fill"
        case .woodenFish:
            return "bell.circle.fill"
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