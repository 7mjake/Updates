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
        } detail: {
            VStack (spacing: 0) {
                //CustomToolbar()
                //Divider()
                
                ProjectUpdateView()
                    .environmentObject(selectedDate)
            }
        }
        .toolbar {
            ToolbarItem {
                CustomToolbar()
                    .environmentObject(selectedDate)
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
