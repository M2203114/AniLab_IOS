import Foundation
import CoreData

class StorageService {
    static let shared = StorageService()
    
    private let container: NSPersistentContainer
    private let containerName = "AniLabX"
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Error loading Core Data: \(error)")
            }
        }
    }
    
    // MARK: - Favorites
    
    func addToFavorites(_ content: MediaContent) {
        let favorite = Favorite(context: viewContext)
        favorite.id = content.id
        favorite.title = content.title
        favorite.type = content.type.rawValue
        favorite.dateAdded = Date()
        
        save()
    }
    
    func removeFromFavorites(_ content: MediaContent) {
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", content.id)
        
        if let favorite = try? viewContext.fetch(fetchRequest).first {
            viewContext.delete(favorite)
            save()
        }
    }
    
    func isFavorite(_ content: MediaContent) -> Bool {
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", content.id)
        
        return (try? viewContext.count(for: fetchRequest)) ?? 0 > 0
    }
    
    // MARK: - Watch/Read Progress
    
    func saveProgress(for content: MediaContent, episode: Episode?, chapter: Chapter?, progress: Double) {
        let progress = Progress(context: viewContext)
        progress.contentId = content.id
        progress.episodeId = episode?.id
        progress.chapterId = chapter?.id
        progress.progress = progress
        progress.lastUpdated = Date()
        
        save()
    }
    
    func getProgress(for content: MediaContent, episode: Episode?, chapter: Chapter?) -> Double {
        let fetchRequest: NSFetchRequest<Progress> = Progress.fetchRequest()
        var predicates: [NSPredicate] = [NSPredicate(format: "contentId == %@", content.id)]
        
        if let episode = episode {
            predicates.append(NSPredicate(format: "episodeId == %@", episode.id))
        }
        if let chapter = chapter {
            predicates.append(NSPredicate(format: "chapterId == %@", chapter.id))
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        return (try? viewContext.fetch(fetchRequest).first)?.progress ?? 0
    }
    
    // MARK: - Utilities
    
    private func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
