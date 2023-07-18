import UIKit
import AmaniSDK
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    self.initialSetUp()
    viewAppeared = true
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
    AmaniUIv1.sharedInstance.popViewController()
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
      let viewModels = rules.map { ruleModel in
        let stepModel = stepConfig.first { $0.id == ruleModel.id }
        return KYCStepViewModel(from: stepModel!, initialRule: ruleModel, topController: self)
      }
      stepModels = viewModels.sorted { $0.sortOrder < $1.sortOrder }
    } else {
      rules.map { ruleModel in
        let stepModel = stepConfig.first { $0.id == ruleModel.id }
        if let stepID = stepModels?.firstIndex{$0.id == ruleModel.id} {
          stepModels?.remove(at: stepID)
          stepModels?.append(KYCStepViewModel(from: stepModel!, initialRule: ruleModel, topController: self))
        }
        //      return KYCStepViewModel(from: stepModel!, initialRule: ruleModel, topController: self)
      }
      stepModels = stepModels?.sorted{ $0.sortOrder < $1.sortOrder }
    }
    
    
    
  }
  
  func setBackgroundColorOfTableView(color: UIColor) {
    self.kycStepTblView.backgroundColor = color
  }
  
  public func bind(customerData: CustomerResponseModel) {
    self.customerData = customerData
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
      kycStepTblViewModel!.upload { (result, errors) in
        if result == true {
          print("upload success")
        } else if let errors = errors {
          
          print(errors)
        }
      }
    })
  }
  
  func goToSuccess() {
    DispatchQueue.main.async {
      let successVC = SuccessViewController(nibName: String(describing: SuccessViewController.self), bundle: Bundle(for: SuccessViewController.self))
      self.navigationController?.pushViewController(successVC, animated: false)
    }
  }
}
extension HomeViewController:AmaniDelegate{
  func onProfileStatus(customerId:String, profile: AmaniSDK.wsProfileStatusModel) {
    print(profile)
    if (profile.status?.uppercased() == ProfileStatus.PENDING_REVIEW.rawValue || profile.status?.uppercased() == ProfileStatus.APPROVED.rawValue) {
      goToSuccess()
      return
    }
  }
  
  func onStepModel(customerId:String, rules: [AmaniSDK.KYCRuleModel]?) {
    // CHECK RULES AND OPEN SUCCESS SCREEN
    // Reload customer when upload is complete
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
