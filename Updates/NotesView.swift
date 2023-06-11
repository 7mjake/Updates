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
    @FocusState private var isNotesFocused: Bool
    
    func fetchExistingNote(for project: SelectedProject) -> Note? {
        guard let project = selectedProject.project else {
                print("No project selected")
                return nil
            }
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        
        // Get the start of the day for the date argument
        let startOfDay = Calendar.current.startOfDay(for: selectedDate.date)
        
        // This predicate assumes 'date' is a Date type and 'task' is a relationship to the Note entity
        let predicate = NSPredicate(format: "date == %@ AND project == %@", startOfDay as NSDate, selectedProject.project!)
        
        fetchRequest.predicate = predicate
        
        do {
            let notes = try context.fetch(fetchRequest)
            if let note = notes.first {
                // Return the first note if one exists
                return note
            }
        } catch {
            print("Failed to fetch Note: \(error)")
        }
        
        // If no Note was found or an error occurred, return nil
        
        print("no note found")
        return nil
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
                currentNote = fetchExistingNote(for: selectedProject) ?? nil
                noteContent = currentNote?.content ?? ""
                print("on appear")
            }
            .onChange(of: noteContent) { newValue in
                
                // Update the Update's content whenever updateContent changes
                currentNote?.content = noteContent
                
                if noteContent.isEmpty {
                        // If the new value is empty and a note exists, delete it
                        if let note = currentNote {
                            context.delete(note)
                            print("note deleted")
                        }
                    // Set currentNote to nil because it has been deleted
                    currentNote = nil
                    
                    } else {
                        // If the new value is not empty and no note exists, create a new one
                        if currentNote == nil {
                            currentNote = createNewNote(for: selectedProject)
                            //print("new note created")
                        }
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
        
        Button("Delete empty notes", action: {
            deleteEmptyNotes()
        })
    }
    
    
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        NotesView()
    }
}

