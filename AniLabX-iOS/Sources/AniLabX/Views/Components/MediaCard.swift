import SwiftUI
import SDWebImageSwiftUI

struct MediaCard: View {
    let content: MediaContent
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WebImage(url: URL(string: content.coverImage))
                .resizable()
                .placeholder {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.2))
                }
                .indicator(.activity)
                .transition(.fade(duration: 0.5))
                .scaledToFill()
                .frame(width: width, height: height * 0.7)
                .clipped()
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(content.title)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(2)
                
                HStack {
                    Text(content.type.rawValue.capitalized)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if content.rating > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", content.rating))
                        }
                        .font(.system(size: 12))
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(width: width, height: height)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
