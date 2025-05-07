import AVFoundation
import Foundation
import SwiftUI

// MARK: - Audio Types

enum SoundEffectType: String {
    case levelUp1 = "level-up-1"
    case levelUp2 = "level-up-2"
    case levelUp3 = "level-up-3"
    case levelUp4 = "level-up-4"
    case badge = "badge"
    case discovery = "discovery"
    case incorrect = "incorrect"
    case correct = "correct"
    case button0 = "button_0"
    case button1 = "button_1"
    case button2 = "button_2"
    case button3 = "button_3"
    case button4 = "button_4"
    case button5 = "button_5"
    case fallback
}

enum MusicType: String {
    case background1 = "background_1"
    case background2 = "background_2"
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
        preloadSounds([.levelUp1, .badge, .incorrect, .correct])
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
        func loadAudio(named name: String, extensions: [String]) -> AVAudioPlayer? {
            for ext in extensions {
                if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                    return try? AVAudioPlayer(contentsOf: url)
                }
            }
            return nil
        }
        let extensions = ["mp3", "wav"]
        if let player = loadAudio(named: filename, extensions: extensions) {
            return player
        }
        if filename != SoundEffectType.fallback.rawValue,
           let fallbackPlayer = loadAudio(named: SoundEffectType.fallback.rawValue, extensions: extensions)
        {
            print("Using fallback audio for: \(filename)")
            return fallbackPlayer
        }
        print("⚠️ Audio file not found: \(filename).mp3 or .wav")
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
