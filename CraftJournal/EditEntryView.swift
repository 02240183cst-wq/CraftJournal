import SwiftUI
import CoreData

struct EditEntryView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var entry: CraftEntry

    @State private var title: String
    @State private var craftType: String
    @State private var location: String
    @State private var notes: String
    @State private var date: Date

    init(entry: CraftEntry) {
        self.entry = entry
        _title = State(initialValue: entry.title ?? "")
        _craftType = State(initialValue: entry.craftType ?? crafts[0])
        _location = State(initialValue: entry.location ?? "")
        _notes = State(initialValue: entry.notes ?? "")
        _date = State(initialValue: entry.date ?? Date())
    }

    var body: some View {

        NavigationStack {

            Form {

                TextField("Title", text: $title)

                Picker("Craft", selection: $craftType) {
                    ForEach(crafts, id: \.self) { craft in
                        Text(craft)
                    }
                }

                TextField("Location found", text: $location)

                DatePicker("Date", selection: $date, displayedComponents: .date)

                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveChanges() }
                        .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveChanges() {

        entry.title = title
        entry.craftType = craftType
        entry.location = location
        entry.notes = notes
        entry.date = date

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Could not save changes: \(error)")
        }
    }
}
