//
//  TaskListView.swift
//  Updates
//
//  Created by Jake Martin on 6/7/23.
//

import SwiftUI

struct TaskListView: View {
    
    @EnvironmentObject var selectedProject: SelectedProject
    @State var addingTask = false
    @State var newTask = ""
    @State var newTaskComplete = false
    @State var newTaskDone = false
    
    @FocusState private var newTaskField: Bool
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    
    @State private var tasks: [Task] = []
    private func fetchTasks(for project: Project) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Task.dueDate, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "project == %@", project)
        do {
            tasks = try context.fetch(fetchRequest)
        } catch {
            print ("Failed to fetch tasks: \(error)")
        }
    }
    
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            
            ForEach(tasks) { task in
                VStack {
                    
                    @State var localUpdate = ""
                    
                    HStack {
                        
                        //Completed Tasks
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
                        
                        //Uncompleted Tasks
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
                            
                            //Checked Tasks
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
                        TextField("Task Update", text: $localUpdate, prompt: Text("Update"),
                                  axis: .vertical)
                        .lineLimit(2...)
                    }
                }
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
                            if let project = selectedProject.project {
                                        fetchTasks(for: project)
                                    }
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
        .onAppear {
            if let project = selectedProject.project {
                fetchTasks(for: project)
            }
        }
        .onChange(of: selectedProject.project) { newProject in
            if let newProject = newProject {
                fetchTasks(for: newProject)
            }
        }
    }
    
}


struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView()
    }
}


