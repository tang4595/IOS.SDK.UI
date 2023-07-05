//
//  AmaniUIv1.swift
//  AmaniUIv1
//
//  Created by Deniz Can on 2.09.2022.
//

import AmaniSDK
import UIKit
import CoreLocation
private class AmaniBundleLocator {}

public class AmaniUIv1 {
public static let sharedInstance = AmaniUIv1()
  /// General Application Config
  /// This property represents the delegate methods.
  public weak var delegate: AmaniUIDelegate?
  public var country: String?
  public var nviData: NviModel?
  public var location: CLLocation?
  
  // MARK: - Private setups
  /// Home Screen is the initial view controller
  private var initialVC: HomeViewController?
  private var parentVC: UIViewController?
  
  /// Internal navigation controller.
  private var sdkNavigationController: UINavigationController?
  
  private var clientNavColor: UIColor?
  private var clientNavBackColor: UIColor?
  
  // MARK: - Internal configurations
  internal var config: AppConfigModel?
  internal let sharedSDKInstance = Amani.sharedInstance
  
  internal var useGeolocation: Bool?
  
  var missingRules:[[String:String]]? = nil
  
  private var bundle: Bundle!

  /**
   This method used to get SDK bundle
   - returns: Bundle
   */
  func getBundle() -> Bundle {
      return self.bundle
  }
  
  public init() {
      setBundle()
  }
  
  public func setNvi(nvi:NviModel){
    nviData = nvi
  }
  public func getNvi()->NviModel?{
    return nviData
  }
    
    /**
     This method set up the SDK bundle
     
     */
    private func setBundle() {
        if let bundle = Bundle(path: "AmaniUIv1.bundle") {
            self.bundle = bundle
        } else if let path = Bundle(for: AmaniBundleLocator.self).path(forResource: "AmaniUIv1", ofType: "bundle"),
                  let bundle = Bundle(path: path)  {
            self.bundle = bundle
        } else {
            let bundle = Bundle(for: AmaniBundleLocator.self)
            self.bundle = bundle
        }
    }
    
  
  /**
   This method set the SDK configuration
   - parameter server: Server
   - parameter token:String
   - parameter sharedSecret:String
   - parameter customer: CustomerRequestModel
   - parameter useGeoLocation:Bool
   - parameter language:String
   - parameter nviModel: NviModel? = nil
   - parameter country: String? = nil
   - parameter completion: (CustomerResponseModel, Error) -> ()
   */
  public func set(
    server: String,
    token: String,
    sharedSecret: String? = nil,
    customer: CustomerRequestModel,
    useGeoLocation: Bool = true,
    language: String = "tr",
    nviModel: NviModel? = nil,
    country: String? = nil,
    location: CLLocation? = nil,
    apiVersion:ApiVersions = .v2,
    completion: @escaping (CustomerResponseModel?, NetworkError?) -> ()
  ) {
    self.nviData = nviModel
    self.country = country
    self.location = location
    Amani.sharedInstance.initAmani(server: server, token: token, sharedSecret: sharedSecret, customer: customer, language: language,apiVersion: apiVersion) {(customerModel, error) in
      do {
        self.config = try Amani.sharedInstance.appConfig().getApplicationConfig()
      } catch let error {
        print("Error while fetching app configuration \(error)")
      }
      completion(customerModel, error)
    }
    
  }
  
   /**
   This method set the SDK configuration
   - parameter server: Server
   - parameter email: String
   - parameter password: String
   - parameter sharedSecret:String
   - parameter customer: CustomerRequestModel
   - parameter useGeoLocation:Bool
   - parameter language:String
   - parameter nviModel: NviModel?
   - parameter country: NviModel?
   - parameter completion: (CustomerResponseModel, Error) -> ()
   */
  public func set(
    server: String,
    userName: String,
    password: String,
    sharedSecret: String? = nil,
    customer: CustomerRequestModel,
    useGeoLocation: Bool = true,
    language: String = "tr",
    nviModel: NviModel? = nil,
    country: String? = nil,
    location: CLLocation? = nil,
    apiVersion:ApiVersions = .v2,
    completion: @escaping (CustomerResponseModel?, NetworkError?) -> ()
  ) {
    self.nviData = nviModel
    self.country = country
    self.location = location

    sharedSDKInstance.initAmani(server: server, userName: userName, password: password, sharedSecret: sharedSecret, customer: customer, language: language,apiVersion: apiVersion) {(customerModel, error) in

        Amani.sharedInstance.appConfig().fetchAppConfig(completion: { [weak self] config, error in
          if error == nil {
            self?.config = config

          } else {
            print("Error while fetching app configuration \(error)")
          }
        })
      completion(customerModel, error)
    }
  }
  
