//
//  ZenWhiteNoiseRow.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  白噪音行组件
//

import SwiftUI

/// 白噪音行组件
struct ZenWhiteNoiseRow: View {
    let whiteNoiseType: WhiteNoiseType
    @Binding var setting: WhiteNoiseSetting
    
    var body: some View {
        HStack(spacing: 12) {
            // 启用开关
            Toggle("", isOn: $setting.isEnabled)
                .zenCompactStyle()
                .labelsHidden()
            
            // 图标
            Image(systemName: whiteNoiseType.icon)
                .font(.system(size: 14))
                .foregroundColor(setting.isEnabled ? Color.zenAccent : Color.zenTextGray)
                .frame(width: 20)
            
            // 标题
            Text(whiteNoiseType.displayName)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(setting.isEnabled ? Color.zenTextGray : Color.zenSecondaryText)
            
            Spacer()
            
            // 音量控制（仅在启用时显示）
            if setting.isEnabled {
                HStack(spacing: 8) {
                    // 音量图标
                    Image(systemName: "speaker.wave.1")
                        .font(.system(size: 11))
                        .foregroundColor(Color.zenTextGray)
                    
                    // 音量滑块
                    Slider(
                        value: Binding(
                            get: { setting.volume },
                            set: { newValue in
                                setting.volume = max(0.0, min(2.0, newValue))
                            }
                        ),
                        in: 0.0...2.0
                    )
                    .zenCompactStyle()
                    .frame(width: 80)
                    
                    // 音量数值
                    Text("\(Int(setting.volume * 100))%")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.zenTextGray)
                        .frame(width: 30, alignment: .trailing)
                }
            }
        }
        .padding(.vertical, 4)
        .animation(.zenQuick, value: setting.isEnabled)
    }
}

// MARK: - Preview

struct ZenWhiteNoiseRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // 启用状态
            ZenWhiteNoiseRow(
                whiteNoiseType: .zenResonance,
                setting: .constant(WhiteNoiseSetting(isEnabled: true, volume: 0.5))
            )
            
            // 禁用状态
            ZenWhiteNoiseRow(
                whiteNoiseType: .woodenFish,
                setting: .constant(WhiteNoiseSetting(isEnabled: false, volume: 0.5))
            )
        }
        .padding()
        .background(Color.zenGray)
        .previewLayout(.sizeThatFits)
    }
}
