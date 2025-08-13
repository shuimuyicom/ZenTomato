//
//  ZenProgressRing.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  禅意风格的圆形进度环组件
//

import SwiftUI

/// 禅意进度环
struct ZenProgressRing: View {
    // MARK: - Properties
    
    /// 进度值 (0.0 - 1.0)
    let progress: Double
    
    /// 环的颜色
    let ringColor: Color
    
    /// 环的大小
    var size: CGFloat = 220
    
    /// 线条宽度
    var lineWidth: CGFloat = 12
    
    /// 是否显示动画
    @State private var animatedProgress: Double = 0
    
    /// 粒子动画触发器
    @State private var particleAnimation = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 背景环
            Circle()
                .stroke(
                    Color.zenDivider.opacity(0.3),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
            
            // 进度环
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    LinearGradient(
                        colors: [
                            ringColor.opacity(0.8),
                            ringColor
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: animatedProgress)
            
            // 进度端点装饰
            if animatedProgress > 0 && animatedProgress < 1 {
                Circle()
                    .fill(ringColor)
                    .frame(width: lineWidth * 1.5, height: lineWidth * 1.5)
                    .offset(y: -size/2)
                    .rotationEffect(.degrees(360 * animatedProgress - 90))
                    .shadow(color: ringColor.opacity(0.5), radius: 4)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: animatedProgress)
                
                // 光晕效果
                Circle()
                    .fill(ringColor.opacity(0.3))
                    .frame(width: lineWidth * 2, height: lineWidth * 2)
                    .offset(y: -size/2)
                    .rotationEffect(.degrees(360 * animatedProgress - 90))
                    .blur(radius: 6)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: animatedProgress)
            }
            
            // 内部装饰环
            Circle()
                .stroke(
                    ringColor.opacity(0.1),
                    lineWidth: 1
                )
                .frame(width: size - lineWidth * 2 - 10, height: size - lineWidth * 2 - 10)
            
            // 禅意粒子效果
            if particleAnimation {
                ForEach(0..<8, id: \.self) { index in
                    ZenParticle(
                        color: ringColor,
                        delay: Double(index) * 0.1
                    )
                    .offset(y: -size/2)
                    .rotationEffect(.degrees(360 * animatedProgress - 90))
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = progress
            }
            
            // 触发粒子动画
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                particleAnimation = true
            }
        }
        .onChange(of: progress) { _, newValue in
            animatedProgress = newValue
        }
    }
}

/// 禅意粒子
struct ZenParticle: View {
    let color: Color
    let delay: Double
    
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 3, height: 3)
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(y: yOffset)
            .onAppear {
                withAnimation(
                    Animation.easeOut(duration: 1.5)
                        .delay(delay)
                        .repeatForever(autoreverses: false)
                ) {
                    opacity = 0
                    scale = 1.5
                    yOffset = -20
                }
                
                withAnimation(
                    Animation.easeIn(duration: 0.3)
                        .delay(delay)
                ) {
                    opacity = 0.8
                }
            }
    }
}

// MARK: - Preview

struct ZenProgressRing_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            ZenProgressRing(progress: 0.25, ringColor: .zenRed)
            ZenProgressRing(progress: 0.5, ringColor: .zenGreen)
            ZenProgressRing(progress: 0.75, ringColor: .zenBlue)
        }
        .padding()
        .background(Color.zenGray)
    }
}