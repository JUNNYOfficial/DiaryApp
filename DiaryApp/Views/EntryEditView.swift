import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct EntryEditView: View {
    @Environment(\.theme) var theme
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var mood: String = "neutral"
    @State private var selectedImage: UIImage?
    @State private var selectedFileData: Data?
    @State private var selectedFileName: String?
    @State private var showingImagePicker = false
    @State private var showingFilePicker = false
    @State private var showingCamera = false
    @State private var showingAttachmentMenu = false
    
    let moods = [
        ("开心", "face.smiling", "happy"),
        ("平静", "face.relaxed", "calm"),
        ("难过", "cloud.rain", "sad"),
        ("生气", "flame", "angry"),
        ("兴奋", "bolt", "excited"),
        ("疲惫", "zzz", "tired")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundWhite
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("标题")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(theme.textSecondary)
                            
                            TextField("输入标题...", text: $title)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(theme.textPrimary)
                        }
                        .padding(14)
                        .background(theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        
                        // Mood
                        VStack(alignment: .leading, spacing: 12) {
                            Text("心情")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(theme.textSecondary)
                            
                            HStack(spacing: 16) {
                                ForEach(moods, id: \.2) { name, icon, key in
                                    MoodButton(
                                        name: name,
                                        icon: icon,
                                        isSelected: mood == key,
                                        action: { mood = key }
                                    )
                                }
                            }
                        }
                        .padding(14)
                        .background(theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        
                        // Content
                        VStack(alignment: .leading, spacing: 8) {
                            Text("内容")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(theme.textSecondary)
                            
                            TextEditor(text: $content)
                                .font(.system(size: 16))
                                .foregroundStyle(theme.textPrimary)
                                .frame(minHeight: 200)
                                .scrollContentBackground(.hidden)
                        }
                        .padding(14)
                        .background(theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        
                        // Attachments
                        if let image = selectedImage {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("附件")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(theme.textSecondary)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        selectedImage = nil
                                        selectedFileData = nil
                                        selectedFileName = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(theme.textSecondary)
                                    }
                                }
                                
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit
                                    .frame(maxHeight: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .padding(14)
                            .background(theme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        } else if let fileName = selectedFileName {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("附件")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(theme.textSecondary)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        selectedImage = nil
                                        selectedFileData = nil
                                        selectedFileName = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(theme.textSecondary)
                                    }
                                }
                                
                                HStack(spacing: 12) {
                                    Image(systemName: AttachmentService.iconForFileType(fileName))
                                        .font(.system(size: 28))
                                        .foregroundStyle(theme.primaryBlue)
                                    
                                    Text(fileName)
                                        .font(.system(size: 14))
                                        .foregroundStyle(theme.textPrimary)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                }
                                .padding(12)
                                .background(theme.lightBlue)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .padding(14)
                            .background(theme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        
                        // Add attachment button
                        Button(action: { showingAttachmentMenu = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "paperclip")
                                Text("添加照片或文件")
                            }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(theme.primaryBlue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(theme.lightBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("新日记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                        .foregroundStyle(theme.textSecondary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") { saveEntry() }
                        .foregroundStyle(theme.primaryBlue)
                        .font(.system(size: 16, weight: .semibold))
                        .disabled(title.isEmpty && content.isEmpty)
                }
            }
            .confirmationDialog("添加附件", isPresented: $showingAttachmentMenu) {
                Button("拍照") { showingCamera = true }
                Button("从相册选择") { showingImagePicker = true }
                Button("选择文件") { showingFilePicker = true }
                Button("取消", role: .cancel) { }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showingCamera) {
                ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showingFilePicker) {
                DocumentPicker(selectedData: $selectedFileData, selectedFileName: $selectedFileName)
            }
        }
    }
    
    private func saveEntry() {
        let entry = DiaryEntry(context: viewContext)
        entry.title = title
        entry.content = content
        entry.mood = mood
        entry.updatedAt = Date()
        
        if let image = selectedImage {
            entry.attachmentData = AttachmentService.compressImage(image)
            entry.attachmentType = AttachmentType.image.rawValue
        } else if let fileData = selectedFileData {
            entry.attachmentData = fileData
            entry.attachmentType = AttachmentType.file.rawValue
            entry.attachmentName = selectedFileName
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to save entry: \(error.localizedDescription)")
        }
    }
}

struct MoodButton: View {
    @Environment(\.theme) var theme
    let name: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? theme.primaryBlue : theme.textSecondary)
                
                Text(name)
                    .font(.system(size: 11))
                    .foregroundStyle(isSelected ? theme.primaryBlue : theme.textSecondary)
            }
            .frame(width: 52, height: 56)
            .background(isSelected ? theme.lightBlue : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
