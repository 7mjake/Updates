//
//  TaskListView.swift
//  Updates
//
//  Created by Jake Martin on 6/7/23.
//

import SwiftUI

struct TaskRow: View {
    @EnvironmentObject var selectedDate: SelectedDate
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    @State private var updateContent: String = ""
    @State private var currentUpdate: Update?
    @State var taskChecked = Bool()
    
    func fetchExistingUpdate(for task: Task) -> Update? {
        let fetchRequest: NSFetchRequest<Update> = Update.fetchRequest()
        
        // Get the start of the day for the date argument
        let startOfDay = Calendar.current.startOfDay(for: selectedDate.date)
        
        // This predicate assumes 'date' is a Date type and 'task' is a relationship to the Task entity
        let predicate = NSPredicate(format: "date == %@ AND task == %@", startOfDay as NSDate, task)
        
        fetchRequest.predicate = predicate
        
        do {
            let updates = try context.fetch(fetchRequest)
            if let update = updates.first {
                // Return the first update if one exists
                return update
            }
        } catch {
            print("Failed to fetch Update: \(error)")
        }
        
        // If no Update was found or an error occurred, return nil
        return nil
    }
    
    func createNewUpdate(for task: Task) -> Update {
        // If no Update was found or an error occurred, create a new Update
        let newUpdate = Update(context: context)
        newUpdate.date = Calendar.current.startOfDay(for: selectedDate.date)
        newUpdate.task = task
        
        do {
            try context.save()
        } catch {
            print("Failed to save new Update: \(error)")
        }
        
        return newUpdate
    }
    
    func setTaskChecked() {
        if fetchExistingUpdate(for: task) == nil {
            taskChecked = Bool()
            
            //print("box set to UN-checked")
        } else {
            taskChecked = true
            //print("box set to checked")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                
                //Task checkbox
                Toggle(isOn: $taskChecked, label: {
                    Text(task.name ?? "error")
                })
                .disabled(task.complete)
                .onChange(of: taskChecked) { newValue in
                    let update = fetchExistingUpdate(for: task)
                    if newValue == false && fetchExistingUpdate(for: task) != nil{
                        context.delete(update!)
                        print("update deleted")
                        
                        do {
                            try context.save()
                        } catch {
                            // handle the Core Data error
                            print("Failed to delete update: \(error)")
                        }
                    }
                }
                
                Spacer()
                
                //'Complete button' logic
                if taskChecked && !task.complete {
                    Button("Mark as Complete") {
                        task.complete = true
                    }
                    .buttonStyle(.link)
                } else if taskChecked && task.complete {
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
                
                
                
            }
            
            //Task Update Field
            if taskChecked {
                
                TextField("Task Update", text: $updateContent, prompt: Text("Update"), axis: .vertical)
                    .onAppear {
                        currentUpdate = fetchExistingUpdate(for: task) ?? createNewUpdate(for: task)
                        updateContent = currentUpdate?.content ?? ""
                        
                    }
                    .onChange(of: updateContent) { newValue in
                        
                        
                        // Update the Update's content whenever updateContent changes
                        currentUpdate?.content = newValue
                        
                        
                        
                        do {
                            print("update saved")
                            try context.save()
                        } catch {
                            print("Failed to save Update content: \(error)")
                        }
                    }
                    .onChange(of: selectedDate.date) { newValue in
                        // Show the current day's update
                        currentUpdate = fetchExistingUpdate(for: task)
                        updateContent = currentUpdate?.content ?? ""
                        
                        if fetchExistingUpdate(for: task) == nil {
                            taskChecked = Bool()
                        }
                    }
                    .lineLimit(2...)
                    .disabled(task.complete)
                
                
            }
        }
        .onAppear {
            setTaskChecked()
        }
        .onChange(of: selectedDate.date) { _ in
            setTaskChecked()
        }
    }
    
}


struct TaskListView: View {
    
    @EnvironmentObject var selectedProject: SelectedProject
    @EnvironmentObject var selectedDate: SelectedDate
    
    @State var addingTask = false
    @State var newTask = ""
    @State var newTaskComplete = false
    @State var newTaskDone = false
    
    func deleteAllUpdates() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Update")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
    }
    
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
            
            //            Button(action: {
            //                deleteAllUpdates()
            //            }, label: {
            //                Text("Delete All Updates")
            //            })
            //            .background(
            //                RoundedRectangle(cornerRadius: 8, style: .continuous)
            //                    .fill(Color.red)
            //            )
        }
    }
    
}


struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView()
    }
}


