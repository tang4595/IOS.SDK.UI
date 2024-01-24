//
//  String+Extensions.swift
//  AmaniUI
//
//  Created by Deniz Can on 24.01.2024.
//

import Foundation

extension String {
  func convertDateFormat() -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy"

    if let originalDate = dateFormatter.date(from: self) {
      dateFormatter.dateFormat = "yyyy-MM-dd"
      return dateFormatter.string(from: originalDate)
    } else {
      return nil
    }
  }
}
