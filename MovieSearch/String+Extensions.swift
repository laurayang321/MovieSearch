//
//  String+Extensions.swift
//  MovieSearch
//
//  Created by Jing Yang on 2024-06-24.
//

import Foundation

extension String {
    func trimmed() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
