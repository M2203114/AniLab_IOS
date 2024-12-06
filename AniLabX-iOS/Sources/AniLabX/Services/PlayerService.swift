import Foundation
import AVKit
import Combine

class PlayerService: ObservableObject {
    static let shared = PlayerService()
    
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isLoading = false
    @Published var error: Error?
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func preparePlayer(url: URL) {
        isLoading = true
        error = nil
        
        // Создаем новый плеер с указанным URL
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        // Наблюдаем за статусом загрузки
        playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .readyToPlay:
                    self?.isLoading = false
                    self?.duration = playerItem.duration.seconds
                    self?.setupTimeObserver()
                case .failed:
                    self?.isLoading = false
                    self?.error = playerItem.error
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // Наблюдаем за буферизацией
        playerItem.publisher(for: \.isPlaybackBufferEmpty)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                self?.isLoading = isEmpty
            }
            .store(in: &cancellables)
    }
    
    private func setupTimeObserver() {
        // Обновляем текущее время каждые 0.5 секунды
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
    }
    
    func play() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime)
    }
    
    func setPlaybackRate(_ rate: Float) {
        player?.rate = rate
    }
    
    func cleanup() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        player = nil
        timeObserver = nil
        cancellables.removeAll()
    }
}
