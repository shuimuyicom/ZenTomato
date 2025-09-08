//
//  AudioPlayer.swift
//  ZenTomato
//
//  Created by Ban on 2025/8/13.
//  音频播放器 - 管理所有音效的播放和音量控制
//

import Foundation
import AVFoundation
import Combine

/// 音频播放器
class AudioPlayer: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 音频设置
    @Published var settings: AudioSettings {
        didSet {
            settings.save()
            updateVolumes()
        }
    }
    
    /// 是否正在播放禅韵木鱼
    @Published var isTickingPlaying: Bool = false

    /// 是否暂停播放禅韵木鱼（用于工作阶段暂停时）
    @Published var isTickingPaused: Bool = false
    
    // MARK: - Private Properties

    /// 音频播放器字典
    private var players: [SoundType: AVAudioPlayer] = [:]

    /// 白噪音播放器字典
    private var whiteNoisePlayers: [WhiteNoiseType: AVAudioPlayer] = [:]

    /// 音频引擎（用于高级音频控制）
    private var audioEngine: AVAudioEngine?
    
    /// 淡入淡出定时器（按播放器维度，避免相互打断）
    private var fadeTimers: [ObjectIdentifier: Timer] = [:]
    
    /// 最近一次启用的白噪音类型集合（用于差异化响应设置变更）
    private var lastEnabledWhiteNoiseTypes: Set<WhiteNoiseType> = []
    
    /// 取消令牌集合
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        self.settings = AudioSettings.load()
        setupAudioSession()
        loadAudioFiles()
        loadWhiteNoiseFiles()
        // 记录初始启用集合
        lastEnabledWhiteNoiseTypes = Set(self.settings.enabledWhiteNoiseTypes)
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// 播放开始音效
    func playWindupSound() {
        playSound(.windup)
    }
    
    /// 播放结束音效
    func playDingSound() {
        playSound(.ding)
    }
    
    /// 开始播放白噪音（兼容旧接口）
    func startTickingSound() {
        startWhiteNoise()
    }

    /// 停止播放白噪音（兼容旧接口）
    func stopTickingSound() {
        stopWhiteNoise()
    }

    /// 开始播放白噪音
    func startWhiteNoise() {
        for whiteNoiseType in settings.enabledWhiteNoiseTypes {
            startWhiteNoise(for: whiteNoiseType)
        }

        // 更新播放状态
        updateTickingPlayingState()
    }

    /// 停止播放白噪音
    func stopWhiteNoise() {
        for (_, player) in whiteNoisePlayers {
            guard player.isPlaying else { continue }

            // 淡出效果
            fadeOut(player: player) { [weak self] in
                player.stop()
                player.currentTime = 0
                self?.updateTickingPlayingState()
            }
        }
    }

    /// 更新播放状态
    private func updateTickingPlayingState() {
        let hasPlayingWhiteNoise = whiteNoisePlayers.values.contains { $0.isPlaying }
        isTickingPlaying = hasPlayingWhiteNoise
        if !hasPlayingWhiteNoise {
            isTickingPaused = false
        }
    }

    /// 暂停播放白噪音（工作阶段暂停时调用）
    func pauseTickingSound() {
        // 暂停所有正在播放的白噪音
        for (_, player) in whiteNoisePlayers {
            guard player.isPlaying else { continue }

            // 淡出效果后暂停
            fadeOut(player: player) { [weak self] in
                player.pause()
                self?.isTickingPaused = true
            }
        }
    }

    /// 恢复播放白噪音（工作阶段恢复时调用）
    func resumeTickingSound() {
        guard isTickingPaused else { return }

        // 恢复所有启用的白噪音
        for whiteNoiseType in settings.enabledWhiteNoiseTypes {
            if let player = whiteNoisePlayers[whiteNoiseType] {
                player.volume = 0
                player.play()

                // 淡入效果
                fadeIn(player: player, to: settings.getEffectiveVolume(for: whiteNoiseType))
            }
        }

        isTickingPaused = false
    }
    
    /// 停止所有声音
    func stopAllSounds() {
        players.forEach { _, player in
            player.stop()
            player.currentTime = 0
        }

        whiteNoisePlayers.forEach { _, player in
            player.stop()
            player.currentTime = 0
        }

        isTickingPlaying = false
        isTickingPaused = false
        // 取消并清空所有淡入淡出定时器
        fadeTimers.values.forEach { $0.invalidate() }
        fadeTimers.removeAll()
    }
    
    /// 设置音量
    func setVolume(for soundType: SoundType, volume: Float) {
        switch soundType {
        case .windup:
            settings.windupVolume = volume
        case .ding:
            settings.dingVolume = volume
        case .ticking:
            settings.tickingVolume = volume
            // 如果正在播放，实时更新音量
            if isTickingPlaying, let player = players[.ticking] {
                player.volume = settings.getEffectiveVolume(for: .ticking)
            }
        }
    }
    
    /// 测试音效
    func testSound(_ soundType: SoundType) {
        switch soundType {
        case .ticking:
            if isTickingPlaying {
                stopTickingSound()
            } else {
                startTickingSound()
                // 3秒后自动停止测试
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    self?.stopTickingSound()
                }
            }
        default:
            playSound(soundType)
        }
    }
    
    // MARK: - Private Methods
    
    /// 设置音频会话
    private func setupAudioSession() {
        // macOS 不需要设置 AVAudioSession
        // AVAudioPlayer 会自动处理音频播放
        // 在 macOS 上，音频会话管理由系统自动处理
    }
    
    /// 加载音频文件
    private func loadAudioFiles() {
        for soundType in SoundType.allCases {
            loadAudioFile(for: soundType)
        }
    }

    /// 加载白噪音文件
    private func loadWhiteNoiseFiles() {
        for whiteNoiseType in WhiteNoiseType.allCases {
            loadWhiteNoiseFile(for: whiteNoiseType)
        }
    }
    
    /// 加载单个音频文件
    private func loadAudioFile(for soundType: SoundType) {
        // 尝试从 Bundle 加载音频文件
        guard let url = Bundle.main.url(
            forResource: soundType.rawValue,
            withExtension: "mp3"
        ) else {
            print("找不到音频文件: \(soundType.fileName)")
            // 创建静默播放器作为占位符
            createSilentPlayer(for: soundType)
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = settings.getEffectiveVolume(for: soundType)
            players[soundType] = player
        } catch {
            print("加载音频文件失败: \(error)")
            createSilentPlayer(for: soundType)
        }
    }

    /// 加载单个白噪音文件
    private func loadWhiteNoiseFile(for whiteNoiseType: WhiteNoiseType) {
        // 尝试从 Bundle 加载音频文件
        guard let url = Bundle.main.url(
            forResource: whiteNoiseType.rawValue,
            withExtension: "mp3"
        ) else {
            print("找不到白噪音文件: \(whiteNoiseType.fileName)")
            // 创建静默播放器作为占位符
            createSilentWhiteNoisePlayer(for: whiteNoiseType)
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = settings.getEffectiveVolume(for: whiteNoiseType)
            whiteNoisePlayers[whiteNoiseType] = player
        } catch {
            print("加载白噪音文件失败: \(error)")
            createSilentWhiteNoisePlayer(for: whiteNoiseType)
        }
    }

    /// 获取（必要时懒加载）白噪音播放器
    private func getOrLoadWhiteNoisePlayer(for whiteNoiseType: WhiteNoiseType) -> AVAudioPlayer? {
        if let player = whiteNoisePlayers[whiteNoiseType] { return player }
        loadWhiteNoiseFile(for: whiteNoiseType)
        return whiteNoisePlayers[whiteNoiseType]
    }

    /// 启动某个白噪音
    private func startWhiteNoise(for whiteNoiseType: WhiteNoiseType) {
        guard let player = getOrLoadWhiteNoisePlayer(for: whiteNoiseType) else {
            print("[Audio] 无法获取播放器: \(whiteNoiseType)")
            return
        }

        player.numberOfLoops = -1 // 无限循环
        player.currentTime = 0
        player.volume = 0

        // 尝试播放，失败则准备后重试一次
        if !player.play() {
            print("[Audio] 播放失败，准备后重试: \(whiteNoiseType)")
            player.prepareToPlay()
            _ = player.play()
        }

        // 淡入到目标音量
        fadeIn(player: player, to: settings.getEffectiveVolume(for: whiteNoiseType))
    }

    /// 停止某个白噪音
    private func stopWhiteNoise(for whiteNoiseType: WhiteNoiseType) {
        guard let player = whiteNoisePlayers[whiteNoiseType], player.isPlaying else { return }
        fadeOut(player: player) { [weak self] in
            player.stop()
            player.currentTime = 0
            self?.updateTickingPlayingState()
        }
    }
    
    /// 创建静默播放器（用于测试或音频文件缺失时）
    private func createSilentPlayer(for soundType: SoundType) {
        // 创建一个极短的静音音频作为占位符
        let sampleRate = 44100.0
        let duration = 0.01
        let frameCount = Int(sampleRate * duration)
        
        guard let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 1
        ),
              let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: AVAudioFrameCount(frameCount)
        ) else { return }
        
        buffer.frameLength = buffer.frameCapacity
        
        // 填充静音数据
        if let channelData = buffer.floatChannelData {
            for frame in 0..<frameCount {
                channelData[0][frame] = 0.0
            }
        }
        
        // 将缓冲区写入临时文件
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(soundType.rawValue)_silent.mp3")
        
        do {
            let file = try AVAudioFile(
                forWriting: tempURL,
                settings: format.settings
            )
            try file.write(from: buffer)
            
            let player = try AVAudioPlayer(contentsOf: tempURL)
            player.prepareToPlay()
            players[soundType] = player
        } catch {
            print("创建静默播放器失败: \(error)")
        }
    }

    /// 创建静默白噪音播放器（用于测试或音频文件缺失时）
    private func createSilentWhiteNoisePlayer(for whiteNoiseType: WhiteNoiseType) {
        // 创建一个极短的静音音频作为占位符
        let sampleRate = 44100.0
        let duration = 0.01
        let frameCount = Int(sampleRate * duration)

        guard let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 1
        ),
              let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: AVAudioFrameCount(frameCount)
        ) else { return }

        buffer.frameLength = buffer.frameCapacity

        // 填充静音数据
        if let channelData = buffer.floatChannelData {
            for frame in 0..<frameCount {
                channelData[0][frame] = 0.0
            }
        }

        // 将缓冲区写入临时文件
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(whiteNoiseType.rawValue)_silent.mp3")

        do {
            let file = try AVAudioFile(
                forWriting: tempURL,
                settings: format.settings
            )
            try file.write(from: buffer)

            let player = try AVAudioPlayer(contentsOf: tempURL)
            player.prepareToPlay()
            whiteNoisePlayers[whiteNoiseType] = player
        } catch {
            print("创建静默白噪音播放器失败: \(error)")
        }
    }
    
    /// 设置绑定
    private func setupBindings() {
        // 监听设置变化
        $settings
            .sink { [weak self] newSettings in
                guard let self = self else { return }
                self.updateVolumes()

                // 差异化处理白噪音的启用/禁用，确保切换时立即生效
                let newSet = Set(newSettings.enabledWhiteNoiseTypes)
                let added = newSet.subtracting(self.lastEnabledWhiteNoiseTypes)
                let removed = self.lastEnabledWhiteNoiseTypes.subtracting(newSet)

                if !added.isEmpty || !removed.isEmpty {
                    // 在主线程执行播放器操作
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        added.forEach { strongSelf.startWhiteNoise(for: $0) }
                        removed.forEach { strongSelf.stopWhiteNoise(for: $0) }
                        strongSelf.lastEnabledWhiteNoiseTypes = newSet
                        strongSelf.updateTickingPlayingState()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    /// 更新所有音量
    private func updateVolumes() {
        for (soundType, player) in players {
            player.volume = settings.getEffectiveVolume(for: soundType)
        }

        for (whiteNoiseType, player) in whiteNoisePlayers {
            player.volume = settings.getEffectiveVolume(for: whiteNoiseType)
        }
    }
    
    /// 播放音效
    private func playSound(_ soundType: SoundType) {
        guard let player = players[soundType] else { return }
        
        // 如果正在播放，先停止
        if player.isPlaying {
            player.stop()
        }
        
        player.currentTime = 0
        player.volume = settings.getEffectiveVolume(for: soundType)
        player.play()
    }
    
    /// 淡入效果（独立定时器，避免互相打断）
    private func fadeIn(player: AVAudioPlayer, to targetVolume: Float, duration: TimeInterval = 0.1) {
        let id = ObjectIdentifier(player)
        fadeTimers[id]?.invalidate()

        let steps = 10
        let stepDuration = duration / Double(steps)
        let volumeStep = targetVolume / Float(steps)
        var currentStep = 0

        player.volume = 0

        let timer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
            currentStep += 1
            player.volume = volumeStep * Float(currentStep)

            if currentStep >= steps {
                timer.invalidate()
                player.volume = targetVolume
                self?.fadeTimers[id] = nil
            }
        }
        fadeTimers[id] = timer
    }
    
    /// 淡出效果（独立定时器，避免互相打断）
    private func fadeOut(player: AVAudioPlayer, duration: TimeInterval = 0.1, completion: @escaping () -> Void) {
        let id = ObjectIdentifier(player)
        fadeTimers[id]?.invalidate()

        let steps = 10
        let stepDuration = duration / Double(steps)
        let startVolume = player.volume
        let volumeStep = startVolume / Float(steps)
        var currentStep = steps

        let timer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
            currentStep -= 1
            player.volume = volumeStep * Float(currentStep)

            if currentStep <= 0 {
                timer.invalidate()
                player.volume = 0
                self?.fadeTimers[id] = nil
                completion()
            }
        }
        fadeTimers[id] = timer
    }
}

// MARK: - Preview Helper

extension AudioPlayer {
    /// 创建预览用的音频播放器
    static var preview: AudioPlayer {
        return AudioPlayer()
    }
}