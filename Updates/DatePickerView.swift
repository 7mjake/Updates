//
//  DatePickerView.swift
//  Updates
//
//  Created by Jake Martin on 7/4/23.
//

import SwiftUI

struct DatePickerView: View {
    
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    
    @EnvironmentObject var selectedDate: SelectedDate
    @ObservedObject var task: Task
    @Binding var isTaskFocused: Bool
    @Binding var isDueDatePickerPresented: Bool
    @State private var tempDueDate = Date()
    @State private var isDatePicked = false
    @State var newTaskDueDate = Date()
    @State var buttonText = "􀉊"
    
    var dateFormatter = Self.makeDateFormatter()
    static func makeDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .short
        
        return dateFormatter
    }
    
    var body: some View {
        
        if isTaskFocused || isDueDatePickerPresented || task.dueDate != nil {
            Button(action: {
                isDueDatePickerPresented.toggle()
            }, label: {
                Text(buttonText)
                    .foregroundStyle(Calendar.current.startOfDay(for: task.dueDate ?? Date.distantFuture) <= Calendar.current.startOfDay(for: selectedDate.date) ? .red : .secondary)
                
            })
            .onAppear {
                if task.dueDate != nil {
                    buttonText = "Due \(dateFormatter.string(from: task.dueDate!))"
                }
            }
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
                    
                    buttonText = "Due \(dateFormatter.string(from: newContent))"
                    
                }
                
                HStack {
                    Button("Save", action: {
                        newTaskDueDate = tempDueDate
                        tempDueDate = Date()
                        isDatePicked = true
                        isDueDatePickerPresented = false
                        task.dueDate = newTaskDueDate
                        
                        do {
                            try context.save()
                        } catch {
                            // handle the Core Data error
                            print("Failed to save due date: \(error)")
                        }
                    })
                    Spacer()
                        .buttonStyle(.plain)
                    Button("Clear", action: {
                        tempDueDate = Date()
                        buttonText = "􀉊"
                        isDatePicked = false
                        isDueDatePickerPresented = false
                        task.dueDate = nil
                        
                        do {
                            try context.save()
                        } catch {
                            // handle the Core Data error
                            print("Failed to save due date: \(error)")
                        }
                    })
                    .buttonStyle(.plain)
                    
                }
                .padding([.leading, .bottom, .trailing], 24.0)
            })
        }
    }
}

//struct DatePickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        DatePickerView()
//    }
//}
