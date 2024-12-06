import Foundation
import Combine
import AVKit

class PlayerViewModel: ObservableObject {
    @Published var episode: Episode
    @Published var content: MediaContent
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showControls = true
    @Published var selectedQuality: String = "720p"
    
    private let playerService = PlayerService.shared
    private let storageService = StorageService.shared
    private var cancellables = Set<AnyCancellable>()
    private var controlsTimer: Timer?
    
    init(content: MediaContent, episode: Episode) {
        self.content = content
        self.episode = episode
        
        // Подписываемся на обновления плеера
        playerService.$isPlaying
            .assign(to: &$isPlaying)
        
        playerService.$currentTime
            .sink { [weak self] time in
                self?.currentTime = time
                // Сохраняем прогресс каждые 5 секунд
                if Int(time) % 5 == 0 {
                    self?.saveProgress()
                }
            }
            .store(in: &cancellables)
        
        playerService.$duration
            .assign(to: &$duration)
        
        playerService.$isLoading
            .assign(to: &$isLoading)
        
        playerService.$error
            .assign(to: &$error)
        
        // Загружаем сохраненный прогресс
        currentTime = storageService.getProgress(for: content, episode: episode, chapter: nil)
        
        // Подготавливаем плеер
        if let url = URL(string: episode.streamingURL) {
            playerService.preparePlayer(url: url)
            if currentTime > 0 {
                playerService.seek(to: currentTime)
            }
        }
    }
    
    func togglePlayPause() {
        if isPlaying {
            playerService.pause()
        } else {
            playerService.play()
        }
        showControls = true
        resetControlsTimer()
    }
    
    func seek(to time: Double) {
        playerService.seek(to: time)
        showControls = true
        resetControlsTimer()
    }
    
    func skipForward() {
        seek(to: currentTime + 10)
    }
    
    func skipBackward() {
        seek(to: currentTime - 10)
    }
    
    func setPlaybackRate(_ rate: Float) {
        playerService.setPlaybackRate(rate)
    }
    
    func toggleControls() {
        showControls.toggle()
        if showControls {
            resetControlsTimer()
        }
    }
    
    private func resetControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            withAnimation {
                self?.showControls = false
            }
        }
    }
    
    private func saveProgress() {
        let progress = currentTime / duration
        storageService.saveProgress(for: content, episode: episode, chapter: nil, progress: progress)
    }
    
    func cleanup() {
        playerService.cleanup()
        cancellables.removeAll()
        controlsTimer?.invalidate()
        controlsTimer = nil
    }
}
