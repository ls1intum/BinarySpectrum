import AVFoundation
import Foundation
import SwiftUI

// MARK: - Audio Types

enum SoundEffectType: String {
    case buttonTap = "button_tap"
    case toggleSwitch = "toggle_switch"
    case notification
    case menuTransition = "menu_transition"
    case correctAnswer = "correct_answer"
    case wrongAnswer = "wrong_answer"
    case achievementUnlocked = "achievement_unlocked"
    case levelCompleted = "level_completed"
    case countdownTick = "countdown_tick"
    case gameStart = "game_start"
    case gameOver = "game_over"
    case binaryGameAction = "binary_game_action"
    case colorGameAction = "color_game_action"
    case pixelGameAction = "pixel_game_action"
    case fallback
}

enum MusicType: String {
    case mainMenu = "main_menu"
    case gamePlay = "game_play"
    case achievementScreen = "achievement_screen"
    case binaryGame = "binary_game"
    case colorGame = "color_game"
    case pixelGame = "pixel_game"
    case victoryTune = "victory_tune"
}

// MARK: - Sound Service

final class SoundService {
    static let shared = SoundService()

    private var soundEffectPlayers: [String: AVAudioPlayer] = [:]
    private var musicPlayer: AVAudioPlayer?
    private var currentMusic: MusicType?

    var isSoundEnabled: Bool {
        PersistenceManager.shared.loadBool(forKey: .soundEnabled)
    }

    var isMusicEnabled: Bool {
        PersistenceManager.shared.loadBool(forKey: .musicEnabled)
    }

    var musicVolume: Float {
        clamped(PersistenceManager.shared.loadDouble(forKey: .musicVolume))
    }

    var soundVolume: Float {
        clamped(PersistenceManager.shared.loadDouble(forKey: .soundVolume))
    }

    private init() {
        setupAudioSession()
        loadDefaultSettings()
        preloadSounds([.buttonTap, .correctAnswer, .wrongAnswer, .notification])
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }

    private func loadDefaultSettings() {
        if !PersistenceManager.shared.hasKey(.soundEnabled) {
            PersistenceManager.shared.saveBool(true, forKey: .soundEnabled)
        }
        if !PersistenceManager.shared.hasKey(.musicEnabled) {
            PersistenceManager.shared.saveBool(true, forKey: .musicEnabled)
        }
        if !PersistenceManager.shared.hasKey(.musicVolume) {
            PersistenceManager.shared.saveDouble(0.5, forKey: .musicVolume)
        }
        if !PersistenceManager.shared.hasKey(.soundVolume) {
            PersistenceManager.shared.saveDouble(0.7, forKey: .soundVolume)
        }
    }

    private func clamped(_ volume: Double) -> Float {
        return Float(max(0.0, min(1.0, volume)))
    }

    private func preloadSounds(_ sounds: [SoundEffectType]) {
        for sound in sounds {
            guard soundEffectPlayers[sound.rawValue] == nil,
                  let player = createAudioPlayer(for: sound.rawValue) else { continue }
            player.prepareToPlay()
            soundEffectPlayers[sound.rawValue] = player
        }
    }

    func toggleSound() {
        PersistenceManager.shared.saveBool(!isSoundEnabled, forKey: .soundEnabled)
    }

    func toggleMusic() {
        let newValue = !isMusicEnabled
        PersistenceManager.shared.saveBool(newValue, forKey: .musicEnabled)

        if !newValue {
            stopMusic()
        } else if let currentMusic = currentMusic {
            playMusic(currentMusic)
        }
    }

    func setMusicVolume(_ volume: Double) {
        let clampedVolume = clamped(volume)
        PersistenceManager.shared.saveDouble(Double(clampedVolume), forKey: .musicVolume)
        musicPlayer?.volume = clampedVolume
    }

    func setSoundVolume(_ volume: Double) {
        let clampedVolume = clamped(volume)
        PersistenceManager.shared.saveDouble(Double(clampedVolume), forKey: .soundVolume)
        for (_, player) in soundEffectPlayers {
            player.volume = clampedVolume
        }
    }

    func playSound(_ sound: SoundEffectType, volume: Float? = nil) {
        guard isSoundEnabled else { return }

        if let player = soundEffectPlayers[sound.rawValue], !player.isPlaying {
            player.volume = volume ?? soundVolume
            player.currentTime = 0
            player.play()
            return
        }

        if let player = createAudioPlayer(for: sound.rawValue) {
            player.volume = volume ?? soundVolume
            player.play()
            soundEffectPlayers[sound.rawValue] = player
        }
    }

    func playMusic(_ music: MusicType, fadeIn: Bool = true, loop: Bool = true) {
        guard isMusicEnabled else { return }
        currentMusic = music

        if musicPlayer?.isPlaying == true {
            if fadeIn {
                fadeOutMusic { [weak self] in self?.startNewMusic(music, loop: loop) }
            } else {
                musicPlayer?.stop()
                startNewMusic(music, loop: loop)
            }
        } else {
            startNewMusic(music, loop: loop)
        }
    }

    func stopMusic(fadeOut: Bool = true) {
        if fadeOut {
            fadeOutMusic()
        } else {
            musicPlayer?.stop()
        }
    }

    func pauseMusic() {
        musicPlayer?.pause()
    }

    func resumeMusic() {
        guard isMusicEnabled else { return }
        musicPlayer?.play()
    }

    private func createAudioPlayer(for filename: String, fileExtension: String = "mp3") -> AVAudioPlayer? {
        func loadAudio(named name: String) -> AVAudioPlayer? {
            guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else { return nil }
            return try? AVAudioPlayer(contentsOf: url)
        }

        if let player = loadAudio(named: filename) {
            return player
        }

        if filename != SoundEffectType.fallback.rawValue,
           let fallbackPlayer = loadAudio(named: SoundEffectType.fallback.rawValue)
        {
            print("Using fallback audio for: \(filename)")
            return fallbackPlayer
        }

        print("⚠️ Audio file not found: \(filename).\(fileExtension)")
        return nil
    }

    private func startNewMusic(_ music: MusicType, loop: Bool) {
        if let player = createAudioPlayer(for: music.rawValue) {
            player.volume = musicVolume
            player.numberOfLoops = loop ? -1 : 0
            player.play()
            musicPlayer = player
        }
    }

    private func fadeOutMusic(duration: TimeInterval = 1.0, steps: Int = 10, completion: (() -> Void)? = nil) {
        guard let player = musicPlayer, player.isPlaying else {
            completion?()
            return
        }

        let originalVolume = player.volume
        let stepTime = duration / Double(steps)

        for step in 0 ..< steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepTime * Double(step)) {
                player.volume = originalVolume * Float(steps - step) / Float(steps)
                if step == steps - 1 {
                    player.stop()
                    player.volume = originalVolume
                    completion?()
                }
            }
        }
    }
}

// MARK: - PersistenceManager Extension

extension PersistenceManager {
    func hasKey(_ key: StorageKey) -> Bool {
        UserDefaults.standard.object(forKey: key.key) != nil
    }

    func loadDouble(forKey key: StorageKey) -> Double {
        UserDefaults.standard.double(forKey: key.key)
    }

    func saveDouble(_ value: Double, forKey key: StorageKey) {
        UserDefaults.standard.set(value, forKey: key.key)
    }
}
