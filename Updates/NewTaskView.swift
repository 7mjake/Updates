//
//  NewTaskView.swift
//  Updates
//
//  Created by Jake Martin on 6/12/23.
//

import SwiftUI

struct NewTaskView: View {
    
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

//struct NewTaskView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewTaskView()
//    }
//}