  public func showSDK(on parentViewController: UIViewController) {
    parentVC = parentViewController
    
    // Updating the configuration for cases like if user exits the sdk view and restarts the KYC process
    updateConfig { [weak self] () in
      guard let self else {return}
      DispatchQueue.main.async {
        self.initialVC = HomeViewController(nibName: String(describing: HomeViewController.self), bundle: Bundle(for: HomeViewController.self))
        
        self.sharedSDKInstance.setDelegate(delegate: self.initialVC!)

        
        self.sdkNavigationController = UINavigationController(rootViewController: self.initialVC!)
        self.sdkNavigationController?.modalPresentationStyle = .fullScreen
        if let navController = parentViewController.navigationController {
          self.clientNavColor = navController.navigationBar.barTintColor
          self.clientNavBackColor = navController.navigationBar.backgroundColor
        }
        
        // Setting the app theme here will ensure it runs correctly on the first time. Otherwise it won't have the correct theme
        // on launch
        /// TODO: Make this patch on original v1 code.
        self.setAppTheme(model: self.config?.generalconfigs!, onVC: self.initialVC!)
        
        // Adding shadow to NavigationBar
        self.sdkNavigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.sdkNavigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.sdkNavigationController?.navigationBar.layer.shadowRadius = 4.0
        self.sdkNavigationController?.navigationBar.layer.shadowOpacity = 0.4
        self.sdkNavigationController?.navigationBar.layer.masksToBounds = false
        
        // Show the SDK!
        parentViewController.present(self.sdkNavigationController!, animated: true)
      }
    }


  }
  
  public func setDelegate(delegate: AmaniUIDelegate) {
    self.delegate = delegate
  }
  
  @objc
  public func popViewController() {
    let customer = Amani.sharedInstance.customerInfo().getCustomer()
    guard let customerId:String = customer.id else {return}
    
    if let missingRules = missingRules {
      self.delegate?.onKYCFailed(CustomerId: customerId, Rules: missingRules)
    }
    guard let sdkNavigationController = sdkNavigationController else { return }
    sdkNavigationController.dismiss(animated: true)
  }
  
  // MARK: - internal methods
  internal func updateConfig(cb:@escaping VoidCallback) {
    Amani.sharedInstance.appConfig().fetchAppConfig {[weak self] (newConfig, error) in
      if let newConfig = newConfig {
        if let self = self {
          self.config = newConfig
          cb()
        }
      } else {
        if let error = error {
          print("Failed to update the application configuration. Reason: \(String(describing: error.error_code)): \(String(describing: error.error_message))")
        }
      }
    }
  }
  
  /**
   This method set up the app theme color
   */
  internal func setAppTheme(model: GeneralConfig?, onVC: HomeViewController) {
    guard let model = model else {
      return
    }
    
    guard let navigationController = sdkNavigationController else {
      return
    }
    
    DispatchQueue.main.async {
      if #available(iOS 13.0, *) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hexString: model.topBarBackground ?? "0F2435")
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: model.topBarFontColor ?? "000000")]
        navigationController.navigationBar.standardAppearance = appearance;
        navigationController.navigationBar.scrollEdgeAppearance = appearance
      } else {
        navigationController.navigationBar.backgroundColor = UIColor(hexString: (model.topBarBackground ?? "000000"))
        navigationController.navigationBar.barTintColor = UIColor(hexString: model.topBarBackground ?? "0F2435")
        navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: model.topBarFontColor ?? "000000")]
      }
      
      onVC.view.backgroundColor = UIColor(hexString: model.appBackground ?? "253C59")
      
      onVC.setNavigationLeftButton(TintColor: model.topBarFontColor ?? "000000")
      
      onVC.setNavigationBarWith(title: model.mainTitleText!, textColor: UIColor(hexString: model.topBarFontColor ?? "000000"))
//      onVC.headView.layer.cornerRadius = 25
      onVC.headView.backgroundColor = UIColor(hexString: model.appBackground ?? "0F2435")
      onVC.setBackgroundColorOfTableView(color: UIColor(hexString: model.appBackground ?? "253C59"))
    }
  }
  
}
//extension AmaniUIv1:AmaniDelegate{
//  
//  public func onProfileStatus(customerId:String, profile: AmaniSDK.wsProfileStatusModel) {
//    print(profile)
//  }
//  
//  public func onStepModel(customerId:String, rules: [AmaniSDK.KYCRuleModel]?) {
//    print(rules)
//    guard let rules = rules else {return}
//    missingRules = rules.filter{
//      $0.status! != DocumentStatus.APPROVED.rawValue ||
//      $0.status! != DocumentStatus.PENDING_REVIEW.rawValue}
//      .map { (rule) -> [String:String] in
//      return [rule.title!:rule.status!]
//  }
//  
//  }
//  
//}
