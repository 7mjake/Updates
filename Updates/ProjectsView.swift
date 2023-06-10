//
//  ProjectsView.swift
//  Updates
//
//  Created by Jake Martin on 6/5/23.
//

import SwiftUI

struct ProjectsView: View {
    
    @EnvironmentObject var selectedProject: SelectedProject
    @State var isAddProjectViewPresented = false
    @State var isEditProjectViewPresented = false
    @State private var selectedEditProject: Project?
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.name)],
        predicate: NSPredicate(format: "status = %d",argumentArray: [ProjectStatus.inProgess.rawValue]))
    var inProgressProjects: FetchedResults<Project>
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.name)],
        predicate: NSPredicate(format: "status = %d",argumentArray: [ProjectStatus.notStarted.rawValue]))
    var notStartedProjects: FetchedResults<Project>
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.name)],
        predicate: NSPredicate(format: "status = %d",argumentArray: [ProjectStatus.done.rawValue]))
    var doneProjects: FetchedResults<Project>
    
    var body: some View {
        VStack {
            List {
                Section("􀧒 In Progress") {
                    ForEach(inProgressProjects) { project in
                        HStack(alignment: .center, spacing: 4) {
                            Text(project.name ?? "")
                                .font(.title2)
                                
                            Spacer()
                            Text("P" + String(project.priority))
                                .font(.body)
                                .fontWeight(.black)
                                .foregroundColor(Color.gray)
                        }
                        .onTapGesture {
                                    selectedProject.project = project
                                }
                        .contextMenu(menuItems: {
                            
                            Button("􀈊 Edit project") {
                                self.selectedEditProject = project
                                isEditProjectViewPresented = true
                            }
                            .sheet(isPresented: $isEditProjectViewPresented) {
                                //EditProjectView(project: project)
                                EditProjectView()
                                    .frame(minWidth: 300.0, minHeight: 300.0)
                            }
                            
                            Button("􀈑 Delete project") {
                                context.delete(project)
                                    do {
                                        try context.save()
                                    } catch {
                                        // handle the Core Data error
                                        print("Failed to delete task: \(error)")
                                    }
                            }
                        })
                    }
                }
                Section("􀓞 Not Started") {
                    ForEach(notStartedProjects) { project in
                        HStack(alignment: .center, spacing: 4) {
                            Text(project.name ?? "")
                                .font(.title2)
                            Spacer()
                            Text("P" + String(project.priority))
                                .font(.body)
                                .fontWeight(.black)
                                .foregroundColor(Color.gray)
                        }
                        .onTapGesture {
                                    selectedProject.project = project
                                }
                        .contextMenu(menuItems: {
                            
                            Button("􀈑 Delete project") {
                                context.delete(project)
                                    do {
                                        try context.save()
                                    } catch {
                                        // handle the Core Data error
                                        print("Failed to delete task: \(error)")
                                    }
                            }
                        })
                        
                    }
                    
                }
                Section("􀁣 Done") {
                    ForEach(doneProjects) { project in
                        HStack(alignment: .center, spacing: 4) {
                            Text(project.name ?? "")
                                .font(.title2)
                            Spacer()
                            Text("P" + String(project.priority))
                                .font(.body)
                                .fontWeight(.black)
                                .foregroundColor(Color.gray)
                        }
                        .onTapGesture {
                                    selectedProject.project = project
                                }
                        .contextMenu(menuItems: {
                            
                            //edit name
                            //edit priority
                            
                            Button("􀈑 Delete project") {
                                context.delete(project)
                                    do {
                                        try context.save()
                                    } catch {
                                        // handle the Core Data error
                                        print("Failed to delete task: \(error)")
                                    }
                            }
                        })
                    }
                }
                
            }
        }
        
        //Select first project in list as initial selectedProject.project
        .onAppear {
            if let firstProject = inProgressProjects.first ?? notStartedProjects.first ?? doneProjects.first {
                selectedProject.project = firstProject
            }
        }

        Button("Add a project") {
            isAddProjectViewPresented = true
        }
        
        .padding(.bottom, 16.0)
        .sheet(isPresented: $isAddProjectViewPresented) {
            AddProjectView()
                .frame(minWidth: 300.0, minHeight: 300.0)
        }
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsView()
    }
}
