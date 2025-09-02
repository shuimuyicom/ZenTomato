//
//  MenuBarManager.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  菜单栏管理器 - 管理菜单栏图标、状态显示和弹出面板
//

import SwiftUI
import AppKit
import Combine

/// 菜单栏管理器
class MenuBarManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    /// 是否在菜单栏显示时间
    @Published var showTimeInMenuBar: Bool = true {
        didSet {
            updateMenuBarDisplay()
        }
    }
    
    /// 是否显示弹出面板
    @Published var isPopoverShown: Bool = false
    
    // MARK: - Private Properties
    
    /// 状态栏项
    private var statusItem: NSStatusItem?
    
    /// 弹出窗口
    private var popover: NSPopover?
    
    /// 事件监视器（用于检测点击外部关闭弹窗）
    private var eventMonitor: EventMonitor?
    
    /// 计时引擎
    private let timerEngine: TimerEngine
    
    /// 音频播放器
    private let audioPlayer: AudioPlayer
    
    /// 通知管理器
    private let notificationManager: NotificationManager

    /// 开机启动管理器
    private let launchAtLoginManager: LaunchAtLoginManager

    /// 取消令牌集合
    private var cancellables = Set<AnyCancellable>()
    
    /// 菜单栏更新定时器
    private var menuBarUpdateTimer: Timer?
    
    // MARK: - Initialization
    
    init(timerEngine: TimerEngine, audioPlayer: AudioPlayer, notificationManager: NotificationManager, launchAtLoginManager: LaunchAtLoginManager) {
        self.timerEngine = timerEngine
        self.audioPlayer = audioPlayer
        self.notificationManager = notificationManager
        self.launchAtLoginManager = launchAtLoginManager
        super.init()

        setupBindings()
        setupEventMonitor()
    }
    
    // MARK: - Public Methods
    
    /// 设置菜单栏
    func setupMenuBar() {
        // 创建状态栏项
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // 设置菜单栏按钮
        if let button = statusItem?.button {
            updateMenuBarIcon()
            button.action = #selector(togglePopover)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // 创建弹出窗口
        setupPopover()
        
        // 开始更新菜单栏显示
        startMenuBarUpdates()
    }
    
    /// 显示弹出面板
    func showPopover() {
        guard let button = statusItem?.button else { return }

        // 调整 popover 显示位置，使其更好地适应大尺寸内容
        // 使用 .minY 确保 popover 在菜单栏按钮下方显示
        popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

        // 如果需要，可以通过调整 popover 的位置来优化显示效果
        if let popoverWindow = popover?.contentViewController?.view.window {
            // 获取屏幕尺寸
            if let screen = NSScreen.main {
                let screenFrame = screen.visibleFrame
                let popoverFrame = popoverWindow.frame

                // 确保 popover 不会超出屏幕边界
                var newOrigin = popoverFrame.origin

                // 检查右边界
                if popoverFrame.maxX > screenFrame.maxX {
                    newOrigin.x = screenFrame.maxX - popoverFrame.width - 10
                }

                // 检查左边界
                if popoverFrame.minX < screenFrame.minX {
                    newOrigin.x = screenFrame.minX + 10
                }

                // 检查下边界
                if popoverFrame.minY < screenFrame.minY {
                    newOrigin.y = screenFrame.minY + 10
                }

                // 应用新位置
                if newOrigin != popoverFrame.origin {
                    popoverWindow.setFrameOrigin(newOrigin)
                }
            }
        }

        isPopoverShown = true
        eventMonitor?.start()
    }
    
    /// 隐藏弹出面板
    func hidePopover() {
        popover?.performClose(nil)
        isPopoverShown = false
        eventMonitor?.stop()
    }
    
    /// 切换弹出面板显示状态
    @objc func togglePopover() {
        if isPopoverShown {
            hidePopover()
        } else {
            showPopover()
        }
    }
    
    /// 更新菜单栏标题
    func updateMenuBarTitle(_ text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.statusItem?.button?.title = text
        }
    }
    
    // MARK: - Private Methods
    
    /// 设置弹出窗口
    private func setupPopover() {
        popover = NSPopover()
        // 调整弹出窗口尺寸以匹配 MainView 的实际内容尺寸 (380x680)
        // 确保应用图标和所有内容都能完整显示
        popover?.contentSize = NSSize(width: 380, height: 680)
        popover?.behavior = .transient
        popover?.animates = true
        
        // 创建主视图
        let contentView = MainView(
            timerEngine: timerEngine,
            audioPlayer: audioPlayer,
            notificationManager: notificationManager,
            menuBarManager: self,
            launchAtLoginManager: launchAtLoginManager
        )
        
        // 设置弹出窗口内容
        popover?.contentViewController = NSHostingController(rootView: contentView)
        
        // 监听弹窗关闭事件
        popover?.delegate = self
    }
    
    /// 设置事件监视器
    private func setupEventMonitor() {
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if self?.isPopoverShown == true {
                self?.hidePopover()
            }
        }
    }
    
    /// 设置绑定
    private func setupBindings() {
        // 监听计时器状态变化 - 状态变化时需要更新图标（显示/隐藏状态指示器）
        timerEngine.$currentState
            .sink { [weak self] _ in
                self?.updateMenuBarIcon()  // 修改：状态变化时也要更新图标
            }
            .store(in: &cancellables)

        // 监听计时器阶段变化 - 阶段变化时需要更新图标颜色
        timerEngine.$currentPhase
            .sink { [weak self] _ in
                self?.updateMenuBarIcon()
            }
            .store(in: &cancellables)

        // 监听配置变化
        timerEngine.$configuration
            .map { $0.showTimeInMenuBar }
            .assign(to: &$showTimeInMenuBar)
    }
    
    /// 更新菜单栏图标
    private func updateMenuBarIcon() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let button = self.statusItem?.button else { return }

            // 创建带状态指示器的图标
            let finalImage = self.createIconWithStatusIndicator()
            button.image = finalImage

            // 更新标题
            self.updateMenuBarDisplay()
        }
    }

    /// 创建带状态指示器的图标
    private func createIconWithStatusIndicator() -> NSImage? {
        // 调试信息
        print("🔍 创建图标 - 当前状态: \(timerEngine.currentState), 当前阶段: \(timerEngine.currentPhase)")

        // 获取基础图标
        let baseImage: NSImage
        if let customImage = NSImage(named: "BarIconIdle") {
            baseImage = customImage
        } else if let systemImage = NSImage(systemSymbolName: "timer", accessibilityDescription: nil) {
            baseImage = systemImage
        } else {
            return nil
        }

        // 设置图标尺寸（菜单栏标准尺寸）
        let iconSize = NSSize(width: 18, height: 18)
        baseImage.size = iconSize

        // 如果计时器处于停止状态，直接返回基础图标
        guard timerEngine.currentState == .running || timerEngine.currentState == .paused else {
            print("⚪ 返回基础图标（无状态指示器）")
            baseImage.isTemplate = true
            return baseImage
        }

        print("🔴 创建带状态指示器的图标 - 阶段: \(timerEngine.currentPhase)")

        // 创建复合图像
        let compositeImage = NSImage(size: iconSize)
        compositeImage.lockFocus()

        // 绘制基础图标 - 始终使用白色
        guard let baseImageCopy = baseImage.copy() as? NSImage else {
            print("⚠️ 无法复制菜单栏图标")
            compositeImage.unlockFocus()
            return baseImage // 返回原始图像作为回退
        }
        baseImageCopy.isTemplate = true

        // 始终使用白色绘制图标（不考虑系统主题）
        let iconColor = NSColor.white
        iconColor.setFill()
        let iconRect = NSRect(origin: .zero, size: iconSize)

        // 创建图标的蒙版并填充白色
        if let cgImage = baseImageCopy.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            guard let currentContext = NSGraphicsContext.current else {
                print("⚠️ 无法获取图形上下文")
                compositeImage.unlockFocus()
                return baseImage // 返回原始图像作为回退
            }
            let context = currentContext.cgContext
            context.saveGState()
            context.clip(to: iconRect, mask: cgImage)
            context.fill(iconRect)
            context.restoreGState()
        } else {
            // 回退方案：直接绘制图标
            baseImageCopy.draw(in: iconRect)
        }

        // 获取状态指示器颜色
        let indicatorColor = getStatusIndicatorColor()

        // 绘制状态指示器小圆点（位于右下角）
        let dotSize: CGFloat = 6
        let dotRect = NSRect(
            x: iconSize.width - dotSize - 1,
            y: 1,
            width: dotSize,
            height: dotSize
        )

        // 绘制白色背景圆圈（增强对比度）
        NSColor.white.setFill()
        let backgroundPath = NSBezierPath(ovalIn: dotRect.insetBy(dx: -1, dy: -1))
        backgroundPath.fill()

        // 绘制彩色状态圆点
        indicatorColor.setFill()
        let dotPath = NSBezierPath(ovalIn: dotRect)
        dotPath.fill()

        compositeImage.unlockFocus()

        // 不设置为模板图像，保持我们自定义的颜色
        compositeImage.isTemplate = false

        return compositeImage
    }

    /// 获取状态指示器颜色
    private func getStatusIndicatorColor() -> NSColor {
        switch timerEngine.currentPhase {
        case .work:
            return NSColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0) // zenRed
        case .shortBreak:
            return NSColor(red: 0.4, green: 0.7, blue: 0.4, alpha: 1.0) // zenGreen
        case .longBreak:
            return NSColor(red: 0.4, green: 0.6, blue: 0.8, alpha: 1.0) // zenBlue
        }
    }
    
    /// 更新菜单栏显示
    private func updateMenuBarDisplay() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let button = self.statusItem?.button else { return }

            if self.showTimeInMenuBar && self.timerEngine.currentState == .running {
                // 显示时间 - 使用等宽字体防止抖动
                let timeText = self.timerEngine.formattedTimeRemaining

                // 创建带有等宽数字字体的属性字符串
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
                ]
                let attributedString = NSAttributedString(string: " " + timeText, attributes: attributes)
                button.attributedTitle = attributedString
            } else {
                // 只显示图标，清空时间显示
                button.attributedTitle = NSAttributedString(string: "")
            }
        }
    }
    
    /// 开始菜单栏更新
    private func startMenuBarUpdates() {
        menuBarUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            if self?.timerEngine.currentState == .running {
                self?.updateMenuBarDisplay()
            }
        }
    }
    
    /// 停止菜单栏更新
    private func stopMenuBarUpdates() {
        menuBarUpdateTimer?.invalidate()
        menuBarUpdateTimer = nil
    }
    
    deinit {
        stopMenuBarUpdates()
        eventMonitor?.stop()
    }
}

// MARK: - NSPopoverDelegate

extension MenuBarManager: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        isPopoverShown = false
        eventMonitor?.stop()
    }
    
    func popoverWillShow(_ notification: Notification) {
        isPopoverShown = true
        eventMonitor?.start()
    }
}

// MARK: - Event Monitor

/// 事件监视器（用于检测点击外部关闭弹窗）
class EventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void
    
    init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }
    
    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }
    
    func stop() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
    
    deinit {
        stop()
    }
}