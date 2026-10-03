import SwiftUI
import CoreData

struct EntryDetailView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var entry: CraftEntry

    @State private var showingEdit = false

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 12) {

                if let data = entry.photo, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Text(entry.title ?? "Untitled")
                    .font(.largeTitle)
                    .bold()

                Text(entry.craftType ?? "")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                if let location = entry.location, !location.isEmpty {
                    Label(location, systemImage: "mappin.and.ellipse")
                        .foregroundStyle(.secondary)
                }

                if let date = entry.date {
                    Text(date, style: .date)
                }

                if let notes = entry.notes, !notes.isEmpty {
                    Divider()
                    Text(notes)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditEntryView(entry: entry)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}

#Preview {

    let context = PersistenceController.preview.container.viewContext
    let entry = CraftEntry(context: context)
    entry.id = UUID()
    entry.title = "Sample craft"
    entry.craftType = "Thagzo"
    entry.location = "Haa"
    entry.notes = "A sample note."
    entry.date = Date()

    return NavigationStack {
        EntryDetailView(entry: entry)
    }
    .environment(\.managedObjectContext, context)
}
