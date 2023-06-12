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
    @FocusState private var isUpdateFocused: Bool
    
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
    
    var dateFormatter = Self.makeDateFormatter()
    static func makeDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .short
        
        return dateFormatter
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
                
                if task.dueDate != nil {
                    Text(dateFormatter.string(from: task.dueDate!))
                        .foregroundColor(task.dueDate! < Date.now ? .red : .gray)
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
                    .focused($isUpdateFocused)
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
                        isUpdateFocused = false
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

struct NewTaskFields: View {
    
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    @EnvironmentObject var selectedProject: SelectedProject
    @EnvironmentObject var selectedDate: SelectedDate
    @Binding var addingTask: Bool
    
    @State var newTask = ""
    @State private var isDueDatePickerPresented = false
    @State private var tempDueDate = Date()
    @State private var isDatePicked = false
    @State var newTaskDueDate = Date()
    @State var newTaskComplete = false
    @State var newTaskDone = false
    @State var buttonText = "Due date"
    @FocusState private var newTaskField: Bool
    
    var dateFormatter = Self.makeDateFormatter()
    static func makeDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .short
        
        return dateFormatter
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            Toggle("", isOn: $newTaskDone.animation())
                .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            TextField("New task", text: $newTask)
                .textFieldStyle(PlainTextFieldStyle())
            //.foregroundColor(.gray)
                .focused($newTaskField)
                .onAppear {newTaskField = true}
                .fixedSize()
            
            Spacer(minLength: 5)
            
            Button(action: {
                isDueDatePickerPresented.toggle()
            }, label: {
                Text(buttonText)
                    .foregroundColor(Color.gray)
            })
            .buttonStyle(.plain)
            .popover(isPresented: $isDueDatePickerPresented, arrowEdge: Edge.trailing, content: {
                DatePicker(
                    "",
                    selection: $tempDueDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding(EdgeInsets(top: 24, leading: 16, bottom: 8, trailing: 24))
                .onChange(of: tempDueDate) { newContent in
                    
                    buttonText = dateFormatter.string(from: newContent)
                    
                }
                
                HStack {
                    Button("Save", action: {
                        newTaskDueDate = tempDueDate
                        tempDueDate = Date()
                        isDatePicked = true
                        isDueDatePickerPresented = false
                    })
                    Spacer()
                        .buttonStyle(.plain)
                    Button("Cancel", action: {
                        tempDueDate = Date()
                        buttonText = "Due date"
                        isDatePicked = false
                        isDueDatePickerPresented = false
                    })
                    .buttonStyle(.plain)
                    
                }
                .padding([.leading, .bottom, .trailing], 24.0)
            })
            
            
        }
        .fixedSize()
        // press enter to save
        // press esc to cancel
        
        HStack {
            Button("Save") {
                addingTask = false
                let task = Task(context: context)
                task.id = UUID()
                task.name = newTask
                task.complete = false
                task.project = selectedProject.project
                
                if isDatePicked {
                    task.dueDate = newTaskDueDate
                }
                
                do {
                    try context.save()
                } catch {
                    print(error)
                }
                
            }
            .buttonStyle(.link)
            Button("Cancel") {
                addingTask = false
                
            }
            .buttonStyle(.link)
        }
    }
}

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
        VStack(alignment: .leading) {
            
            
            ForEach(filteredTasks) { task in
                TaskRow(task: task)
                
            }
            
            //Adding Tasks
            if addingTask {
                NewTaskFields(addingTask: $addingTask)
            } else {
                Button("Add a task") {
                    addingTask = true
                }
                .buttonStyle(.link)
            }
        }
        Spacer(minLength: 16)
        Button(action: {
            deleteAllTasks()
        }, label: {
            Text("Delete All Tasks")
        })
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.red)
        )
    }
}




struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView()
    }
}


