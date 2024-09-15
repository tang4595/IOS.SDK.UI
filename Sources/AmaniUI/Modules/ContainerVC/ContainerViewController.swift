//
//  AnimationViewController.swift
//  AmaniUIv1
//
//  Created by Münir Ketizmen on 7.01.2023.
//

import Lottie
import UIKit
import AmaniSDK

class ContainerViewController: BaseViewController {
    // MARK: Properties
    private lazy var btnContinue: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    private lazy var animationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var titleDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = stepConfig?.documents?[0].versions?[0].informationScreenDesc1 ?? "\(stepConfig?.documents?[0].versions?[0].steps?[0].captureDescription ?? "Click continue to take a photo within the specified area")"
        label.font = UIFont.systemFont(ofSize: 16.0, weight: .light)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor(hexString: "#20202F")
        return label
    }()
    
    
  private var animationName : String?
  private var callback: VoidCallback?
  private var disappearCallback: VoidCallback?
  private var docStep:DocumentStepModel?
  private var lottieAnimationView:LottieAnimationView?
  private var step:steps = .front
  private var isDissapeared = false
  var stepConfig: StepConfig?
    

//  @IBOutlet weak var btnContinue: UIButton!
//  @IBOutlet weak var animationView: UIView!
  func bind(animationName:String?,
            docStep:DocumentStepModel,
            step:steps,
            callback: @escaping VoidCallback) {
    self.animationName = animationName
    self.callback = callback
    self.step = step
    self.docStep = docStep
  }
    
   
    
  func setDisappearCallback(_ callback: @escaping VoidCallback) {
    self.disappearCallback = callback
  }
    
  @objc func actBtnContinue(_ sender: Any) {
        self.lottieAnimationView?.stop()
    }
  
    override func viewDidLoad() {
      super.viewDidLoad()
      self.initialSetup()
      
      self.setConstraints()
      self.btnContinue.addTarget(self, action: #selector(actBtnContinue(_:)), for: .touchUpInside)
    }
    
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
      
      isDissapeared = false

    if let animationName = animationName {
      var side:String = "front"
      switch step {
      case .front:
        side = "front"
        break
      case .back:
        side = "back"
        break
      default:
        side = "front"
        break
      }
      var name = "\((animationName.lowercased()))_\(side)"
      
      if ((AmaniUI.sharedInstance.getBundle().url(forResource: name, withExtension: "json")?.isFileURL) == nil) {
        name = "xx_id_0_\(side)"
      }
        DispatchQueue.main.async {
            self.lottieInit(name: name) {[weak self] _ in
        //      print(finishedAnimation)
              self?.callback!()
            }
        }
    
    } else {
      lottieAnimationView?.removeFromSuperview()
      self.callback!()

    }

  }
  

    
  override func viewWillDisappear(_ animated: Bool) {
    // remove the sdk view on exiting by calling the callback
    print("Container View disappear")
    if let disappearCb = self.disappearCallback {
      disappearCb()
    }
      isDissapeared = true
    super.viewWillDisappear(animated)
  }
  
 
  
}
extension ContainerViewController {
   
    
    func initialSetup() {
      if AmaniUI.sharedInstance.isEnabledClientSideMrz {
        Amani.sharedInstance.setMRZDelegate(delegate: self)
      }
      let appConfig = try! Amani.sharedInstance.appConfig().getApplicationConfig()
      let buttonRadious = CGFloat(appConfig.generalconfigs?.buttonRadius ?? 10)

      // Navigation Bar
      self.setNavigationBarWith(title: docStep?.captureTitle ?? "", textColor: UIColor(hexString: appConfig.generalconfigs?.topBarFontColor ?? "ffffff"))
      self.setNavigationLeftButton(TintColor: appConfig.generalconfigs?.topBarFontColor ?? "ffffff")
      self.view.backgroundColor = UIColor(hexString: appConfig.generalconfigs?.appBackground ?? "#263B5B")
      btnContinue.backgroundColor = UIColor(hexString: appConfig.generalconfigs?.primaryButtonBackgroundColor ?? ThemeColor.primaryColor.toHexString())
      btnContinue.layer.borderColor = UIColor(hexString: appConfig.generalconfigs?.primaryButtonBorderColor ?? "#263B5B").cgColor
      btnContinue.setTitle(appConfig.generalconfigs?.continueText, for: .normal)
      btnContinue.setTitleColor(UIColor(hexString: appConfig.generalconfigs?.primaryButtonTextColor ?? ThemeColor.whiteColor.toHexString()), for: .normal)
      btnContinue.tintColor = UIColor(hexString: appConfig.generalconfigs?.primaryButtonTextColor ?? ThemeColor.whiteColor.toHexString())
      btnContinue.addCornerRadiousWith(radious: buttonRadious)
      
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
      private func lottieInit(name:String = "xx_id_0_front", completion:@escaping(_ finishedAnimation:Int)->()) {
          
          guard let animation = LottieAnimation.named(name, bundle: AmaniUI.sharedInstance.getBundle()) else {
                    print("Lottie animation not found")
                    return
                }

        self.lottieAnimationView = LottieAnimationView(animation: animation)
        guard let lottieAnimationView = self.lottieAnimationView else {
            print("Failed to create Lottie animation view")
            return
        }

          lottieAnimationView.frame = animationView.bounds
          lottieAnimationView.backgroundColor = .clear
          lottieAnimationView.contentMode = .scaleAspectFit
          lottieAnimationView.translatesAutoresizingMaskIntoConstraints = false
          DispatchQueue.main.async {
              self.view.addSubview(self.animationView)
              self.animationView.addSubview(self.lottieAnimationView!)
              NSLayoutConstraint.activate([
                self.animationView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
                self.animationView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
                self.animationView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
                self.animationView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
                
                self.lottieAnimationView!.leadingAnchor.constraint(equalTo: self.animationView.leadingAnchor),
                self.lottieAnimationView!.trailingAnchor.constraint(equalTo: self.animationView.trailingAnchor),
                self.lottieAnimationView!.topAnchor.constraint(equalTo: self.animationView.topAnchor),
                self.lottieAnimationView!.bottomAnchor.constraint(equalTo: self.animationView.bottomAnchor)
              ])
              
              self.animationView.bringSubviewToFront(self.view)
              self.lottieAnimationView!.play {[weak self] (_) in
                  self?.lottieAnimationView!.removeFromSuperview()
                  if let isdp = self?.isDissapeared, !isdp{
                      completion(steps.front.rawValue)
                  }
              }
          }
      }
    
    private func setConstraints() {
        DispatchQueue.main.async {
            self.view.addSubview(self.titleDescription)
            self.view.addSubview(self.btnContinue)
//            self.view.addSubview(self.animationView)
            
            NSLayoutConstraint.activate([
                self.titleDescription.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8),
                self.titleDescription.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                self.titleDescription.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                
                self.btnContinue.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                self.btnContinue.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                self.btnContinue.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                self.btnContinue.heightAnchor.constraint(equalToConstant: 50),
                
//                self.animationView.topAnchor.constraint(equalTo: self.titleDescription.bottomAnchor, constant: 40),
//                self.animationView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
//                self.animationView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
//                self.animationView.bottomAnchor.constraint(equalTo: self.btnContinue.topAnchor, constant: -40)
            ])
        }
      
    }
}



