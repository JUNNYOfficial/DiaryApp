import Foundation
import CoreData

@objc(DiaryEntry)
public class DiaryEntry: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var content: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var mood: String
    @NSManaged public var weather: String
    @NSManaged public var location: String
    @NSManaged public var attachmentData: Data?
    @NSManaged public var attachmentType: String?
    @NSManaged public var attachmentName: String?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        createdAt = Date()
        updatedAt = Date()
        title = ""
        content = ""
        mood = "neutral"
        weather = ""
        location = ""
    }
}

extension DiaryEntry {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DiaryEntry> {
        return NSFetchRequest<DiaryEntry>(entityName: "DiaryEntry")
    }
    
    var hasAttachment: Bool {
        return attachmentData != nil
    }
    
    var attachmentImage: UIImage? {
        guard let data = attachmentData else { return nil }
        return UIImage(data: data)
    }
}
