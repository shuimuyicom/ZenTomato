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
    
    /// 取消令牌集合
    private var cancellables = Set<AnyCancellable>()
    
    /// 菜单栏更新定时器
    private var menuBarUpdateTimer: Timer?
    
    // MARK: - Initialization
    
    init(timerEngine: TimerEngine, audioPlayer: AudioPlayer, notificationManager: NotificationManager) {
        self.timerEngine = timerEngine
        self.audioPlayer = audioPlayer
        self.notificationManager = notificationManager
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
        
        popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
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
        popover?.contentSize = NSSize(width: 300, height: 400)
        popover?.behavior = .transient
        popover?.animates = true
        
        // 创建主视图
        let contentView = MainView(
            timerEngine: timerEngine,
            audioPlayer: audioPlayer,
            notificationManager: notificationManager,
            menuBarManager: self
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
        // 监听计时器状态变化
        timerEngine.$currentState
            .sink { [weak self] _ in
                self?.updateMenuBarDisplay()
            }
            .store(in: &cancellables)
        
        // 监听计时器阶段变化
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

            // 使用自定义番茄图标，始终显示为白色
            if let image = NSImage(named: "BarIconIdle") {
                // 设置为模板图像，这样会自动适应系统主题（在深色模式下显示白色，浅色模式下显示黑色）
                image.isTemplate = true
                button.image = image

                // 不设置 contentTintColor，让系统自动处理颜色
                button.contentTintColor = nil
            } else {
                // 如果自定义图标加载失败，回退到系统图标
                if let image = NSImage(systemSymbolName: "timer", accessibilityDescription: nil) {
                    image.isTemplate = true
                    button.image = image
                    button.contentTintColor = nil
                }
            }

            // 更新标题
            self.updateMenuBarDisplay()
        }
    }
    
    /// 更新菜单栏显示
    private func updateMenuBarDisplay() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let button = self.statusItem?.button else { return }
            
            if self.showTimeInMenuBar && self.timerEngine.currentState == .running {
                // 显示时间
                button.title = " " + self.timerEngine.formattedTimeRemaining
            } else {
                // 只显示图标
                button.title = ""
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