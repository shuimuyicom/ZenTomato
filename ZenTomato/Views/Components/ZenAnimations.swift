//
//  ZenAnimations.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  禅意动画组件集合 - 增强交互体验
//

import SwiftUI

// MARK: - 禅意涟漪效果
struct ZenRippleEffect: View {
    let color: Color
    let maxRadius: CGFloat
    
    @State private var animationAmount: CGFloat = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Circle()
            .stroke(color, lineWidth: 2)
            .frame(width: maxRadius * 2 * animationAmount, height: maxRadius * 2 * animationAmount)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    Animation.easeOut(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    animationAmount = 1
                    opacity = 0
                }
            }
    }
}

// MARK: - 禅意脉冲效果
struct ZenPulseEffect: View {
    let color: Color
    let size: CGFloat
    
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: size, height: size)
                .scaleEffect(isPulsing ? 1.3 : 1.0)
                .opacity(isPulsing ? 0 : 1)
            
            Circle()
                .fill(color)
                .frame(width: size * 0.6, height: size * 0.6)
                .scaleEffect(isPulsing ? 1.1 : 1.0)
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: false)
            ) {
                isPulsing = true
            }
        }
    }
}

// MARK: - 禅意流动文字
struct ZenFlowingText: View {
    let text: String
    let font: Font
    let color: Color
    
    @State private var animateOffset: CGFloat = 0
    @State private var animateOpacity: Double = 0
    
    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(color)
            .offset(y: animateOffset)
            .opacity(animateOpacity)
            .onAppear {
                withAnimation(
                    Animation.easeOut(duration: 0.8)
                        .delay(0.2)
                ) {
                    animateOffset = 0
                    animateOpacity = 1
                }
            }
            .onDisappear {
                animateOffset = 20
                animateOpacity = 0
            }
    }
}

// MARK: - 禅意浮动气泡
struct ZenFloatingBubble: View {
    let color: Color
    let size: CGFloat
    let floatDistance: CGFloat
    let duration: Double
    
    @State private var isFloating = false
    @State private var opacity: Double = 0.6
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(0.3),
                        color.opacity(0.1),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: size * 0.1,
                    endRadius: size * 0.5
                )
            )
            .frame(width: size, height: size)
            .offset(y: isFloating ? -floatDistance : floatDistance)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                ) {
                    isFloating = true
                }
                
                withAnimation(
                    Animation.easeInOut(duration: duration * 0.5)
                        .repeatForever(autoreverses: true)
                ) {
                    opacity = 0.3
                }
            }
    }
}

// MARK: - 禅意光环
struct ZenGlowEffect: View {
    let color: Color
    let radius: CGFloat
    
    @State private var isGlowing = false
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: radius * 2, height: radius * 2)
            .blur(radius: isGlowing ? radius * 0.3 : radius * 0.1)
            .opacity(isGlowing ? 0.6 : 0.3)
            .scaleEffect(isGlowing ? 1.2 : 1.0)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever(autoreverses: true)
                ) {
                    isGlowing = true
                }
            }
    }
}

// MARK: - 禅意进度指示器
struct ZenLoadingIndicator: View {
    let color: Color
    let size: CGFloat
    
    @State private var rotation: Double = 0
    @State private var trimEnd: CGFloat = 0.1
    
    var body: some View {
        ZStack {
            // 背景圆环
            Circle()
                .stroke(color.opacity(0.1), lineWidth: size * 0.1)
                .frame(width: size, height: size)
            
            // 动画圆环
            Circle()
                .trim(from: 0, to: trimEnd)
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.3), color],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(
                        lineWidth: size * 0.1,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(rotation))
        }
        .onAppear {
            withAnimation(
                Animation.linear(duration: 1)
                    .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
            
            withAnimation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
            ) {
                trimEnd = 0.8
            }
        }
    }
}

// MARK: - 禅意数字过渡
struct ZenNumberTransition: View {
    let number: Int
    let font: Font
    let color: Color
    
    @State private var animatedNumber: Int = 0
    
    var body: some View {
        Text("\(animatedNumber)")
            .font(font)
            .foregroundColor(color)
            .onAppear {
                animateNumber()
            }
            .onChange(of: number) { _, _ in
                animateNumber()
            }
    }
    
