//
//  TaskRow.swift
//  Updates
//
//  Created by Jake Martin on 6/12/23.
//

import SwiftUI

struct TaskRow: View {
    
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    
    @EnvironmentObject var selectedDate: SelectedDate
    @ObservedObject var task: Task
    @State private var updateContent: String = ""
    @State private var currentUpdate: Update?
    @State var taskChecked = Bool()
    @FocusState private var isUpdateFocused: Bool
    @State private var currentTask = ""
    @FocusState var isTaskFocused: Bool
    @State var taskFocused = Bool()
    @Binding var isGlobalTaskFocused: Bool
    @State private var hover = false
    @State private var isTaskMenuPresented = false
    @Binding var justCreatedTask: Task?
    @State private var isDueDatePickerPresented = false


    
    // Do some reading about automatically generated initilizers for classes and structs
    
    func fetchExistingUpdate(for task: Task) -> Update? {
        let fetchRequest: NSFetchRequest<Update> = Update.fetchRequest()
        
        // Get the start of the day for the date argument
        let startOfDay = Calendar.current.startOfDay(for: selectedDate.date)
        
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
        VStack(alignment: .leading, spacing: 4) {
            
                // GPT using combine debounce to save
                //Task checkbox
            HStack(alignment: .top, spacing: 8.0) {
                    Toggle(isOn: $taskChecked, label: {})
                    .padding(1.0)
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
                    
                    VStack(spacing: 4.0) {
                        TextField("Task name", text: $currentTask, axis: .vertical)
                            .onSubmit {
                                isTaskFocused = false
                            }
                            .textFieldStyle(PlainTextFieldStyle())
                            .focused($isTaskFocused)
                            .fontWeight(.bold)
                            .foregroundStyle(isTaskFocused ? .secondary : .primary)
                            .onAppear {
                                currentTask = task.name ?? "no task name found"
                                if task == justCreatedTask {
                                    isTaskFocused = true
                                }
                            }
                            .onChange(of: selectedDate.date) { _ in
                                    isTaskFocused = false
                            }
                            .onChange(of: isTaskFocused) { _ in
                                
                                taskFocused = isTaskFocused
                                
                                if isTaskFocused == true && isGlobalTaskFocused == false {
                                    isGlobalTaskFocused = true
                                }
                                
                                if isTaskFocused == false && currentTask.isEmpty {
                                    context.delete(task)
                                    do {
                                        try context.save()
                                    } catch {
                                        // handle the Core Data error
                                        print("Failed to delete task: \(error)")
                                    }
                                }
                                
                            }
                            .onChange(of: isGlobalTaskFocused) { _ in
                                if isGlobalTaskFocused == false && isTaskFocused == true {
                                    isTaskFocused = false
                                }
                            }
                            .onChange(of: currentTask) { newValue in
                                
                                task.name = currentTask
                                
                                do {
                                    print("task name saved")
                                    try context.save()
                                } catch {
                                    print("Failed to save task name: \(error)")
                                }
                            }
                        
                        if isTaskFocused || task.dueDate != nil || isDueDatePickerPresented{
                            HStack {
                                DatePickerView(task: task, isTaskFocused: $taskFocused, isDueDatePickerPresented: $isDueDatePickerPresented)
                                
                                if isTaskFocused {
                                    
                                    Menu("") {
                                        
                                        Button("􀈑 Delete task", action: {
                                            context.delete(task)
                                            do {
                                                try context.save()
                                            } catch {
                                                // handle the Core Data error
                                                print("Failed to delete task: \(error)")
                                            }
                                        })
                                        
                                        Text(task.dateAdded != nil ? "􀉉 Added on \(dateFormatter.string(from: task.dateAdded!))" : "No dateAdded found")
                                        
                                    }
                                    .menuStyle(.borderlessButton)
                                    .fixedSize()
                                }
                                
                                Spacer()
                            }
                        }
                }
                

                
                
                
                
                Spacer()
                
                //'Complete button' logic
                if taskChecked && !task.complete {
                    Button("Mark as Complete") {
                        task.complete = true
                        task.dateComplete = selectedDate.date
                    }
                    .buttonStyle(.link)
                    
                } else if task.complete{
                    HStack(spacing: 0.0) {
                        
                        let completeToday = selectedDate.date == task.dateComplete
                        
                        Text("Task completed on ")
                            .foregroundStyle(.gray)
                        
                        Button(task.dateComplete != nil ? dateFormatter.string(from: task.dateComplete!) : "No dateComplete found", action: {
                            selectedDate.date = task.dateComplete ?? selectedDate.date
                        })
                        .buttonStyle(.plain)
                        .foregroundStyle(completeToday ? .gray : .blue)
                    }
                    if taskChecked && task.complete && task.dateComplete == selectedDate.date{
                        Button("Undo") {
                            task.complete = false
                            task.dateComplete = nil
                        }
                        .buttonStyle(.link)
                    }
                }
                
                
                
            }
            .onHover { over in
                hover = over
            }
            
            //Task Update Field
            if taskChecked {
                
                TextField("Task Update", text: $updateContent, prompt: Text("Add an update"), axis: .vertical)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 400.0)
                    .focused($isUpdateFocused)
                    .onAppear {
                        currentUpdate = fetchExistingUpdate(for: task) ?? createNewUpdate(for: task)
                        updateContent = currentUpdate?.content ?? ""
                        
                    }
                    .onChange(of: isUpdateFocused) { _ in
                        
                        if isUpdateFocused == true && isGlobalTaskFocused == false {
                            isGlobalTaskFocused = true
                        }
                    }
                    .onChange(of: isGlobalTaskFocused) { _ in
                        if isGlobalTaskFocused == false && isUpdateFocused == true {
                            isUpdateFocused = false
                        }
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
                //.disabled(task.complete)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.leading, 24.0)
                
                
            }
        }
        .padding(8)
        .background(taskChecked ? Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.1) : Color.clear)
        .cornerRadius(taskChecked ? 12.0 : 0.0)
        .padding(.bottom, taskChecked ? 8.0 : 0)
        .onAppear {
            setTaskChecked()
        }
        .onChange(of: selectedDate.date) { _ in
            setTaskChecked()
        }
    }
    
}


//#Preview {
//    TaskRow()
//}
