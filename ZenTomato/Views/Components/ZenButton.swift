//
//  ZenButton.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  禅意风格的按钮组件
//

import SwiftUI

/// 禅意按钮样式
enum ZenButtonStyle {
    case primary   // 主要按钮
    case secondary // 次要按钮
    case floating  // 浮动按钮
    case text      // 文本按钮
}

/// 禅意按钮
struct ZenButton: View {
    // MARK: - Properties
    
    /// 按钮标题
    let title: String?
    
    /// 按钮图标
    let icon: String?
    
    /// 按钮样式
    var style: ZenButtonStyle = .primary
    
    /// 按钮颜色
    var color: Color = .zenAccent
    
    /// 按钮动作
    let action: () -> Void
    
    /// 是否禁用
    var isDisabled: Bool = false
    
    /// 按钮大小
    var size: ButtonSize = .medium
    
    /// 按下状态
    @State private var isPressed = false
    
    /// 悬停状态
    @State private var isHovered = false
    
    // MARK: - Button Size
    
    enum ButtonSize {
        case small, medium, large
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 14
            case .large: return 16
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            }
        }
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            case .medium: return EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
            case .large: return EdgeInsets(top: 14, leading: 28, bottom: 14, trailing: 28)
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize))
                }
                
                if let title = title {
                    Text(title)
                        .font(.system(size: size.fontSize, weight: .medium))
                }
            }
            .padding(size.padding)
            .foregroundColor(foregroundColor)
            .background(backgroundView)
            .overlay(overlayView)
            .cornerRadius(cornerRadius)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
            .scaleEffect(isPressed ? 0.95 : (isHovered ? 1.05 : 1.0))
            .animation(.zenQuick, value: isPressed)
            .animation(.zenQuick, value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
        .onHover { hovering in
            isHovered = hovering
        }
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
    }
    
    // MARK: - Computed Properties
    
    /// 前景色
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return color
        case .floating:
            return .white
        case .text:
            return color
        }
    }
    
    /// 背景视图
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            LinearGradient(
                colors: [color, color.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            Color.zenCardBackground
        case .floating:
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        case .text:
            Color.clear
        }
    }
    
    /// 叠加视图
    @ViewBuilder
    private var overlayView: some View {
        switch style {
        case .secondary:
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(color.opacity(0.3), lineWidth: 1)
        default:
            EmptyView()
        }
    }
    
    /// 圆角半径
    private var cornerRadius: CGFloat {
        switch style {
        case .floating:
            return 50
        default:
            switch size {
            case .small: return 6
            case .medium: return 8
            case .large: return 10
            }
        }
    }
    
    /// 阴影颜色
    private var shadowColor: Color {
        switch style {
        case .primary, .floating:
            return color.opacity(0.3)
        case .secondary:
            return Color.black.opacity(0.1)
        case .text:
            return .clear
        }
    }
    
    /// 阴影半径
    private var shadowRadius: CGFloat {
        switch style {
        case .primary, .floating:
            return isPressed ? 2 : (isHovered ? 8 : 4)
        case .secondary:
            return isPressed ? 1 : (isHovered ? 4 : 2)
        case .text:
            return 0
        }
    }
    
    /// 阴影Y偏移
    private var shadowY: CGFloat {
        switch style {
        case .primary, .floating:
            return isPressed ? 1 : (isHovered ? 4 : 2)
        case .secondary:
            return isPressed ? 0 : (isHovered ? 2 : 1)
        case .text:
            return 0
        }
    }
}

/// 禅意浮动操作按钮
struct ZenFloatingButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        ZenButton(
            title: nil,
            icon: icon,
            style: .floating,
            color: color,
            action: action
        )
        .frame(width: 60, height: 60)
        .rotationEffect(.degrees(isAnimating ? 360 : 0))
        .onAppear {
            withAnimation(
                Animation.linear(duration: 20)
                    .repeatForever(autoreverses: false)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Preview

struct ZenButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // 主要按钮
            ZenButton(
                title: "开始专注",
                icon: "play.fill",
                style: .primary,
                color: .zenRed,
                action: {}
            )
            
            // 次要按钮
            ZenButton(
                title: "设置",
                icon: "gearshape",
                style: .secondary,
                color: .zenBlue,
                action: {}
            )
            
            // 文本按钮
            ZenButton(
                title: "跳过",
                icon: "forward.end",
                style: .text,
                color: .zenSecondaryText,
                action: {}
            )
            
            // 浮动按钮
            ZenFloatingButton(
                icon: "pause.fill",
                color: .zenGold,
                action: {}
            )
            
            // 不同大小
            HStack(spacing: 20) {
                ZenButton(
                    title: "小",
                    icon: nil,
                    style: .primary,
                    action: {},
                    size: .small
                )
                
                ZenButton(
                    title: "中",
                    icon: nil,
                    style: .primary,
                    action: {},
                    size: .medium
                )
                
                ZenButton(
                    title: "大",
                    icon: nil,
                    style: .primary,
                    action: {},
                    size: .large
                )
            }
        }
        .padding(40)
        .background(Color.zenGray)
    }
}