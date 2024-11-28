//
//  File.swift
//  Demo
//
//  Created by Münir Ketizmen on 26.01.2022.
//

import UIKit
import AmaniSDK

final class SignatureViewController: BaseViewController {
    
    // MARK: Properties
  private var clearBtn = UIButton()
  private var confirmBtn = UIButton()

  let amani:Amani = Amani.sharedInstance
  var viewContainer:UIView?
  var stepCount:Int = 0
  var docStep:DocumentStepModel?
  var documentVersion: DocumentVersion?
  var callback:((UIImage)->())?

    @objc func confirmAct(_ sender: UIButton) {
        amani.signature().capture()
    }
    
    @objc func clearAct(_ sender: Any) {
        amani.signature().clear()
    }

  func start(docStep: AmaniSDK.DocumentStepModel, version: AmaniSDK.DocumentVersion, completion: ((UIImage)->())?) {
    guard let steps = version.steps else {return}
    stepCount = steps.count
    self.documentVersion = version
    self.docStep = docStep
    self.callback = completion
//    setupUI()
    

  }
   
    override func viewDidLoad() {
        super.viewDidLoad()
       setupUI()
       
    }
  
  override func viewWillAppear(_ animated: Bool) {
        do {
            let signature = amani.signature()
            signature.setViewArea(viewArea: view.bounds)
            
            signature.setConfirmButtonCallback {
              self.confirmBtn.isEnabled = true
            }
          
          signature.setOnConfirmPressedCallback { image, currentSignatureNo in
            print(image.cgImage?.width, image.cgImage?.height, currentSignatureNo)
          }
          
          guard let signatureView:UIView = try signature.start(stepId: stepCount, completion: { [weak self] (previewImage) in
                DispatchQueue.main.async {
                  guard let callback = self?.callback else {return}
                  callback(previewImage)
//                  callback(.success(self.stepViewModel))
//
//                    guard let previewVC:UIViewController  = self?.storyboard?.instantiateViewController(withIdentifier: "preview") else {return}
////                  ( previewVC as! DocConfirmationViewController).preImage = previewImage
//                    self?.navigationController?.pushViewController(previewVC, animated: true)
//                    self?.viewContainer?.removeFromSuperview()
                }
            }) else {return}
          
            DispatchQueue.main.async {
                self.viewContainer = signatureView
                self.view.addSubview(signatureView)
                self.view.bringSubviewToFront(self.confirmBtn)
                self.view.bringSubviewToFront(self.clearBtn)
            }
        }
        catch  {
            print("Unexpected error: \(error).")
        }
    }
  
    override func viewDidAppear(_ animated: Bool) {
    }
  
}

// MARK: Initial setup and setting constraints
extension SignatureViewController {
   private func setupUI() {
       DispatchQueue.main.async {
           let appConfig = try! Amani.sharedInstance.appConfig().getApplicationConfig()
           let buttonRadious = CGFloat(appConfig.generalconfigs?.buttonRadius ?? 10)
           
           
           // Navigation Bar
           self.setNavigationBarWith(title: self.docStep?.captureTitle ?? "", textColor: UIColor(hexString: appConfig.generalconfigs?.topBarFontColor ?? "ffffff"))
           self.setNavigationLeftButton(TintColor: appConfig.generalconfigs?.topBarFontColor ?? "ffffff")
           self.view.backgroundColor = UIColor(hexString: appConfig.generalconfigs?.appBackground ?? "#263B5B")
           self.confirmBtn.backgroundColor = UIColor(hexString: appConfig.generalconfigs?.primaryButtonBackgroundColor ?? ThemeColor.primaryColor.toHexString())
           self.confirmBtn.layer.borderColor = UIColor(hexString: appConfig.generalconfigs?.primaryButtonBorderColor ?? "#263B5B").cgColor
           self.confirmBtn.setTitle(appConfig.generalconfigs?.confirmText, for: .normal)
           self.confirmBtn.setTitleColor(UIColor(hexString: appConfig.generalconfigs?.primaryButtonTextColor ?? ThemeColor.whiteColor.toHexString()), for: .normal)
           self.confirmBtn.tintColor = UIColor(hexString: appConfig.generalconfigs?.primaryButtonTextColor ?? ThemeColor.whiteColor.toHexString())
           self.confirmBtn.addCornerRadiousWith(radious: buttonRadious)
           
           let secondaryBackgroundColor:UIColor = appConfig.generalconfigs?.secondaryButtonBackgroundColor == nil ? UIColor.clear :UIColor(hexString: (appConfig.generalconfigs?.secondaryButtonBackgroundColor)!)

           self.clearBtn.backgroundColor = secondaryBackgroundColor
           self.clearBtn.addBorder(borderWidth: 1, borderColor: UIColor(hexString: appConfig.generalconfigs?.secondaryButtonBorderColor ?? "#263B5B").cgColor)
           self.clearBtn.setTitle(self.documentVersion?.clearText ?? "Temizle", for: .normal)
           self.clearBtn.setTitleColor(UIColor(hexString: appConfig.generalconfigs?.secondaryButtonTextColor ?? ThemeColor.whiteColor.toHexString()), for: .normal)
           self.clearBtn.tintColor = UIColor(hexString: appConfig.generalconfigs?.secondaryButtonTextColor ?? ThemeColor.whiteColor.toHexString())
           self.clearBtn.addCornerRadiousWith(radious: buttonRadious)
           
           self.clearBtn.translatesAutoresizingMaskIntoConstraints = false
           self.confirmBtn.translatesAutoresizingMaskIntoConstraints = false
         
         
         self.clearBtn.addTarget(self, action: #selector(self.clearAct(_:)), for: .touchUpInside)
         self.confirmBtn.addTarget(self, action: #selector(self.confirmAct(_:)), for: .touchUpInside)
           
          
       }
      setConstraints()
        
  //    // For everything else
  //      imgOuterView.isHidden = false
  //      self.idImgView.image = image

  //      self.previewHeightConstraints.constant = (UIScreen.main.bounds.width - 46) * CGFloat((documentVersion?.aspectRatio!)!)
  //      self.previewHeightConstraints.isActive = true
  //      self.view.layoutIfNeeded()
  //      titleLabel.isHidden = false
  //      selfieImageView.isHidden = true
  //      physicalContractImageView.isHidden = true
  //
  //
    }
    
    private func setConstraints() {
        DispatchQueue.main.async {
            self.view.addSubviews(self.confirmBtn, self.clearBtn)
            
            NSLayoutConstraint.activate([
             self.clearBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40),
             self.confirmBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40),
              
             self.clearBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
             self.confirmBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
              
             self.clearBtn.trailingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -10),
             self.confirmBtn.leadingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 10),
              
             self.clearBtn.heightAnchor.constraint(equalToConstant: 50),
             self.confirmBtn.heightAnchor.constraint(equalTo: self.clearBtn.heightAnchor),
              
             self.clearBtn.widthAnchor.constraint(equalTo: self.confirmBtn.widthAnchor)
            ])
        }
    }
}
