//
//  Color+Zen.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  禅意配色系统扩展
//

import SwiftUI

extension Color {
    // MARK: - 禅意主题色
    
    /// 工作状态红色
    static let zenRed = Color(hex: "#CC3333")
    
    /// 休息状态绿色
    static let zenGreen = Color(hex: "#66B366")
    
    /// 专注状态蓝色
    static let zenBlue = Color(hex: "#6699CC")
    
    /// 完成状态金色
    static let zenGold = Color(hex: "#E6B34D")
    
    /// 背景灰色
    static let zenGray = Color(hex: "#F2F2F2")
    
    /// 深灰文字色
    static let zenTextGray = Color(hex: "#4D4D4D")
    
    /// 次要文字色
    static let zenSecondaryText = Color(hex: "#8E8E93")
    
    /// 卡片背景色
    static let zenCardBackground = Color(hex: "#FFFFFF")
    
    /// 分隔线颜色
    static let zenDivider = Color(hex: "#E5E5EA")
    
    // MARK: - 语义化颜色
    
    /// 主要强调色
    static var zenAccent: Color {
        return zenRed
    }
    
    /// 成功色
    static var zenSuccess: Color {
        return zenGreen
    }
    
    /// 警告色
    static var zenWarning: Color {
        return zenGold
    }
    
    /// 信息色
    static var zenInfo: Color {
        return zenBlue
    }
    
    // MARK: - 初始化扩展
    
    /// 从十六进制字符串创建颜色
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - 渐变色扩展
extension LinearGradient {
    /// 工作状态渐变
    static var zenWorkGradient: LinearGradient {
        LinearGradient(
            colors: [Color.zenRed.opacity(0.8), Color.zenRed],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// 休息状态渐变
    static var zenRestGradient: LinearGradient {
        LinearGradient(
            colors: [Color.zenGreen.opacity(0.8), Color.zenGreen],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// 背景渐变
    static var zenBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color.zenGray, Color.zenGray.opacity(0.95)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}