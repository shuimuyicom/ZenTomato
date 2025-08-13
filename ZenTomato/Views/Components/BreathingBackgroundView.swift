//
//  BreathingBackgroundView.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  呼吸动画背景组件 - 营造禅意氛围
//

import SwiftUI

/// 呼吸动画背景视图
struct BreathingBackgroundView: View {
    // MARK: - Properties
    
    /// 当前阶段颜色
    let phaseColor: Color
    
    /// 是否启用动画
    @State private var isBreathing = false
    
    /// 圆圈缩放值
    @State private var circleScale: CGFloat = 1.0
    
    /// 光晕不透明度
    @State private var glowOpacity: Double = 0.3
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [
                    Color.zenGray,
                    Color.zenGray.opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // 禅意圆圈层
            ZStack {
                // 外层光晕
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                phaseColor.opacity(0.1),
                                phaseColor.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 50,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .scaleEffect(circleScale * 1.2)
                    .opacity(glowOpacity)
                    .blur(radius: 20)
                
                // 中层圆圈
                Circle()
                    .stroke(phaseColor.opacity(0.15), lineWidth: 1)
                    .frame(width: 250, height: 250)
                    .scaleEffect(circleScale)
                    .opacity(isBreathing ? 0.8 : 0.4)
                
                // 内层圆圈
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                phaseColor.opacity(0.08),
                                phaseColor.opacity(0.03),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 180, height: 180)
                    .scaleEffect(circleScale * 1.1)
                
                // 中心点
                Circle()
                    .fill(phaseColor.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(isBreathing ? 1.5 : 1.0)
                    .blur(radius: isBreathing ? 2 : 0)
            }
            
            // 禅意纹理叠加
            ZenTextureOverlay()
                .opacity(0.03)
        }
        .onAppear {
            startBreathing()
        }
    }
    
    // MARK: - Methods
    
    /// 开始呼吸动画
    private func startBreathing() {
        withAnimation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            isBreathing = true
            circleScale = 1.2
            glowOpacity = 0.6
        }
    }
}

/// 禅意纹理叠加
struct ZenTextureOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                // 绘制细微的点状纹理
                for _ in 0..<500 {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    let opacity = Double.random(in: 0.1...0.3)
                    
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: 1, height: 1)),
                        with: .color(.black.opacity(opacity))
                    )
                }
            }
        }
    }
}

// MARK: - Preview

struct BreathingBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BreathingBackgroundView(phaseColor: .zenRed)
            .frame(width: 380, height: 680)
    }
}