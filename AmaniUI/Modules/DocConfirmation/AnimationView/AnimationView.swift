//
//  AnimationView.swift
//  AmaniUI
//
//  Created by Bedri Doğan on 29.05.2024.
//

import Foundation
import AmaniSDK


class AnimationViewDocConfirmation: UIViewController {
    var spinner = UIActivityIndicatorView(style: .large)
    var infoLabel = UILabel()
    var config: StepConfig? {
            didSet {
                guard let config = config else { return }
                setupUI()
               
            }
        }
    
    override func loadView() {
        super.loadView()
        
    }
  
    private func setupUI() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)


        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

       
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.text = "Your ID's informations are checking. Please wait..."
        infoLabel.textColor = .white
        infoLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        view.addSubview(infoLabel)

 
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

       
        infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 24).isActive = true
    }
}



