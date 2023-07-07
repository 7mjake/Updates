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
    @Binding var isGlobalTaskFocused: Bool
    @State var justCreatedTask: Task?
    
    // make a state prop for recentlyCreatedTask
    
    func deleteAllTasks() {
        guard let project = selectedProject.project else { return }
        let tasks = allTasks.filter { $0.project == project}
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
        return allTasks.filter { $0.project == project && $0.dateAdded ?? selectedDate.date <= selectedDate.date && $0.dateComplete ?? selectedDate.date >= selectedDate.date}
    }
    
    var dateFormatter = Self.makeDateFormatter()
    static func makeDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .short
        
        return dateFormatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            
            
            ForEach(filteredTasks) { task in
                // pass in should be selected if task is the currently selected task
                TaskRow(task: task, isGlobalTaskFocused: $isGlobalTaskFocused, justCreatedTask: $justCreatedTask)
                
                // You need to at some point nil out the value of the currently selected task
            }
            
            Spacer(minLength: 5.0)
            
            //Adding Tasks
                Button("Add a task") {
                    let task = Task(context: context)
                    task.dateAdded = selectedDate.date
                    task.id = UUID()
                    task.name = ""
                    task.complete = false
                    task.project = selectedProject.project
                    justCreatedTask = task
                    
                    do {
                        try context.save()
                    } catch {
                        print(error)
                    }
                }
                .buttonStyle(.link)
                .padding(.leading, 8)
            
        }
        
//        Spacer(minLength: 16)
//                Button(action: {
//                    deleteAllTasks()
//                }, label: {
//                    Text("Delete All Tasks")
//                })
//                .background(
//                    RoundedRectangle(cornerRadius: 8, style: .continuous)
//                        .fill(Color.red)
//                )
    }
}

//struct TaskListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TaskListView()
//    }
//}


