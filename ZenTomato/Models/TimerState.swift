//
//  TimerState.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  计时器状态枚举
//

import Foundation

/// 计时器状态
enum TimerState: String, CaseIterable {
    /// 空闲状态
    case idle = "idle"
    /// 运行中
    case running = "running" 
    /// 暂停状态
    case paused = "paused"
    /// 已完成
    case completed = "completed"
    
    /// 状态显示名称
    var displayName: String {
        switch self {
        case .idle:
            return "准备就绪"
        case .running:
            return "进行中"
        case .paused:
            return "已暂停"
        case .completed:
            return "已完成"
        }
    }
}