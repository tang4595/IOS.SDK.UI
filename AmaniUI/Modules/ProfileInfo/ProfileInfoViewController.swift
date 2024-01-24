//
//  ProfileInfoViewController.swift
//  AmaniUI
//
//  Created by Deniz Can on 22.01.2024.
//

import Foundation
import UIKit
import AmaniSDK

class ProfileInfoViewController: KeyboardAvoidanceViewController {
  var profileInfoView: ProfileInfoView!
  let profileInfoViewModel = ProfileInfoViewModel()
  private var handler: (() -> Void)? = nil
  private var docVersion: DocumentVersion?
  
  override func viewDidLoad() {
    profileInfoView = ProfileInfoView()
    profileInfoView.bind(withViewModel: profileInfoViewModel)
    
    profileInfoView.setCompletion { [weak self] in
      if let handler = self?.handler {
        handler()
      }
    }
    
    view.backgroundColor = UIColor(hexString: "#EEF4FA")
    
    contentView.addSubview(profileInfoView)
    addPoweredByIcon()
    
    profileInfoView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      profileInfoView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      profileInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
      profileInfoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0),
    ])
  }
  
  func setCompletionHandler(_ handler: @escaping (() -> Void)) {
    self.handler = handler
  }
  
  func bind(with docVersion: DocumentVersion?) {
    self.docVersion = docVersion
  }

}
