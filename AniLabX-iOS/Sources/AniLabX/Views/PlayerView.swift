import SwiftUI
import AVKit

struct PlayerView: View {
    @StateObject var viewModel: PlayerViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Видеоплеер
            VideoPlayer(player: PlayerService.shared.player)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    viewModel.toggleControls()
                }
            
            // Элементы управления
            if viewModel.showControls {
                controlsOverlay
            }
            
            // Индикатор загрузки
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
            }
        }
        .alert(item: Binding(
            get: { viewModel.error.map { ErrorWrapper(error: $0) } },
            set: { _ in viewModel.error = nil }
        )) { wrapper in
            Alert(
                title: Text("Ошибка воспроизведения"),
                message: Text(wrapper.error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
    
    private var controlsOverlay: some View {
        VStack {
            // Верхняя панель
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.down")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(viewModel.content.title)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                Menu {
                    Button(action: {
                        viewModel.selectedQuality = "1080p"
                    }) {
                        Text("1080p")
                    }
                    Button(action: {
                        viewModel.selectedQuality = "720p"
                    }) {
                        Text("720p")
                    }
                    Button(action: {
                        viewModel.selectedQuality = "480p"
                    }) {
                        Text("480p")
                    }
                } label: {
                    Text(viewModel.selectedQuality)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            Spacer()
            
            // Центральные кнопки управления
            HStack(spacing: 40) {
                Button(action: viewModel.skipBackward) {
                    Image(systemName: "gobackward.10")
                        .font(.title)
                }
                
                Button(action: viewModel.togglePlayPause) {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                }
                
                Button(action: viewModel.skipForward) {
                    Image(systemName: "goforward.10")
                        .font(.title)
                }
            }
            .foregroundColor(.white)
            
            Spacer()
            
            // Нижняя панель
            VStack(spacing: 8) {
                // Прогресс-бар
                Slider(
                    value: Binding(
                        get: { viewModel.currentTime },
                        set: { viewModel.seek(to: $0) }
                    ),
                    in: 0...viewModel.duration
                )
                .accentColor(.white)
                
                HStack {
                    Text(formatTime(viewModel.currentTime))
                    Spacer()
                    Text(formatTime(viewModel.duration))
                }
                .font(.caption)
                .foregroundColor(.white)
                
                // Кнопки дополнительных функций
                HStack {
                    Menu {
                        Button(action: { viewModel.setPlaybackRate(0.5) }) {
                            Text("0.5x")
                        }
                        Button(action: { viewModel.setPlaybackRate(1.0) }) {
                            Text("1.0x")
                        }
                        Button(action: { viewModel.setPlaybackRate(1.5) }) {
                            Text("1.5x")
                        }
                        Button(action: { viewModel.setPlaybackRate(2.0) }) {
                            Text("2.0x")
                        }
                    } label: {
                        Image(systemName: "speedometer")
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Toggle subtitles
                    }) {
                        Image(systemName: "captions.bubble")
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Toggle fullscreen
                    }) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                    }
                }
                .foregroundColor(.white)
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    private func formatTime(_ time: Double) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
