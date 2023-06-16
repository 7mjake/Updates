//
//  AddProjectView.swift
//  Updates
//
//  Created by Jake Martin on 6/5/23.
//

import SwiftUI

struct EditProjectView: View {
    
    let project: Project
    @State var projectName = project.name
    @State var projectPriority: Int16
    @State var projectStatus: Int16
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    
//    init(project: Project) {
//        self.project = project
//        self.projectName = project.name ?? ""
//        self.projectPriority = project.priority
//        self.projectStatus = project.status
//    }
    
    var body: some View {
        VStack (spacing: 16) {
            Text("Edit")
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
                Text("In Progress").tag(ProjectStatus.inProgess)
                Text("Not Started").tag(ProjectStatus.notStarted)
                Text("Done").tag(ProjectStatus.done)
            }
            Spacer()
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
                Spacer()
                Button("Done") {
                    
                    let project = Project(context: context)
                    project.name = projectName
//                    project.priority = projectPriority.rawValue
//                    project.status = projectStatus.rawValue
                    
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

//struct EditProjectView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditProjectView()
//    }
//}
