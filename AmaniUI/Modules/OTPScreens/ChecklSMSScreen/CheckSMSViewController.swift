//
//  CheckSMSViewController.swift
//  AmaniUI
//
//  Created by Deniz Can on 26.12.2023.
//

import Foundation
import UIKit

class CheckSMSViewController: KeyboardAvoidanceViewController {
  let checkSMSView = CheckSMSView()
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationItem.hidesBackButton = false
  }
  
  override func viewDidLoad() {
    checkSMSView.bind(withViewModel: CheckSMSViewModel())
    addPoweredByIcon()
    view.backgroundColor = UIColor(hexString: "#EEF4FA")
    contentView.addSubview(checkSMSView)
    checkSMSView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      checkSMSView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      checkSMSView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
      checkSMSView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0),
    ])
  }
  
  func setupCompletionHandler(_ handler: @escaping (() -> Void)) {
    checkSMSView.setCompletionHandler(handler)
  }
  
}
