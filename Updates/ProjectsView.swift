//
//  ProjectsView.swift
//  Updates
//
//  Created by Jake Martin on 6/5/23.
//

import SwiftUI

struct ProjectRow: View {
    @ObservedObject var project: Project
    @EnvironmentObject var selectedDate: SelectedDate
    @EnvironmentObject var selectedProject: SelectedProject
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    
    private func activeTaskCount(for project: Project, on date: Date) -> Int {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        
        // Set the predicate.
        let predicate = NSPredicate(format: "project == %@ && complete == false", project)
        request.predicate = predicate
        
        do {
            // Get the count for the tasks in the project on the selected date.
            let count = try context.count(for: request)
            return count
        } catch {
            print("Error fetching task count: \(error)")
            return 0
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            let taskCount = activeTaskCount(for: project, on: selectedDate.date)
            let isProjectSelected = project == selectedProject.project
            
            if project.priority == 1 {
                Image(systemName: "star.fill")
                    .foregroundColor(isProjectSelected ? Color.primary: Color.accentColor)
            }
            
            Text(project.name ?? "")
                .font(.title2)
                .fontWeight(project.priority == 1 ? .bold : .regular)
            
            Spacer()
            
            //            Text("P" + String(project.priority))
            if taskCount > 0 {
                Text(String(taskCount))
                    .fontWeight(.bold)
                    .foregroundColor(isProjectSelected ? Color.white : Color.clear)
                    .scaleEffect(isProjectSelected ? 1.0 : 0.1)
                    .frame(width: isProjectSelected ? 24.0 : 12.0, height: isProjectSelected ? 24.0 : 12.0)
                    .background(
                        Circle()
                            .fill(Color.accentColor)
                    )
                    .padding(isProjectSelected ? 0.0 : 6.0)
                    .animation(.easeInOut(duration: 0.15), value: isProjectSelected)
            }
        }
    }
}

struct ProjectMenu: View {
    
    @EnvironmentObject var selectedProject: SelectedProject
    var project: Project
    let editHandler: () -> Void
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\Project.status),
            SortDescriptor(\Project.priority),
            SortDescriptor(\Project.name)
        ],
        predicate: nil
    ) private var allProjects: FetchedResults<Project>
    
    var body: some View {
        Button("􀈊 Edit project") {
            editHandler()
        }
        
        Button("􀈑 Delete project") {
            
            context.delete(project)
            
            do {
                try context.save()
            } catch {
                print("Failed to delete project: \(error)")
            }
            if allProjects.count >= 1  && project == selectedProject.project {
                selectedProject.project = allProjects[0]
            } else if allProjects.count == 0 {
                selectedProject.project = nil
                print("no more projects")
            }
        }
    }
}


struct ProjectsView: View {
    
    @EnvironmentObject var selectedProject: SelectedProject
    @State var isAddProjectViewPresented = false
    @State var isEditProjectViewPresented = false
    @State var projectForEdit: Project?
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    
    @SectionedFetchRequest(
        sectionIdentifier: \Project.status,
        sortDescriptors: [
            SortDescriptor(\Project.status),
            SortDescriptor(\Project.priority),
            SortDescriptor(\Project.name)
        ],
        predicate: nil
    ) private var projects: SectionedFetchResults<Int16, Project>
    
    var body: some View {
        VStack {
            
            List(selection: $selectedProject.project) {
                
                ForEach(projects) { section in
                    Section(header: Text(ProjectStatusSections.title(for: section.id))) {
                        ForEach(section) { project in
                            ProjectRow(project: project)
                                .tag(project)
                                .onTapGesture {
                                    selectedProject.project = project
                                }
                                .contextMenu(menuItems: {
                                    ProjectMenu(project: project){
                                        projectForEdit = project
                                    }
                                })
                        }
                    }
                }
                .onMove(perform: { _, _ in
                    
                })
            }
            .sheet(item: $projectForEdit) { project in
                EditProjectView(project: project)
                    .frame(minWidth: 300.0, minHeight: 300.0)
            }
        }
        
        //Select first project in list as initial selectedProject.project
        .onAppear {
            if let firstSection = projects.first(where: { !$0.isEmpty }),
               let firstProject = firstSection.first {
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
