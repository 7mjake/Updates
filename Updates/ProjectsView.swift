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
    @Binding var isEditProjectViewPresented: Bool
    
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    
    
    
    var body: some View {
        Button("􀈊 Edit project") {
            isEditProjectViewPresented = true
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
    @State var isEditProjectViewPresented = false
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    
    @SectionedFetchRequest(
        sectionIdentifier: \Project.status,
        sortDescriptors: [SortDescriptor(\Project.name)],
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
                                    projectMenu(project: project, isEditProjectViewPresented: $isEditProjectViewPresented)
                                })
                        }
                    }
                }
            }
            .sheet(isPresented: $isEditProjectViewPresented) {
                EditProjectView()
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
