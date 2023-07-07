//
//  AddProjectView.swift
//  Updates
//
//  Created by Jake Martin on 6/5/23.
//

import SwiftUI

struct AddProjectView: View {
    
    @EnvironmentObject var selectedProject: SelectedProject
    @State var projectName = ""
    @State var projectPriority = ProjectPriority.p1
    @State var projectStatus = ProjectStatusSections.inProgress
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    
    var body: some View {
        VStack (spacing: 16) {
            Text("Add a New Project")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            TextField("Project Name", text: $projectName)
            Picker("Priority", selection: $projectPriority) {
                Text("P1").tag(ProjectPriority.p1)
                Text("P2").tag(ProjectPriority.p2)
                Text("P3").tag(ProjectPriority.p3)
            }
            .pickerStyle(.segmented)
            Picker("Status", selection: $projectStatus) {
                ForEach(ProjectStatusSections.allCases, id: \.self) { status in
                                Text(status.title).tag(status)
                            }
            }
            Spacer()
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
                Spacer()
                Button("Add project") {
                    
                    let project = Project(context: context)
                    project.name = projectName
                    project.priority = projectPriority.rawValue
                    project.status = projectStatus.rawValue
                    selectedProject.project = project
                    
                    do {
                        try context.save()
                    } catch {
                        print(error)
                    }
                    
                   dismiss()
                }
                .disabled(projectName.isEmpty)
            }
        }
        .padding(32)
    }
}

struct AddProjectView_Previews: PreviewProvider {
    static var previews: some View {
        AddProjectView()
    }
}
