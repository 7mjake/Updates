//
//  ProjectStatusSections.swift
//  Updates
//
//  Created by Jake Martin on 6/14/23.
//

import Foundation

enum ProjectStatusSections: Int16, CaseIterable {
    case inProgress = 0
    case notStarted = 1
    case done = 2

    static func title(for value: Int16) -> String {
        return Self(rawValue: value)?.title ?? "Unknown"
    }
    
    var title: String {
        switch self {
            case .inProgress:
                return "􀧒 In Progress"
            case .notStarted:
                return "􀓞 Not Started"
            case .done:
                return "􀁣 Done"
        }
    }
}

extension ProjectStatusSections {
    func next() -> ProjectStatusSections? {
        switch self {
        case .inProgress:
            return .notStarted
        case .notStarted:
            return .done
        case .done:
            return .inProgress
        }
    }
}
