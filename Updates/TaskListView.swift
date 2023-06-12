//
//  TaskListView.swift
//  Updates
//
//  Created by Jake Martin on 6/7/23.
//

import SwiftUI

struct TaskListView: View {
    
    @EnvironmentObject var selectedProject: SelectedProject
    @EnvironmentObject var selectedDate: SelectedDate
    @State var addingTask = false
    
    func deleteAllTasks() {
        guard let project = selectedProject.project else { return }
        let tasks = allTasks.filter { $0.project == project }
        for task in tasks {
            context.delete(task)
        }
        do {
            try context.save()
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
    }
    
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.dueDate, ascending: true)],
        animation: .default)
    private var allTasks: FetchedResults<Task>
    
    private var filteredTasks: [Task] {
        guard let project = selectedProject.project else { return [] }
        return allTasks.filter { $0.project == project }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            
            
            ForEach(filteredTasks) { task in
                TaskRow(task: task)
                
            }
            
            //Adding Tasks
            if addingTask {
                NewTaskView(addingTask: $addingTask)
            } else {
                Button("Add a task") {
                    addingTask = true
                }
                .buttonStyle(.link)
            }
        }
        Spacer(minLength: 16)
        //        Button(action: {
        //            deleteAllTasks()
        //        }, label: {
        //            Text("Delete All Tasks")
        //        })
        //        .background(
        //            RoundedRectangle(cornerRadius: 8, style: .continuous)
        //                .fill(Color.red)
        //        )
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView()
    }
}


