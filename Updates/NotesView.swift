//
//  NotesView.swift
//  Updates
//
//  Created by Jake Martin on 6/11/23.
//

import SwiftUI

struct NotesView: View {
    
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    @EnvironmentObject var selectedProject: SelectedProject
    @EnvironmentObject var selectedDate: SelectedDate
    @State private var currentNote: Note?
    @State private var noteContent = ""
    @FocusState var isNotesFocused: Bool
    
    func fetchExistingNote(for project: SelectedProject) -> Note? {
        guard let project = selectedProject.project else {
                print("No project selected")
                return nil
            }
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        
        // Get the start of the day for the date argument
        let startOfDay = Calendar.current.startOfDay(for: selectedDate.date)
        
        // This predicate assumes 'date' is a Date type and 'task' is a relationship to the Note entity
        let predicate = NSPredicate(format: "date == %@ AND project == %@", startOfDay as NSDate, project)
        
        fetchRequest.predicate = predicate
        
        do {
            let notes = try context.fetch(fetchRequest)
            return notes.first
        } catch {
            return nil
        }
    }
    
    func createNewNote(for project: SelectedProject) -> Note {
        // If no Note was found or an error occurred, create a new Note
        let newNote = Note(context: context)
        newNote.date = Calendar.current.startOfDay(for: selectedDate.date)
        newNote.project = selectedProject.project
        
        do {
            try context.save()
        } catch {
            print("Failed to save new Note: \(error)")
        }
        print("new note created for  \(String(describing: newNote.date))")
        return newNote
    }
    
    func deleteEmptyNotes() {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()

        // This predicate finds Notes where content is nil or an empty string
        let predicate = NSPredicate(format: "content == nil OR content == ''")
        fetchRequest.predicate = predicate
        
        // NSBatchDeleteRequest

        do {
            let emptyNotes = try context.fetch(fetchRequest)
            for note in emptyNotes {
                if let date = note.date {
                    print("Deleting note from date: \(date)")
                } else {
                    print("Deleting note with no date")
                }
                context.delete(note)
            }

            try context.save()
        } catch {
            print("Failed to delete empty Notes: \(error)")
        }
    }


    
    var body: some View {
        TextField("Any other updates", text: $noteContent, axis: .vertical)
            .focused($isNotesFocused)
            .onAppear {
                currentNote = fetchExistingNote(for: selectedProject)
                noteContent = currentNote?.content ?? ""
                print("on appear")
            }
            .onChange(of: noteContent) { newValue in
                let hasCurrentNote = currentNote != nil
                let hasContent = !noteContent.isEmpty
                let noteContentEmpty = noteContent.isEmpty
                let shouldDeleteNote = noteContentEmpty && hasCurrentNote
                let shouldUpdateExistingNote = hasCurrentNote && hasContent
                let shouldCreateNote = !hasCurrentNote && hasContent
                
                if shouldDeleteNote,
                   let currentNote {
                    context.delete(currentNote)
                    self.currentNote = nil
                } else if shouldUpdateExistingNote {
                    currentNote?.content = noteContent
                } else if shouldCreateNote {
                    let note = createNewNote(for: selectedProject)
                    note.content = noteContent
                    currentNote = note
                }
                
                do {
                    print("note saved")
                    try context.save()
                } catch {
                    print("Failed to save Note content: \(error)")
                }
            }
            .onChange(of: selectedDate.date) { newValue in
                isNotesFocused = false
                
                // Show the current day's update
                currentNote = fetchExistingNote(for: selectedProject) ?? nil
                noteContent = currentNote?.content ?? ""
                //print("date changed")
            }
            .onChange(of: selectedProject.project) { newValue in
                isNotesFocused = false
                
                // Show the current day's update
                currentNote = fetchExistingNote(for: selectedProject) ?? nil
                noteContent = currentNote?.content ?? ""
                //print("project changed")
            }
            .lineLimit(4...)
        
//        Button("Delete empty notes", action: {
//            deleteEmptyNotes()
//        })
    }
    
    
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        NotesView()
    }
}

