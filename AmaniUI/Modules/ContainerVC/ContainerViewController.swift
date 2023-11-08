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
  
  func setDisappearCallback(_ callback: @escaping VoidCallback) {
    self.disappearCallback = callback
  }
  
  @IBAction func ActBtnContinue(_ sender: Any) {
    lottieAnimationView?.stop()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

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
    let appBackground = try? Amani.sharedInstance.appConfig().getApplicationConfig().generalconfigs?.appBackground
    
    self.initialSetup()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    // remove the sdk view on exiting by calling the callback
    print("Container View disappear")
    if let disappearCb = self.disappearCallback {
      disappearCb()
    }
    super.viewWillDisappear(animated)
  }
  
  func initialSetup() {
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
    lottieAnimationView!.frame = animationView.bounds
    lottieAnimationView!.backgroundColor = .clear
    animationView.addSubview(lottieAnimationView!)
    lottieAnimationView?.bringSubviewToFront(view)
    lottieAnimationView!.play {[weak self] (_) in
      self?.lottieAnimationView!.removeFromSuperview()
      completion(steps.front.rawValue)
    }
    
  }
  
}
