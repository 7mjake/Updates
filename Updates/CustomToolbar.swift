//
//  CustomToolbar.swift
//  Updates
//
//  Created by Jake Martin on 6/8/23.
//

import SwiftUI

struct CustomToolbar: View {
    
    @State private var date = Date()
    @State private var isDatePickerPresented = false
    private var dateFormatter = Self.makeDateFormatter()
    
    static func makeDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        
        return dateFormatter
    }
    
    var body: some View {
        HStack {
            Button(action: {
                date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
            }, label: {
                Image(systemName: "chevron.left")
            })
            Text(dateFormatter.string(from: date))
                .font(.largeTitle)
                .fontWeight(.heavy)
            Button(action: {
                date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
            }, label: {
                Image(systemName: "chevron.right")
            })
            
            Spacer()
            
            
            if dateFormatter.string(from: date) != (dateFormatter.string(from: Date.now)) {
                Button(action: {
                    date = Date.now
                }, label: {
                    Text("Today")
                        .fontWeight(.bold)
                        .foregroundColor(Color.blue)
                })
                
            } else if dateFormatter.string(from: date) == (dateFormatter.string(from: Date.now)) {
                Button(action: {
                    date = Date.now
                }, label: {
                    Text("Today")
                })
                .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            }
            
            
            
            Button(action: {
                isDatePickerPresented.toggle()
            }, label: {
                Image(systemName: "calendar")
            }).popover(isPresented: $isDatePickerPresented, arrowEdge: Edge.bottom, content: {
                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding(EdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 24))
                
            })
            
        }
        
        .padding(16)
        
    }
       
}


struct CustomToolbar_Previews: PreviewProvider {
    static var previews: some View {
        CustomToolbar()
    }
}

