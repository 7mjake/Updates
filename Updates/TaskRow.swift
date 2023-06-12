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
                    .padding(.bottom, 8.0)
                
                
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


//#Preview {
//    TaskRow()
//}
