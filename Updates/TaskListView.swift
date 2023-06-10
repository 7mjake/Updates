//
//  TaskListView.swift
//  Updates
//
//  Created by Jake Martin on 6/7/23.
//

import SwiftUI

struct TaskRow: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    
    var body: some View {
        VStack {
            HStack {
                //Completed Task
                if task.complete {
                    Toggle(isOn: Binding(get: {
                        task.checked
                    }, set: { newValue in
                        task.checked = newValue
                        try? context.save()
                    }), label: {
                        Text(task.name ?? "error")
                            .strikethrough()
                    })
                    .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    
                    Spacer()
                    Button("Undo") {
                        task.complete = false
                    }
                    .buttonStyle(.link)
                    Button("Delete task") {
                        context.delete(task)
                        do {
                            try context.save()
                        } catch {
                            // handle the Core Data error
                            print("Failed to delete task: \(error)")
                        }
                    }
                    .buttonStyle(.link)
                    .foregroundColor(.red)
                    
                    
                }
                
                //Uncompleted Task
                else if !task.complete {
                    Toggle(isOn: Binding(get: {
                        task.checked
                    }, set: { newValue in
                        task.checked = newValue
                        try? context.save()
                    }), label: {
                        Text(task.name ?? "error")
                    })
                    
                    Spacer()
                    
                    if task.checked {
                        Button("Mark as Complete") {
                            task.complete = true
                        }
                        .buttonStyle(.link)
                    }
                }
                
                
            }
            
            //Task Update Field
            if task.checked {
                
                @State var updateText: String = ""
                
                TextField("Task Update", text: $updateText, prompt: Text("Update"), axis: .vertical)
                .onSubmit {
                    print("Text submitted")
                }
                .lineLimit(2...)
                
            }
        }
    }
}


struct TaskListView: View {
    
    @EnvironmentObject var selectedProject: SelectedProject
    
    @State var addingTask = false
    @State var newTask = ""
    @State var newTaskComplete = false
    @State var newTaskDone = false
    
    @FocusState private var newTaskField: Bool
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
        VStack(alignment: .leading) {
            
            ForEach(filteredTasks) { task in
                TaskRow(task: task)
            }
            
            //Adding Tasks
            if addingTask {
                HStack(alignment: .bottom, spacing: 0) {
                    Toggle("", isOn: $newTaskDone.animation())
                        .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    TextField("New task", text: $newTask)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.gray)
                        .focused($newTaskField)
                    
                    
                }
                // press enter to save
                // press esc to cancel
                
            }
            
            if !addingTask {
                Button("Add a task") {
                    addingTask = true
                    newTaskField = true
                }
                .buttonStyle(.link)
            }
            //Saving or Canceling a new task
            else if addingTask {
                HStack {
                    Button("Save") {
                        addingTask = false
                        let task = Task(context: context)
                        task.id = UUID()
                        task.name = newTask
                        task.complete = false
                        task.dueDate = Date.now
                        task.project = selectedProject.project
                        newTask = ""
                        
                        
                        do {
                            try context.save()
                        } catch {
                            print(error)
                        }
                        
                    }
                    .buttonStyle(.link)
                    Button("Cancel") {
                        addingTask = false
                        newTask = ""
                    }
                    .buttonStyle(.link)
                }
            }
            
        }
    }
    
}


struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView()
    }
}


