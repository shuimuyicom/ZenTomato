//
//  TimerPhase.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  计时器阶段枚举
//

import SwiftUI

/// 计时器阶段
enum TimerPhase: String, CaseIterable {
    /// 工作阶段
    case work = "work"
    /// 短休息
    case shortBreak = "shortBreak"
    /// 长休息
    case longBreak = "longBreak"
    
    /// 阶段显示名称
    var displayName: String {
        switch self {
        case .work:
            return "专注工作"
        case .shortBreak:
            return "短暂休息"
        case .longBreak:
            return "长休息"
        }
    }
    
    /// 阶段对应的颜色
    var color: Color {
        switch self {
        case .work:
            return Color.zenRed
        case .shortBreak:
            return Color.zenGreen
        case .longBreak:
            return Color.zenBlue
        }
    }
    
    /// 阶段图标
    var icon: String {
        switch self {
        case .work:
            return "desktopcomputer"
        case .shortBreak:
            return "cup.and.saucer"
        case .longBreak:
            return "leaf"
        }
    }
}