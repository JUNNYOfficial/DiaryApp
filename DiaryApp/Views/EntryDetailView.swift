import SwiftUI

struct EntryDetailView: View {
    @Environment(\.theme) var theme
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let entry: DiaryEntry
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundWhite
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(entry.title.isEmpty ? "无标题" : entry.title)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(theme.textPrimary)
                                
                                Spacer()
                                
                                MoodBadge(mood: entry.mood)
                            }
                            
                            Text(entry.createdAt, style: .date)
                                .font(.system(size: 14))
                                .foregroundStyle(theme.textSecondary)
                            + Text(" ")
                            + Text(entry.createdAt, style: .time)
                                .font(.system(size: 14))
                                .foregroundStyle(theme.textSecondary)
                        }
                        .padding(16)
                        .background(theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        
                        // Content
                        VStack(alignment: .leading, spacing: 12) {
                            Text(entry.content)
                                .font(.system(size: 16))
                                .foregroundStyle(theme.textPrimary)
                                .lineSpacing(6)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        
                        // Attachment
                        if let image = entry.attachmentImage {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("照片")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(theme.textSecondary)
                                
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit
                                    .frame(maxHeight: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(16)
                            .background(theme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        } else if let fileName = entry.attachmentName {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("附件")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(theme.textSecondary)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: AttachmentService.iconForFileType(fileName))
                                        .font(.system(size: 32))
                                        .foregroundStyle(theme.primaryBlue)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(fileName)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(theme.textPrimary)
                                        
                                        if let data = entry.attachmentData {
                                            Text(formatFileSize(data.count))
                                                .font(.caption)
                                                .foregroundStyle(theme.textSecondary)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(14)
                                .background(theme.lightBlue)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(16)
                            .background(theme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("日记详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                            .foregroundStyle(theme.primaryBlue)
                    }
                }
            }
            .alert("确认删除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    deleteEntry()
                }
            } message: {
                Text("确定要删除这篇日记吗？此操作无法撤销。")
            }
        }
    }
    
    private func deleteEntry() {
        viewContext.delete(entry)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to delete entry: \(error.localizedDescription)")
        }
    }
    
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

struct MoodBadge: View {
    @Environment(\.theme) var theme
    let mood: String
    
    var moodInfo: (String, String, Color) {
        switch mood {
        case "happy": return ("开心", "face.smiling", Color.green)
        case "calm": return ("平静", "face.relaxed", theme.primaryBlue)
        case "sad": return ("难过", "cloud.rain", Color.gray)
        case "angry": return ("生气", "flame", Color.red)
        case "excited": return ("兴奋", "bolt", Color.orange)
        case "tired": return ("疲惫", "zzz", Color.purple)
        default: return ("平静", "face.relaxed", theme.primaryBlue)
        }
    }
    
    var body: some View {
        let info = moodInfo
        HStack(spacing: 4) {
            Image(systemName: info.1)
                .font(.caption)
            Text(info.0)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundStyle(info.2)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(info.2.opacity(0.12))
        .clipShape(Capsule())
    }
}
