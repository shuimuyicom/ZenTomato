//
//  AboutView.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  关于页面 - 显示应用信息、协议链接和版权声明
//

import SwiftUI

/// 关于页面视图
struct AboutView: View {
    // MARK: - Properties
    
    /// 应用版本信息
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "250826"
        return "Version \(version) (\(build))"
    }
    
    /// 应用名称
    private var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "ZenTomato"
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部间距，使内容整体下移
            Spacer()
                .frame(height: 20)

            // 顶部应用信息
            appInfoSection

            // 版权声明（与版本信息之间：中等间距）
            copyrightSection
                .padding(.top, 16)

            // 协议链接区域 - 移至底部，改为小按钮样式（与版权信息之间：较大间距）
            protocolLinksSection
                .padding(.top, 24)

            Spacer()
        }
        .padding(32)
        .frame(width: 450, height: 420)
        .background(Color.zenGray.opacity(0.95))
        .cornerRadius(16)
    }
    
    // MARK: - Subviews

    /// 应用图标视图 - 使用改进的图标加载和显示方式
    private var appIconView: some View {
        Group {
            // 尝试多种方式获取应用图标
            if let appIcon = getAppIcon() {
                Image(nsImage: appIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .background(Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 80 * 0.2237, style: .continuous))
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            } else {
                // 最终回退图标
                Image(systemName: "leaf.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(Color.zenRed)
                    .clipShape(RoundedRectangle(cornerRadius: 80 * 0.2237, style: .continuous))
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
        }
    }

    /// 获取应用图标的辅助方法
    private func getAppIcon() -> NSImage? {
        // 方法1: 尝试从Bundle获取指定尺寸的图标
        if let bundleIcon = NSImage(named: "AppIcon") {
            // 确保图标尺寸正确
            let targetSize = NSSize(width: 128, height: 128)
            bundleIcon.size = targetSize
            return bundleIcon
        }

        // 方法2: 尝试系统应用图标
        if let systemIcon = NSApp.applicationIconImage {
            // 调整系统图标尺寸
            let targetSize = NSSize(width: 128, height: 128)
            systemIcon.size = targetSize
            return systemIcon
        }

        // 方法3: 尝试从Assets直接加载特定尺寸
        if let iconImage = NSImage(named: NSImage.Name("icon_128x128")) {
            return iconImage
        }

        return nil
    }

    /// 应用信息区域
    private var appInfoSection: some View {
        VStack(spacing: 0) {
            // 应用图标 - 使用系统级别的应用图标确保完整显示
            appIconView
                .padding(.bottom, 18) // 图标与主标题：较大间距

            // 主标题
            Text("禅番茄")
                .font(.system(size: 26, weight: .medium))
                .foregroundColor(Color.zenAccent)

            // 副标题：形成标题组（与主标题紧密）
            Text("禅意番茄工作法")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.zenTextGray)
                .padding(.top, 8) // 主标题与副标题：紧密间距

            // 版本信息：与副标题中等间距
            Text(appVersion)
                .font(.system(size: 14))
                .foregroundColor(Color.zenSecondaryText)
                .padding(.top, 12)
        }
    }
    
    /// 协议链接区域 - 更小的按钮样式
    private var protocolLinksSection: some View {
        HStack(spacing: 8) { // 两个协议链接之间：小间距
            // 隐私协议放前
            Button(action: openPrivacyPolicy) {
                HStack(spacing: 4) {
                    Image(systemName: "hand.raised")
                        .font(.system(size: 11))
                        .foregroundColor(Color.zenSecondaryText.opacity(0.85))

                    Text("隐私协议")
                        .font(.system(size: 11))
                        .foregroundColor(Color.zenSecondaryText.opacity(0.85))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.zenCardBackground.opacity(0.55))
                .cornerRadius(4)
            }
            .buttonStyle(PlainButtonStyle())

            // 服务协议随后
            Button(action: openTermsOfService) {
                HStack(spacing: 4) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 11))
                        .foregroundColor(Color.zenSecondaryText.opacity(0.85))

                    Text("服务协议")
                        .font(.system(size: 11))
                        .foregroundColor(Color.zenSecondaryText.opacity(0.85))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.zenCardBackground.opacity(0.55))
                .cornerRadius(4)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.top, 22) // 版权信息与协议链接之间：较大间距
    }
    
    /// 版权声明区域
    private var copyrightSection: some View {
        VStack(spacing: 6) {
            Text("Copyright © 2025 水木易. All rights reserved.")
                .font(.system(size: 12))
                .foregroundColor(Color.zenSecondaryText)
        }
        .padding(.top, 14) // 版本信息与版权信息之间：中等间距
    }
    
    // MARK: - Actions
    
    /// 打开服务协议
    private func openTermsOfService() {
        if let url = URL(string: "https://shuimuyi.notion.site/zentomato-terms-of-service") {
            NSWorkspace.shared.open(url)
        }
    }
    
    /// 打开隐私协议
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://shuimuyi.notion.site/zentomato-privacy-policy?source=copy_link") {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Preview

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
