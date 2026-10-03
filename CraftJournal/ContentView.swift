import SwiftUI
import CoreData

struct ContentView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \CraftEntry.date,
                ascending: false
            )
        ],
        animation: .default
    )
    private var entries: FetchedResults<CraftEntry>

    @State private var showingAddEntry = false
    @State private var searchText = ""

    var body: some View {

        NavigationStack {

            List {

                Section {

                    ForEach(entries) { entry in

                        NavigationLink {

                            EntryDetailView(entry: entry)

                        } label: {

                            EntryRow(entry: entry)
                        }
                    }

                    .onDelete(perform: deleteEntries)

                } header: {

                    if !entries.isEmpty {
                        Text(entries.count == 1 ? "1 entry" : "\(entries.count) entries")
                    }
                }
            }

            .overlay {

                if entries.isEmpty {

                    if searchText.isEmpty {

                        ContentUnavailableView(
                            "No Entries Yet",
                            systemImage: "camera",
                            description: Text("Tap + to photograph your first craft item.")
                        )

                    } else {

                        ContentUnavailableView.search(text: searchText)
                    }
                }
            }

            .navigationTitle("Craft Journal")

            .searchable(text: $searchText, prompt: "Search by title")

            .onChange(of: searchText) { _, newValue in
                if newValue.isEmpty {
                    entries.nsPredicate = nil
                } else {
                    entries.nsPredicate = NSPredicate(
                        format: "title CONTAINS[cd] %@",
                        newValue
                    )
                }
            }

            .toolbar {

                ToolbarItem(placement: .topBarTrailing) {

                    Button {

                        showingAddEntry = true

                    } label: {

                        Label("Add", systemImage: "plus")
                    }
                }
            }

            .sheet(isPresented: $showingAddEntry) {

                AddEntryView()
                    .environment(
                        \.managedObjectContext,
                        viewContext
                    )
            }
        }
    }

    private func deleteEntries(offsets: IndexSet) {

        offsets
            .map { entries[$0] }
            .forEach(viewContext.delete)

        do {

            try viewContext.save()

        } catch {

            print("Could not delete: \(error)")
        }
    }
}

struct EntryRow: View {

    @ObservedObject var entry: CraftEntry

    var body: some View {

        HStack {

            if let data = entry.photo, let uiImage = UIImage(data: data) {

                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

            } else {

                Image(systemName: "photo")
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading) {

                Text(entry.title ?? "Untitled")
                    .font(.headline)

                Text(entry.craftType ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let location = entry.location, !location.isEmpty {
                    Text(location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {

    ContentView()
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
}
