//
//  ZenToggleStyle.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  禅意风格的开关样式 - 与应用配色保持一致
//

import SwiftUI

/// 禅意开关样式
struct ZenToggleStyle: ToggleStyle {
    
    // MARK: - Properties
    
    /// 开启状态颜色
    private let onColor: Color = .zenGreen
    
    /// 关闭状态颜色  
    private let offColor: Color = Color.zenSecondaryText.opacity(0.3)
    
    /// 拇指颜色
    private let thumbColor: Color = .white
    
    /// 开关尺寸
    private let switchWidth: CGFloat = 51
    private let switchHeight: CGFloat = 31
    private let thumbSize: CGFloat = 27
    
    // MARK: - Body
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()
            
            // 自定义开关
            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                // 背景轨道
                RoundedRectangle(cornerRadius: switchHeight / 2)
                    .fill(configuration.isOn ? onColor : offColor)
                    .frame(width: switchWidth, height: switchHeight)
                    .overlay(
                        // 内部阴影效果
                        RoundedRectangle(cornerRadius: switchHeight / 2)
                            .stroke(
                                configuration.isOn ? 
                                onColor.opacity(0.3) : 
                                Color.zenDivider.opacity(0.5),
                                lineWidth: 0.5
                            )
                    )
                    .animation(.zenSmooth, value: configuration.isOn)
                
                // 拇指按钮
                Circle()
                    .fill(thumbColor)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(
                        color: Color.black.opacity(0.15),
                        radius: 2,
                        x: 0,
                        y: 1
                    )
                    .overlay(
                        // 拇指高光
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .padding(2)
                    .animation(.zenQuick, value: configuration.isOn)
            }
            .onTapGesture {
                // 添加触觉反馈
                NSHapticFeedbackManager.defaultPerformer.perform(
                    .levelChange,
                    performanceTime: .default
                )
                configuration.isOn.toggle()
            }
        }
    }
}

/// 紧凑型禅意开关样式 - 用于空间受限的场景
struct ZenCompactToggleStyle: ToggleStyle {
    
    // MARK: - Properties
    
    private let onColor: Color = .zenGreen
    private let offColor: Color = Color.zenSecondaryText.opacity(0.25)
    private let thumbColor: Color = .white
    
    // 紧凑尺寸
    private let switchWidth: CGFloat = 44
    private let switchHeight: CGFloat = 26
    private let thumbSize: CGFloat = 22
    
    // MARK: - Body
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: configuration.isOn ? .trailing : .leading) {
            // 背景轨道
            RoundedRectangle(cornerRadius: switchHeight / 2)
                .fill(configuration.isOn ? onColor : offColor)
                .frame(width: switchWidth, height: switchHeight)
                .animation(.zenSmooth, value: configuration.isOn)
            
            // 拇指按钮
            Circle()
                .fill(thumbColor)
                .frame(width: thumbSize, height: thumbSize)
                .shadow(
                    color: Color.black.opacity(0.12),
                    radius: 1.5,
                    x: 0,
                    y: 0.5
                )
                .padding(2)
                .animation(.zenQuick, value: configuration.isOn)
        }
        .onTapGesture {
            NSHapticFeedbackManager.defaultPerformer.perform(
                .levelChange,
                performanceTime: .default
            )
            configuration.isOn.toggle()
        }
    }
}

// MARK: - 扩展便捷方法

extension Toggle {
    /// 应用禅意开关样式
    func zenStyle() -> some View {
        self.toggleStyle(ZenToggleStyle())
    }
    
    /// 应用紧凑禅意开关样式
    func zenCompactStyle() -> some View {
        self.toggleStyle(ZenCompactToggleStyle())
    }
}
