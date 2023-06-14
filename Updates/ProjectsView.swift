//
//  ProjectsView.swift
//  Updates
//
//  Created by Jake Martin on 6/5/23.
//

import SwiftUI

struct ProjectRow: View {
    var project: Project
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(project.name ?? "")
                .font(.title2)
            
            Spacer()
            Text("P" + String(project.priority))
                .font(.body)
                .fontWeight(.black)
                .opacity(0.5)
        }
    }
}

struct projectMenu: View {
    
    var project: Project
    @State var isEditProjectViewPresented = false
    @State private var selectedEditProject: Project?
    
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    
    
    
    var body: some View {
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
    }
}

struct ProjectsView: View {
    
    @EnvironmentObject var selectedProject: SelectedProject
    @State var isAddProjectViewPresented = false
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    
    private func moveProject(from source: IndexSet, to destination: Int, in status: Int16) {
        withAnimation {
            let sourceProject = projects[status][source.first!]
            let newStatus = ProjectStatusSections(rawValue: status)?.next() ?? ProjectStatusSections.done
            sourceProject.status = newStatus.rawValue

            do {
                try context.save()
            } catch {
                print("Failed to update project status: \(error)")
            }
        }
    }

    
    @SectionedFetchRequest(
        sectionIdentifier: \Project.status,
        sortDescriptors: [SortDescriptor(\Project.name)],
        predicate: nil
    ) private var projects: SectionedFetchResults<Int16, Project>
    
    
    var body: some View {
        VStack {
            
            List {
                
                ForEach(projects) { section in
                    Section(header: Text(ProjectStatusSections.title(for: section.id))) {
                        ForEach(section) { project in
                            ProjectRow(project: project)
                                .tag(project)
                                .onTapGesture {
                                    selectedProject.project = project
                                }
                                .contextMenu(menuItems: {
                                    projectMenu(project: project)
                                })
                        }
                    }
                }
                .onMove { source, destination in
                    moveProject(from: source, to: destination, in: section.id)
                }
            }
            
        }
        
        //Select first project in list as initial selectedProject.project
        .onAppear {
            //if let firstProject = inProgressProjects.first ?? notStartedProjects.first ?? doneProjects.first {
            //selectedProject.project = firstProject
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
