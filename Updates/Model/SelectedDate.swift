//
//  SelectedDate.swift
//  Updates
//
//  Created by Jake Martin on 6/11/23.
//

import SwiftUI

class SelectedDate: ObservableObject {
    @Published var date = Calendar.current.startOfDay(for: Date())
}

