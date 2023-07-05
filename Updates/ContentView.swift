//
//  ContentView.swift
//  Updates
//
//  Created by Jake Martin on 6/5/23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var selectedProject = SelectedProject()
    @StateObject var selectedDate = SelectedDate()
    @State private var date = Date()
    @State private var isDatePickerPresented = false
    private var dateFormatter = Self.makeDateFormatter()
    
    static func makeDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .full
        
        return dateFormatter
    }
    
    
    var body: some View {
        NavigationSplitView {
            ProjectsView()
                .environmentObject(selectedProject)
                .environmentObject(selectedDate)
        } detail: {
            VStack (spacing: 0) {
                //CustomToolbar()
                //Divider()
                
                ProjectUpdateView(isGlobalTaskFocused: false)
                    .environmentObject(selectedDate)
            }
        }
        .toolbar {
            ToolbarItem (placement: .navigation) {
                HStack {
                    Button(action: {
                        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate.date) {
                            selectedDate.date = previousDay
                        }
                    }, label: {
                        Image(systemName: "chevron.left")
                    })
                    Button(action: {
                        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate.date) {
                                selectedDate.date = nextDay
                        }
                    }, label: {
                        Image(systemName: "chevron.right")
                    })
                    Text(dateFormatter.string(from: selectedDate.date))
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                }
            }
            ToolbarItem {
                HStack {
                    let isToday = Calendar.current.isDateInToday(selectedDate.date)
                    if !isToday {
                        Button(action: {
                            selectedDate.date = Date.now
                        }) {
                            Text("Today")
                                .foregroundColor(Color.blue)
                        }
                    }
                    
                    Button(action: {
                        isDatePickerPresented.toggle()
                    }, label: {
                        Image(systemName: "calendar")
                    }).popover(isPresented: $isDatePickerPresented, arrowEdge: Edge.bottom, content: {
                        DatePicker(
                            "",
                            selection: $selectedDate.date,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                        .padding(EdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 24))
                        
                    })
                }
            }
            
            
        }
        
        .navigationTitle("")
        .environmentObject(selectedProject)
    }
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
