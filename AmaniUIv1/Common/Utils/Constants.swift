//
//  Constants.swift
//  AmaniUIv1
//
//  Created by Deniz Can on 6.09.2022.
//

enum AppConstants {
  
  enum CameraFacing: String {
    case user
    case environment
  }
  
  enum AmaniError: Error {
    case ConfigError
    case StepFetchError
  }
} 