extension ContainerViewController: mrzInfoDelegate {
  func mrzInfo(_ mrz: AmaniSDK.MrzModel?, documentId: String?) {
    print("MRZ INFO DELEGATE'E GELDI")
    if let mrzData = mrz {
      var isReady: Bool = false
      switch AmaniUI.sharedInstance.apiVersion {
      case .v1:
        isReady = true
      case .v2:
        if AmaniUI.sharedInstance.isEnabledClientSideMrz {
          isReady = true
        }
      default:
        break
      }
      
      if isReady {
        AmaniUI.sharedInstance.nviData = NviModel(mrzModel: mrzData)
      }
    } else {
//      DispatchQueue.main.async {
//        var actions: [(String, UIAlertAction.Style)] = []
//        
//        let title = self.appConfig?.generalconfigs?.tryAgainText
//        let buttonTitle = self.appConfig?.generalconfigs?.okText
//        let message = self.documentVersion?.mrzReadErrorText
//        
//        actions.append(("\(buttonTitle ?? "Re-try")", UIAlertAction.Style.default))
//        
//        AlertDialogueUtility.shared.showAlertWithActions(vc: self, title: title, message: message, actions: actions) { index in
//          if index == 0 {
//            self.dismissAnimationView()
//            self.popViewController()
//          }
//        }
//      }
      
    }
  }
}
