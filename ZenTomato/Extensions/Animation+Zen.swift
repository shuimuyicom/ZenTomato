//
//  Animation+Zen.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  禅意动画系统扩展
//

import SwiftUI

extension Animation {
    // MARK: - 预定义动画时长
    
    /// 快速动画 (0.2秒)
    static let zenQuick = Animation.easeInOut(duration: 0.2)
    
    /// 平滑动画 (0.3秒)
    static let zenSmooth = Animation.easeInOut(duration: 0.3)
    
    /// 标准动画 (0.5秒)
    static let zenStandard = Animation.easeInOut(duration: 0.5)
    
    /// 缓慢动画 (0.8秒)
    static let zenSlow = Animation.easeInOut(duration: 0.8)
    
    /// 呼吸动画 (2秒循环)
    static let zenBreathing = Animation.easeInOut(duration: 2.0)
        .repeatForever(autoreverses: true)
    
    /// 脉冲动画 (1秒循环)
    static let zenPulse = Animation.easeInOut(duration: 1.0)
        .repeatForever(autoreverses: true)
    
    // MARK: - 弹性动画
    
    /// 弹性进入动画
    static let zenBounceIn = Animation.spring(
        response: 0.3,
        dampingFraction: 0.6,
        blendDuration: 0
    )
    
    /// 弹性退出动画
    static let zenBounceOut = Animation.spring(
        response: 0.4,
        dampingFraction: 0.75,
        blendDuration: 0
    )
    
    /// 轻弹动画
    static let zenSnap = Animation.spring(
        response: 0.25,
        dampingFraction: 0.5,
        blendDuration: 0
    )
    
    // MARK: - 自定义时序函数
    
    /// 渐入动画
    static let zenEaseIn = Animation.timingCurve(0.42, 0, 1, 1, duration: 0.3)
    
    /// 渐出动画
    static let zenEaseOut = Animation.timingCurve(0, 0, 0.58, 1, duration: 0.3)
    
    /// 快速开始，缓慢结束
    static let zenQuickStart = Animation.timingCurve(0.11, 0, 0.5, 0, duration: 0.4)
    
    /// 缓慢开始，快速结束
    static let zenSlowStart = Animation.timingCurve(0.5, 1, 0.89, 1, duration: 0.4)
}

// MARK: - View 动画扩展
extension View {
    /// 添加缩放悬停效果
    func zenHoverEffect(isHovered: Bool) -> some View {
        self.scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.zenQuick, value: isHovered)
    }
    
    /// 添加点击缩放效果
    func zenTapEffect(isPressed: Bool) -> some View {
        self.scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.zenQuick, value: isPressed)
    }
    
    /// 添加呼吸动画效果
    @ViewBuilder
    func zenBreathingEffect(isAnimating: Bool) -> some View {
        if isAnimating {
            self.scaleEffect(1.0)
                .onAppear {
                    withAnimation(.zenBreathing) {
                        // 触发动画
                    }
                }
        } else {
            self
        }
    }
    
    /// 添加淡入效果
    func zenFadeIn(isVisible: Bool, delay: Double = 0) -> some View {
        self.opacity(isVisible ? 1 : 0)
            .animation(.zenSmooth.delay(delay), value: isVisible)
    }
    
    /// 添加滑入效果
    func zenSlideIn(isVisible: Bool, edge: Edge = .bottom) -> some View {
        let offset: CGFloat = 20
        let x: CGFloat = edge == .leading ? -offset : (edge == .trailing ? offset : 0)
        let y: CGFloat = edge == .top ? -offset : (edge == .bottom ? offset : 0)
        
        return self
            .offset(x: isVisible ? 0 : x, y: isVisible ? 0 : y)
            .opacity(isVisible ? 1 : 0)
            .animation(.zenBounceIn, value: isVisible)
    }
    
    /// 添加旋转加载效果
    func zenRotationEffect(isRotating: Bool) -> some View {
        self.rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(
                isRotating ?
                Animation.linear(duration: 1).repeatForever(autoreverses: false) :
                Animation.linear(duration: 0),
                value: isRotating
            )
    }
}

// MARK: - 过渡效果扩展
extension AnyTransition {
    /// 禅意缩放过渡
    static var zenScale: AnyTransition {
        AnyTransition.scale
            .combined(with: .opacity)
            .animation(.zenBounceIn)
    }
    
    /// 禅意滑动过渡
    static var zenSlide: AnyTransition {
        AnyTransition.move(edge: .bottom)
            .combined(with: .opacity)
            .animation(.zenSmooth)
    }
    
    /// 禅意淡入淡出过渡
    static var zenFade: AnyTransition {
        AnyTransition.opacity
            .animation(.zenSmooth)
    }
    
    /// 禅意翻转过渡
    static var zenFlip: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        )
        .animation(.zenBounceIn)
    }
}