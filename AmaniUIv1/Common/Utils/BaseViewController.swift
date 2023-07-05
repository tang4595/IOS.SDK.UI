//
//  BaseViewController.swift
//  AmaniUIv1
//
//  Created by Deniz Can on 6.09.2022.
//

import UIKit
import CoreLocation
import AmaniSDK

/**
 Base controller for all view controllers
 */
class BaseViewController: UIViewController {
  
//  let orientation: UIInterfaceOrientationMask = .portrait
  var navBarFontColor: String = "000000"
  var navbarRightButtonAction:VoidCallback? = nil

  override open var shouldAutorotate: Bool {
    return true
  }
  
//  override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//    return orientation
//  }
  
//  func rotateScreen(orientation: UIInterfaceOrientationMask) {
//    // turn screen to portrait mode
//    UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
//    UINavigationController.attemptRotationToDeviceOrientation()
//  }
  
  /// The **locationManager** is a refernce of CLLocationManager which helps in determining location of user
//  let locationManager = CLLocationManager()
  
  /// The configuration of the SDK.
  
  // MARK: - Life cycle methods
  
  override func viewDidLoad() {
    
//    rotateScreen(orientation: orientation)
    self.navigationController?.delegate = self
    
    super.viewDidLoad()
//    self.locationManager.delegate = self
    
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    self.baseSetup()
  }
  
  // MARK: Set up methods
  /**
   This method set up all the commmon initial feature of a controller
   */
  private func baseSetup() {
    self.setThemeColor()
    self.navigationController?.navigationBar.isHidden = false
    if #available(iOS 13.0, *) {
      overrideUserInterfaceStyle = .light
    }
  }
  
  func setNavigationLeftButton(TintColor:String? = nil) {
    let leftButton: UIButton = UIButton(type: .custom)
    leftButton.setImage(UIImage(named: "ic_backArrow", in: Bundle(for: HomeViewController.self), compatibleWith: nil), for: .normal)
    leftButton.tintColor = UIColor(hexString: TintColor ?? navBarFontColor)
    leftButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
    leftButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
    leftButton.backgroundColor = .clear
    leftButton.addTarget(self, action: #selector(popViewController), for: .touchUpInside)
    let backBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: leftButton)
    self.navigationItem.leftBarButtonItem = backBarButtonItem
  }
  
  @objc func popViewController() {
    self.navigationController?.popViewController(animated: true)
  }
  
  @objc func selectorFunc() {
    if let navbarRightButtonAction = navbarRightButtonAction  {
      navbarRightButtonAction()
    }
  }
  
  func setRightNavBarButtonAction(cb:@escaping VoidCallback) {
    
    navbarRightButtonAction = cb
  }
  
  func setNavigationRightButton(text:String = "Elle Kırp", TintColor:String? = nil) {
    let rightButton: UIButton = UIButton(type: .custom)
    rightButton.setTitle(text,for: .normal)
    rightButton.setTitleColor(UIColor(hexString: TintColor ?? navBarFontColor), for: .normal)
    //        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
    //        rightButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
    rightButton.backgroundColor = .clear
      rightButton.addTarget(self, action: #selector(selectorFunc), for: .touchUpInside)
    let manualCropBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: rightButton)
    self.navigationItem.rightBarButtonItem = manualCropBarButtonItem
    
  }
  
  /**
   This method used to set navigation title
   - parameter title: String
   */
  func setNavigationBarWith(title: String,textColor:UIColor? = nil) {
    self.navigationItem.title = title
    
    if #available(iOS 13.0, *) {
      let appearance = UINavigationBarAppearance()
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = self.navigationController?.navigationBar.standardAppearance.backgroundColor
      appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: textColor ?? UIColor(hexString: navBarFontColor)]
      self.navigationController?.navigationBar.standardAppearance = appearance;
      self.navigationController?.navigationBar.scrollEdgeAppearance =  self.navigationController?.navigationBar.standardAppearance
      
    } else {
      self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: textColor ?? UIColor(hexString: navBarFontColor)]
    }
  }
  
  /**
   This method set up the theme color
   */
  func setThemeColor() {
    let config = AmaniUIv1.sharedInstance.config
    
    
    navBarFontColor = config?.generalconfigs?.topBarFontColor ?? "000000"
    if #available(iOS 13.0, *) {
      let appearance = UINavigationBarAppearance()
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = UIColor(hexString: config?.generalconfigs?.topBarBackground ?? "0F2435")
      appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: navBarFontColor)]
      self.navigationController?.navigationBar.standardAppearance = appearance;
      self.navigationController?.navigationBar.scrollEdgeAppearance =  self.navigationController?.navigationBar.standardAppearance
      self.navigationController?.navigationBar.isTranslucent = true
    } else {
      self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString:navBarFontColor)]
      self.navigationController?.navigationBar.barTintColor = UIColor(hexString: config?.generalconfigs?.topBarBackground ?? "0F2435")
    }
    self.view.backgroundColor = UIColor(hexString: config?.generalconfigs?.appBackground ?? "253C59")
    self.navigationController?.navigationBar.backgroundColor = UIColor(hexString: config?.generalconfigs?.topBarBackground ?? "0F2435")
    
  }
  
  func setToolBar() -> UIToolbar {
    let config = AmaniUIv1.sharedInstance.config
    
    let toolBar = UIToolbar()
    toolBar.barStyle = UIBarStyle.default
    toolBar.isTranslucent = true
    toolBar.tintColor = .black
    toolBar.sizeToFit()
    
    let doneButton = UIBarButtonItem(title: config?.generalconfigs!.okText ?? "Tamam", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePressOnPicker))
    let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    toolBar.setItems([spaceButton, doneButton], animated: false)
    toolBar.isUserInteractionEnabled = true
    return toolBar
  }
  
  // MARK: - Actions
  /**
   This action used to pop out the controller on click of navigation back button
   */
  
  
  @objc func donePressOnPicker() {
    self.view.endEditing(true)
  }
  
 
}

extension BaseViewController {
 
  /**
   This method used to show error prompts
   - parameter error: BPError
   */
  func showError(error: NetworkError) {
    print(error)
    let generalConfigs = try? Amani.sharedInstance.appConfig().getApplicationConfig().generalconfigs
    if (error.error_code != 10500) {
      DispatchQueue.main.async {
        AlertDialogueUtility.shared.showMsgAlertWithHandler(controller: self, alertTitle: "", message: error.error_message ?? "", successTitle: (generalConfigs?.okText ?? "Tamam")!, success: { (_: UIAlertAction) in
          self.navigationController?.dismiss(animated: true, completion: nil)
                      self.navigationController?.popToRootViewController(animated: true)
        }, failureTitle: nil, failure: nil)
      }
      
    }
  }
  
}

extension  BaseViewController: UINavigationControllerDelegate {
  public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
    return navigationController.topViewController!.supportedInterfaceOrientations
  }
  
}
