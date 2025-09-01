//
//  ZenSliderStyle.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  禅意风格的滑块样式扩展 - 与应用配色保持一致
//

import SwiftUI

// MARK: - Slider 扩展

extension Slider {
    /// 应用禅意滑块样式
    func zenStyle() -> some View {
        self
            .tint(.zenGreen)
            .controlSize(.small)
    }

    /// 应用紧凑禅意滑块样式
    func zenCompactStyle() -> some View {
        self
            .tint(.zenGreen)
            .controlSize(.mini)
    }
}
