//
//  ProjectUpdateView.swift
//  Updates
//
//  Created by Jake Martin on 6/8/23.
//

import SwiftUI

struct ProjectUpdateView: View {
    
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    @EnvironmentObject var selectedProject: SelectedProject
    @EnvironmentObject var selectedDate: SelectedDate
    @FocusState var isNotesFocused: Bool
    @State var isGlobalTaskFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(selectedProject.project?.name ?? "No project selected")
                        .font(.system(size: 48, weight: .bold))
                    Spacer(minLength: 24)
                    Text("What did you work on today?")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Spacer(minLength: 8)
                    
                    TaskListView(isGlobalTaskFocused: $isGlobalTaskFocused)
                        
                    Spacer(minLength: 24)
                    
                    Text("Notes")
                        .font(.title2)
                        .fontWeight(.medium)
                    Spacer(minLength: 8)
                    
//                    if fetchExistingNote(for: selectedProject) != nil {
//                        Text("A note exists!")
//                            .foregroundColor(Color.green)
//                        
//                    }
                    
                    
                    NotesView(isNotesFocused: _isNotesFocused)
                    
                   //
                        
                    
                }
                .padding(32)
            }
            
            
            
            Divider()
            HStack {
                Button("See all \(selectedProject.project?.name ?? "Project") updates") {
                    //Create a new task
                }
                .buttonStyle(.link)
                Spacer()
                if selectedProject.project?.status != 2 {
                    Button("Mark \(selectedProject.project?.name ?? "Project") as **Done**") {
                        selectedProject.project?.status = 2
                        do {
                            try context.save()
                        } catch {
                            // handle the Core Data error
                            print("Failed to delete task: \(error)")
                        }
                    }
                    .buttonStyle(.link)
                }
            }
            .padding(EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32))
        }
        .onTapGesture {
            isNotesFocused = false
            isGlobalTaskFocused = false
        }
    }
}


//struct ProjectUpdateView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProjectUpdateView()
//    }
//}
