//
//  ProjectUpdateView.swift
//  Updates
//
//  Created by Jake Martin on 6/8/23.
//

import SwiftUI


struct ProjectUpdateView: View {
    
    @EnvironmentObject var selectedProject: SelectedProject
    @State var notes = ""
   // @State var selectedProject = Project.
    
    
    
    
    var body: some View {
        VStack(spacing: 0){
            ScrollView {
                VStack(alignment: .leading, spacing: 0){
                    Text(selectedProject.project?.name ?? "No project selected")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer(minLength: 24)
                    Text("What did you work on today?")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Spacer(minLength: 8)
                    
                    TaskListView()
                    
                    Spacer(minLength: 24)
                    
                    Text("Notes")
                        .font(.title2)
                        .fontWeight(.medium)
                    Spacer(minLength: 8)
                    TextField("Any other updates", text: $notes, axis: .vertical)
                        .lineLimit(4...)
                    
                        
                    
                }
                .padding(32)
            }
            
            
            
            Divider()
            HStack {
                Button("See all **Dairy Queen** updates") {
                    //Create a new task
                }
                .buttonStyle(.link)
                Spacer()
                Button("Mark **Dairy Queen** as done") {
                    //Create a new task
                }
                .buttonStyle(.link)
            }
            .padding(EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32))
        }
    }
}


struct ProjectUpdateView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectUpdateView()
    }
}
