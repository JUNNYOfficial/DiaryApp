import UIKit
import UniformTypeIdentifiers
import PhotosUI

enum AttachmentType: String {
    case image = "image"
    case file = "file"
}

class AttachmentService {
    static func compressImage(_ image: UIImage, maxSize: CGFloat = 1200) -> Data? {
        let scale = min(maxSize / image.size.width, maxSize / image.size.height, 1.0)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage.jpegData(compressionQuality: 0.8)
    }
    
    static func iconForFileType(_ fileName: String) -> String {
        let ext = (fileName as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf": return "doc.text"
        case "doc", "docx": return "doc.text.fill"
        case "xls", "xlsx": return "tablecells"
        case "ppt", "pptx": return "play.rectangle"
        case "txt", "md": return "text.alignleft"
        case "zip", "rar", "7z": return "archivebox"
        default: return "doc"
        }
    }
}
