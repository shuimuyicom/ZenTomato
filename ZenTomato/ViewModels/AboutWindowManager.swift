//
//  AboutWindowManager.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  关于窗口管理器 - 管理关于页面的显示和窗口状态
//

import SwiftUI
import AppKit

/// 关于窗口管理器
class AboutWindowManager: NSObject, ObservableObject {
    // MARK: - Properties
    
    /// 关于窗口实例
    private var aboutWindow: NSWindow?
    
    /// 窗口是否已显示
    @Published var isWindowShown = false
    
    // MARK: - Singleton
    
    static let shared = AboutWindowManager()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// 显示关于窗口
    func showAboutWindow() {
        // 如果窗口已存在且可见，将其置于前台
        if let window = aboutWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        // 创建新窗口或重新显示已存在的窗口
        if aboutWindow == nil {
            createAboutWindow()
        }
        
        aboutWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        isWindowShown = true
    }
    
    /// 隐藏关于窗口
    func hideAboutWindow() {
        aboutWindow?.orderOut(nil)
        isWindowShown = false
    }
    
    /// 关闭关于窗口
    func closeAboutWindow() {
        aboutWindow?.close()
        aboutWindow = nil
        isWindowShown = false
    }
    
    // MARK: - Private Methods
    
    /// 创建关于窗口
    private func createAboutWindow() {
        // 创建关于视图
        let aboutView = AboutView()

        // 创建窗口内容视图控制器
        let hostingController = NSHostingController(rootView: aboutView)

        // 计算合适的窗口尺寸 - 确保内容完整显示
        let windowSize = NSSize(width: 450, height: 380)

        // 创建窗口 - 确保包含正确的样式掩码
        aboutWindow = NSWindow(
            contentRect: NSRect(origin: .zero, size: windowSize),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        // 配置窗口属性
        aboutWindow?.title = "关于 禅番茄"
        aboutWindow?.contentViewController = hostingController
        aboutWindow?.isReleasedWhenClosed = false

        // 设置窗口尺寸限制
        aboutWindow?.minSize = windowSize
        aboutWindow?.maxSize = windowSize

        // 设置窗口样式 - 保持标准的 macOS 窗口外观
        aboutWindow?.titlebarAppearsTransparent = false
        aboutWindow?.backgroundColor = NSColor.windowBackgroundColor

        // 监听窗口关闭事件
        aboutWindow?.delegate = self

        // 设置窗口为普通层级，避免影响关闭按钮功能
        aboutWindow?.level = .normal

        // 确保窗口在屏幕中央显示
        aboutWindow?.center()
    }
}

// MARK: - NSWindowDelegate

extension AboutWindowManager: NSWindowDelegate {
    /// 窗口即将关闭
    func windowWillClose(_ notification: Notification) {
        isWindowShown = false
    }
    
    /// 窗口应该关闭
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // 允许关闭窗口
        return true
    }
}
