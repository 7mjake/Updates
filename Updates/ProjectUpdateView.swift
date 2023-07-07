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
    @State var isAddProjectViewPresented = false
    @FocusState var isNotesFocused: Bool
    @State var isGlobalTaskFocused: Bool
    
    @FetchRequest(entity: Project.entity(), sortDescriptors: [])
    private var projects: FetchedResults<Project>
    
    var body: some View {
        if projects.count >= 1 {
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
                        
                        
                        NotesView(isNotesFocused: _isNotesFocused)
                        
                        //
                        
                        
                    }
                    .padding(32)
                    
                }
                
                
                
                Divider()
                HStack {
                    //                Button("See all \(selectedProject.project?.name ?? "Project") updates") {
                    //                    //Create a new task
                    //                }
                    //                .buttonStyle(.link)
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
        } else {
            
            // Empty State View
            
            Spacer()
            VStack {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .shadow(radius: 16)
                    .frame(width: 150.0)
                Spacer()
                    .frame(height: 32)
                Text("Welcome to MyUpdates")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Get started by adding a project")
                Spacer()
                    .frame(height: 32)
                Button("Add a project") {
                    isAddProjectViewPresented = true
                }
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $isAddProjectViewPresented) {
                    AddProjectView()
                        .frame(minWidth: 300.0, minHeight: 300.0)
                }
            }
            Spacer()
        }
        
    }
}


//struct ProjectUpdateView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProjectUpdateView()
//    }
//}
