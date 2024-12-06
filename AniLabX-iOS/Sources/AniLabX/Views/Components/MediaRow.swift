import SwiftUI

struct MediaRow: View {
    let title: String
    let content: [MediaContent]
    let onViewAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: onViewAll) {
                    Text("Все")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(content) { item in
                        NavigationLink(destination: MediaDetailView(content: item)) {
                            MediaCard(content: item, width: 160, height: 240)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
