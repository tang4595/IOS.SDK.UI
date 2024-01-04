//
//  CheckMailViewController.swift
//  AmaniStudio
//
//  Created by Deniz Can on 11.12.2023.
//

import Foundation
import UIKit

class CheckMailViewController: KeyboardAvoidanceViewController {
  private var checkMailView: CheckMailView!
  
  override init() {
    super.init()
    checkMailView = CheckMailView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationItem.hidesBackButton = false
  }
  
  override func viewDidLoad() {
    checkMailView.bind(withViewModel: CheckMailViewModel())
    addPoweredByIcon()
    view.backgroundColor = UIColor(hexString: "#EEF4FA")
    contentView.addSubview(checkMailView)
    checkMailView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      checkMailView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      checkMailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
      checkMailView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0),
    ])
  }
  
  func setupCompletionHandler(_ handler: @escaping (() -> Void)) {
    checkMailView.setCompletionHandler(handler)
  }
  
}
