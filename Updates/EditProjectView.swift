//
//  AddProjectView.swift
//  Updates
//
//  Created by Jake Martin on 6/5/23.
//

import SwiftUI

struct EditProjectView: View {
    
    @ObservedObject var project: Project
    @State var projectName: String
    @State var projectPriority: ProjectPriority
    @State var projectStatus: ProjectStatusSections
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    
    init(project: Project) {
        self.project = project
        self._projectName = State(initialValue: project.name ?? "")
        self._projectPriority = State(initialValue: ProjectPriority(rawValue: project.priority)!)
        self._projectStatus = State(initialValue: ProjectStatusSections(rawValue: project.status)!)
    }


    
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
                Button("Save") {

                    project.name = projectName
                    project.priority = projectPriority.rawValue
                    project.status = projectStatus.rawValue
                    
                    do {
                        try context.save()
                    } catch {
                        print(error)
                    }
                    
                   dismiss()
                }
                .buttonStyle(.borderedProminent)
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
