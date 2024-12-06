import SwiftUI
import SDWebImageSwiftUI

struct MediaDetailView: View {
    let content: MediaContent
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                WebImage(url: URL(string: content.coverImage))
                    .resizable()
                    .placeholder {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                    }
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFill()
                    .frame(height: 300)
                    .clipped()
                
                // Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(content.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let originalTitle = content.originalTitle {
                        Text(originalTitle)
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text(content.type.rawValue.capitalized)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                        
                        Text(content.status)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(8)
                        
                        if content.rating > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", content.rating))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    .font(.subheadline)
                    
                    Text(content.description)
                        .padding(.top, 8)
                    
                    // Genres
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(content.genres, id: \.self) { genre in
                                Text(genre)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
                
                // Episodes/Chapters
                if content.type == .anime || content.type == .drama {
                    if let episodes = content.episodes {
                        Text("Эпизоды")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(episodes) { episode in
                            EpisodeRow(episode: episode)
                        }
                    }
                } else if let chapters = content.chapters {
                    Text("Главы")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ForEach(chapters) { chapter in
                        ChapterRow(chapter: chapter)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Toggle favorite
                }) {
                    Image(systemName: "heart")
                }
            }
        }
    }
}

struct EpisodeRow: View {
    let episode: Episode
    
    var body: some View {
        Button(action: {
            // Play episode
        }) {
            HStack {
                Text("Эпизод \(episode.number)")
                    .fontWeight(.medium)
                
                Spacer()
                
                if episode.watchProgress > 0 {
                    Text("\(Int(episode.watchProgress * 100))%")
                        .foregroundColor(.gray)
                }
                
                Image(systemName: "play.circle.fill")
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ChapterRow: View {
    let chapter: Chapter
    
    var body: some View {
        Button(action: {
            // Open chapter
        }) {
            HStack {
                Text("Глава \(chapter.number)")
                    .fontWeight(.medium)
                
                Spacer()
                
                if chapter.readProgress > 0 {
                    Text("\(Int(chapter.readProgress * 100))%")
                        .foregroundColor(.gray)
                }
                
                Image(systemName: "book")
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
