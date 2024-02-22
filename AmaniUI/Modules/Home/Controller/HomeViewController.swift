import UIKit
import AmaniSDK
import CoreNFC

/**
 The HomeViewController class is used to provide a user interface for home/main screen.
 */
class HomeViewController: BaseViewController {
  
  var viewAppeared:Bool = false
  @IBOutlet private weak var kycStepTblView: KYCStepTblView!
  @IBOutlet weak var amaniLogo:UIImageView!
  
  @IBOutlet weak var headView: UIView!
  var stepModels: [KYCStepViewModel]?
  var customerData: CustomerResponseModel? = nil
  
  var nonKYCStepManager: NonKYCStepManager? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    NotificationCenter.default.addObserver(self, selector: #selector(didReceiveStepModel), name: Notification.Name(
      AppConstants.AmaniDelegateNotifications.onStepModel.rawValue
    ), object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(didReceiveProfileStatus), name: NSNotification.Name(
      AppConstants.AmaniDelegateNotifications.onProfileStatus.rawValue
    ), object: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    self.initialSetUp()
    viewAppeared = true
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    NotificationCenter.default.removeObserver(self)
    if !isMovingFromParent && !((self.navigationController?.viewControllers.count)! > 1) {
      AmaniUI.sharedInstance.popViewController()
    }
  }
  
  // MARK: - Initial setup methods
  private func initialSetUp() {
    var customerInfo = Amani.sharedInstance.customerInfo().getCustomer()
    if (customerInfo.rules != nil && customerInfo.rules!.isEmpty) {
      if let customerResp = self.customerData {
        customerInfo = customerResp
      }
    }
    if(stepModels == nil) {
      guard let rules = customerInfo.rules else {
        return
      }
      
      try? generateKYCStepViewModels(from: rules)
    }
    self.setCustomerInfo(model: customerInfo)
    if (customerInfo.status?.uppercased() == ProfileStatus.PENDING_REVIEW.rawValue || customerInfo.status?.uppercased() == ProfileStatus.APPROVED.rawValue) {
      goToSuccess()
      return
    }
    
  }
  
  // MARK: - Actions
  /**
   This method used to pop put the controller. For example back button pressed to exit the SDK screen.
   */
  override func popViewController() {
    AmaniUI.sharedInstance.popViewController()
  }
  
  func checkStatus(model: CustomerResponseModel) -> Bool{
    let rules = model.rules ?? []
    for kycRule in rules{
      if kycRule.status! != DocumentStatus.APPROVED.rawValue && kycRule.status! != DocumentStatus.PENDING_REVIEW.rawValue {
        return false
      }
    }
    return true
  }
  
  func generateKYCStepViewModels(from rules: [KYCRuleModel]) throws {
    guard let stepConfig = try? Amani.sharedInstance.appConfig().getApplicationConfig().stepConfig else {
      throw AppConstants.AmaniError.ConfigError
    }
    
    if stepModels == nil {
      let viewModels: [KYCStepViewModel?] = rules.map { ruleModel in
        if var stepModel = stepConfig.first(where: { $0.id == ruleModel.id }) {
          // Remove the OT as this SDK doesn't have to do anything with it
          stepModel.documents?.removeAll(where: { $0.id == "OT" })
          
          if stepModel.documents?.contains(where: { $0.id == "NF" }) == true && !NFCNDEFReaderSession.readingAvailable {
            return nil
          }
          
          // Add only if the identifer equals to kyc
          if stepModel.identifier == "kyc" {
            return KYCStepViewModel(from: stepModel, initialRule: ruleModel, topController: self)
          }
          
          return nil
        } else {
          return nil
        }
      }
      
      
      let filteredViewModels = viewModels.filter { $0 != nil && !($0?.isHidden ?? false)} as! [KYCStepViewModel]
      stepModels = filteredViewModels.sorted { $0.sortOrder < $1.sortOrder }
    } else {
      rules.forEach { ruleModel in
        if let stepModel = stepConfig.first(where: { $0.id == ruleModel.id }) {
          if let stepID = stepModels?.firstIndex(where: {$0.id == ruleModel.id}) {
            stepModels?.remove(at: stepID)
            stepModels?.append(KYCStepViewModel(from: stepModel, initialRule: ruleModel, topController: self))
          }
        }
      }
      stepModels = stepModels?.sorted{ $0.sortOrder < $1.sortOrder }
    }
    
    
    
  }
  
  func setBackgroundColorOfTableView(color: UIColor) {
    self.kycStepTblView.backgroundColor = color
  }
  
  public func bind(customerData: CustomerResponseModel, nonKYCManager: NonKYCStepManager? = nil) {
    self.customerData = customerData
    self.nonKYCStepManager = nonKYCManager
  }
  
}

// MARK: - HomeViewDelegate methods
extension HomeViewController {
  
  /**
   This method renders the rules, and uploads the document.
   */
  func setCustomerInfo(model: CustomerResponseModel) {
    
    kycStepTblView.showKYCStep(stepModels: stepModels!, onSelectCallback: { kycStepTblViewModel in
      self.kycStepTblView.updateStatus(for: kycStepTblViewModel!, status: .PROCESSING)
      kycStepTblViewModel!.upload { (result,args) in
//        if result == true {
//          print("upload success")
//        } else if let errors = errors {
//          
//          print(errors)
//        }
      }
    })
  }
  
  func goToSuccess() {
    
    if let nonKYCManager = self.nonKYCStepManager, nonKYCManager.hasPostSteps() {
        nonKYCManager.startFlow(forPreSteps: false) {_ in
          DispatchQueue.main.async {
            let successVC = SuccessViewController(nibName: String(describing: SuccessViewController.self), bundle: Bundle(for: SuccessViewController.self))
            self.navigationController?.pushViewController(successVC, animated: true)
          }
        }
    } else {
      DispatchQueue.main.async {
        let successVC = SuccessViewController(nibName: String(describing: SuccessViewController.self), bundle: Bundle(for: SuccessViewController.self))
        self.navigationController?.pushViewController(successVC, animated: false)
      }  
    }
  }
  
  @objc
  func didReceiveStepModel(_ notification: Notification) {
    if let rules = (notification.object as? [Any?])?[1] as? [KYCRuleModel] {
      self.onStepModel(rules: rules)
    }
  }
  
  @objc
  func didReceiveProfileStatus(_ notification: Notification) {
    if let profileStatusModel = (notification.object as? [Any?])?[1] as?
        AmaniSDK.wsProfileStatusModel {
      self.onProfileStatus(profile: profileStatusModel)
    }
  }
  
  
}

extension HomeViewController {
  
  func onProfileStatus(profile: AmaniSDK.wsProfileStatusModel) {
    if (profile.status?.uppercased() == ProfileStatus.PENDING_REVIEW.rawValue || profile.status?.uppercased() == ProfileStatus.APPROVED.rawValue) {
      goToSuccess()
      return
    }
  }
  
  func onStepModel(rules: [AmaniSDK.KYCRuleModel]?) {
    // CHECK RULES AND OPEN SUCCESS SCREEN
    // Reload customer when upload is complete
    print("on stepmodel \(rules)")
    if viewAppeared{
      guard let kycStepTblView = kycStepTblView else {return}
      guard let rules = rules else {
        return
      }
      print(rules)
      
      try? self.generateKYCStepViewModels(from: rules)
      guard let stepModels = stepModels else {return}
      self.kycStepTblView.updateDataAndReload(stepModels: stepModels)
    }
  }
  
}
