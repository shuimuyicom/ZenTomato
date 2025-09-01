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
        VStack(spacing: 24) {
            // 顶部间距，使内容整体下移
            Spacer()
                .frame(height: 20)

            // 顶部应用信息
            appInfoSection

            // 协议链接区域
            protocolLinksSection

            // 版权声明
            copyrightSection

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
        VStack(spacing: 16) {
            // 应用图标 - 使用系统级别的应用图标确保完整显示
            appIconView
            
            // 应用名称
            Text(appName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color.zenTextGray)
            
            // 版本信息
            Text(appVersion)
                .font(.system(size: 14))
                .foregroundColor(Color.zenSecondaryText)
        }
    }
    
    /// 协议链接区域
    private var protocolLinksSection: some View {
        VStack(spacing: 12) {
            // 服务协议链接
            Button(action: openTermsOfService) {
                HStack {
                    Image(systemName: "doc.text")
                        .font(.system(size: 16))
                        .foregroundColor(Color.zenBlue)
                    
                    Text("服务协议")
                        .font(.system(size: 16))
                        .foregroundColor(Color.zenBlue)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundColor(Color.zenSecondaryText)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.zenCardBackground.opacity(0.8))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            // 隐私协议链接
            Button(action: openPrivacyPolicy) {
                HStack {
                    Image(systemName: "hand.raised")
                        .font(.system(size: 16))
                        .foregroundColor(Color.zenBlue)
                    
                    Text("隐私协议")
                        .font(.system(size: 16))
                        .foregroundColor(Color.zenBlue)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundColor(Color.zenSecondaryText)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.zenCardBackground.opacity(0.8))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    /// 版权声明区域
    private var copyrightSection: some View {
        VStack(spacing: 8) {
            Text("Copyright © 2025 水木易. All rights reserved. ")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.zenSecondaryText)
            
            Text("禅意番茄工作法")
                .font(.system(size: 12))
                .foregroundColor(Color.zenSecondaryText.opacity(0.8))
        }
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
