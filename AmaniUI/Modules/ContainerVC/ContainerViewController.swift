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
  private var animationName : String?
  private var callback: VoidCallback?
  private var disappearCallback: VoidCallback?
  private var docStep:DocumentStepModel?
  private var lottieAnimationView:LottieAnimationView?
  private var step:steps = .front
    private var isDissapeared = false
    var stepConfig: StepConfig?

  @IBOutlet weak var btnContinue: UIButton!
  @IBOutlet weak var animationView: UIView!
  func bind(animationName:String?,
            docStep:DocumentStepModel,
            step:steps,
            callback: @escaping VoidCallback) {
    self.animationName = animationName
    self.callback = callback
    self.step = step
    self.docStep = docStep
  }
    
    lazy var titleDescription: UILabel = {
        let label = UILabel()
        label.text = stepConfig?.documents?[0].versions?[0].informationScreenDesc1 ?? "\(stepConfig?.documents?[0].versions?[0].steps?[0].captureDescription ?? "Click continue to take a photo within the specified area")"
        label.font = UIFont.systemFont(ofSize: 16.0, weight: .light)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor(hexString: "#20202F")
        return label
    }()
    
  func setDisappearCallback(_ callback: @escaping VoidCallback) {
    self.disappearCallback = callback
  }
  
  @IBAction func ActBtnContinue(_ sender: Any) {
      self.lottieAnimationView?.stop()
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
      lottieInit(name: name) {[weak self] _ in
  //      print(finishedAnimation)
        self?.callback!()
      }
    } else {
      lottieAnimationView?.removeFromSuperview()
      self.callback!()

    }

  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

      view.addSubview(titleDescription)
      titleDescription.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        titleDescription.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
        titleDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        titleDescription.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      ])
      
    let appBackground = try? Amani.sharedInstance.appConfig().getApplicationConfig().generalconfigs?.appBackground
    
    self.initialSetup()
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
        lottieAnimationView = .init(name: name,bundle: AmaniUI.sharedInstance.getBundle())
        //    lottieAnimationView!.frame = animationView.bounds
        lottieAnimationView!.backgroundColor = .clear
        lottieAnimationView!.contentMode = .scaleAspectFit
        lottieAnimationView!.translatesAutoresizingMaskIntoConstraints = false
        animationView.addSubview(lottieAnimationView!)
        NSLayoutConstraint.activate([
            lottieAnimationView!.centerXAnchor.constraint(equalTo: animationView.centerXAnchor),
            lottieAnimationView!.centerYAnchor.constraint(equalTo: animationView.centerYAnchor),
            lottieAnimationView!.widthAnchor.constraint(equalTo: animationView.widthAnchor),
            lottieAnimationView!.heightAnchor.constraint(equalTo: animationView.heightAnchor),
        ])
        
        lottieAnimationView?.bringSubviewToFront(view)
        lottieAnimationView!.play {[weak self] (_) in
            self?.lottieAnimationView!.removeFromSuperview()
            if let isdp = self?.isDissapeared, !isdp{
                completion(steps.front.rawValue)
            }
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
