import SwiftUI

struct ContentView: View {
    @Environment(\.theme) var theme
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DiaryEntry.createdAt, ascending: false)],
        animation: .default
    ) private var entries: FetchedResults<DiaryEntry>
    
    @State private var showingNewEntry = false
    @State private var selectedEntry: DiaryEntry?
    @State private var searchText = ""
    @State private var showingProfile = false
    
    var filteredEntries: [DiaryEntry] {
        if searchText.isEmpty {
            return Array(entries)
        }
        return entries.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var groupedEntries: [Date: [DiaryEntry]] {
        Dictionary(grouping: filteredEntries) { entry in
            Calendar.current.startOfDay(for: entry.createdAt)
        }
    }
    
    var sortedDates: [Date] {
        groupedEntries.keys.sorted(by: >)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundWhite
                    .ignoresSafeArea()
                
                if entries.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                            ForEach(sortedDates, id: \.self) { date in
                                Section {
                                    ForEach(groupedEntries[date] ?? []) { entry in
                                        EntryCard(entry: entry)
                                            .onTapGesture {
                                                selectedEntry = entry
                                            }
                                    }
                                } header: {
                                    DateHeader(date: date)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("我的日记")
            .searchable(text: $searchText, prompt: "搜索日记...")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingProfile = true }) {
                        Image(systemName: "person.circle")
                            .font(.title2)
                            .foregroundStyle(theme.primaryBlue)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingNewEntry = true }) {
                        Image(systemName: "square.and.pencil")
                            .font(.title2)
                            .foregroundStyle(theme.primaryBlue)
                    }
                }
            }
            .sheet(isPresented: $showingNewEntry) {
                EntryEditView()
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(item: $selectedEntry) { entry in
                EntryDetailView(entry: entry)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
        }
    }
}

struct DateHeader: View {
    @Environment(\.theme) var theme
    let date: Date
    
    var body: some View {
        HStack {
            Text(date, style: .date)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(theme.primaryBlue)
            
            Spacer()
        }
        .padding(.vertical, 6)
        .background(theme.backgroundWhite.opacity(0.95))
    }
}

struct EntryCard: View {
    @Environment(\.theme) var theme
    let entry: DiaryEntry
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(entry.title.isEmpty ? "无标题" : entry.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(theme.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if entry.hasAttachment {
                        Image(systemName: entry.attachmentType == AttachmentType.image.rawValue ? "photo" : "doc")
                            .font(.caption)
                            .foregroundStyle(theme.primaryBlue)
                    }
                }
                
                Text(entry.content)
                    .font(.system(size: 14))
                    .foregroundStyle(theme.textSecondary)
                    .lineLimit(2)
                
                Text(entry.createdAt, style: .time)
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary.opacity(0.7))
            }
            
            if let image = entry.attachmentImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(14)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

struct EmptyStateView: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 70))
                .foregroundStyle(theme.lightBlue)
            
            Text("还没有日记")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(theme.textPrimary)
            
            Text("点击右上角按钮开始记录您的第一篇日记")
                .font(.system(size: 15))
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