    private func animateNumber() {
        let duration = 0.5
        let steps = 20
        let stepDuration = duration / Double(steps)
        let difference = number - animatedNumber
        let increment = difference / steps
        
        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                if i == steps - 1 {
                    animatedNumber = number
                } else {
                    animatedNumber += increment
                }
            }
        }
    }
}

// MARK: - 禅意路径动画
struct ZenPathAnimation: View {
    let points: [CGPoint]
    let color: Color
    let lineWidth: CGFloat
    
    @State private var trimEnd: CGFloat = 0
    
    var body: some View {
        Path { path in
            guard !points.isEmpty else { return }
            path.move(to: points[0])
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
        }
        .trim(from: 0, to: trimEnd)
        .stroke(
            LinearGradient(
                colors: [color.opacity(0.3), color],
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(
                lineWidth: lineWidth,
                lineCap: .round,
                lineJoin: .round
            )
        )
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 1.5)
                    .delay(0.2)
            ) {
                trimEnd = 1
            }
        }
    }
}

// MARK: - 禅意粒子系统
struct ZenParticleSystem: View {
    let particleCount: Int
    let color: Color
    let size: CGSize
    
    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { index in
                ZenParticleView(
                    color: color,
                    maxSize: 4,
                    delay: Double(index) * 0.1
                )
                .position(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                )
            }
        }
        .frame(width: size.width, height: size.height)
    }
}

struct ZenParticleView: View {
    let color: Color
    let maxSize: CGFloat
    let delay: Double
    
    @State private var size: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .opacity(opacity)
            .offset(y: yOffset)
            .onAppear {
                withAnimation(
                    Animation.easeOut(duration: 2)
                        .delay(delay)
                        .repeatForever(autoreverses: false)
                ) {
                    size = maxSize
                    opacity = 0
                    yOffset = -30
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

// MARK: - 禅意水波纹
struct ZenWaterRipple: View {
    let color: Color
    let rippleCount: Int = 3
    
    @State private var animationAmounts: [CGFloat] = Array(repeating: 1, count: 3)
    @State private var opacities: [Double] = Array(repeating: 1, count: 3)
    
    var body: some View {
        ZStack {
            ForEach(0..<rippleCount, id: \.self) { index in
                Circle()
                    .stroke(color, lineWidth: 2)
                    .scaleEffect(animationAmounts[index])
                    .opacity(opacities[index])
                    .onAppear {
                        let delay = Double(index) * 0.4
                        
                        withAnimation(
                            Animation.easeOut(duration: 2)
                                .delay(delay)
                                .repeatForever(autoreverses: false)
                        ) {
                            animationAmounts[index] = 3
                            opacities[index] = 0
                        }
                    }
            }
        }
    }
}

// MARK: - 禅意渐变背景
struct ZenGradientBackground: View {
    let colors: [Color]
    
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
            ) {
                animateGradient = true
            }
        }
    }
}

// MARK: - 禅意呼吸圆圈
struct ZenBreathingCircle: View {
    let color: Color
    let minSize: CGFloat
    let maxSize: CGFloat
    
    @State private var isBreathing = false
    @State private var opacity: Double = 0.3
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(opacity),
                        color.opacity(opacity * 0.5),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: minSize * 0.2,
                    endRadius: maxSize * 0.5
                )
            )
            .frame(
                width: isBreathing ? maxSize : minSize,
                height: isBreathing ? maxSize : minSize
            )
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever(autoreverses: true)
                ) {
                    isBreathing = true
                    opacity = 0.6
                }
            }
    }
}

// MARK: - Preview
struct ZenAnimations_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            // 涟漪效果
            ZStack {
                ZenRippleEffect(color: .zenRed, maxRadius: 50)
                Text("涟漪")
                    .font(.system(size: 12))
            }
            .frame(width: 100, height: 100)
            
            // 脉冲效果
            ZenPulseEffect(color: .zenBlue, size: 60)
            
            // 水波纹
            ZenWaterRipple(color: .zenGreen)
                .frame(width: 100, height: 100)
            
            // 加载指示器
            ZenLoadingIndicator(color: .zenAccent, size: 40)
            
            // 呼吸圆圈
            ZenBreathingCircle(color: .zenGold, minSize: 50, maxSize: 80)
        }
        .padding(40)
        .background(Color.zenGray)
    }
}