import UIKit
import AmaniSDK
/**
 This class represents the KYC step list view
 */
class KYCStepTblView: UITableView {

    // MARK: - Local properties

    /// This property represents the rule selection callback
    fileprivate var callback: ((KYCStepViewModel) -> Void)?
    
    /// This property represents the list of KYC rules
    fileprivate var kycSteps: [KYCStepViewModel] = []

    // MARK: - Life cycle methods
    override func awakeFromNib() {
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = .clear
    }

    // MARK: - Helper methods
    /**
     This method bind the kyc list model with view
     - parameter array: [KYCRuleModel]
     - parameter onSelectCallback: rule selection callback
     */
  func showKYCStep(stepModels: [KYCStepViewModel], onSelectCallback: @escaping ((KYCStepViewModel?) -> Void)) {
    self.kycSteps = stepModels
    
    self.callback = onSelectCallback
    DispatchQueue.main.async {
      self.register(UINib(nibName: String(describing: KYCStepTableViewCell.self), bundle: Bundle(for: KYCStepTableViewCell.self)), forCellReuseIdentifier: String(describing: KYCStepTableViewCell.self))
      self.reloadData()
    }
    
  }
  
  func updateStatus(for step: KYCStepViewModel, status: DocumentStatus) {
    DispatchQueue.main.async {
      step.updateStatus(status: status)
      self.reloadData()
    }
  }
  
  func updateDataAndReload(stepModels: [KYCStepViewModel]) {
    
    DispatchQueue.main.async {
      self.kycSteps = stepModels
      self.reloadData()
    }
  }

}

// MARK: - Table view datasource and delegate methods
extension KYCStepTblView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.kycSteps.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      guard let cell: KYCStepTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: KYCStepTableViewCell.self), for: indexPath) as? KYCStepTableViewCell else {
        return UITableViewCell()
      }
      
      let stepViewModel = self.kycSteps[indexPath.row]
      if !stepViewModel.isEnabled() {
        cell.bind(model: stepViewModel, alpha: 0.5)
      } else {
        cell.bind(model: stepViewModel)
      }
      
     return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let step = self.kycSteps[indexPath.row]
      guard let callback = callback else { return }
      if (step.status != DocumentStatus.APPROVED && step.status != DocumentStatus.PROCESSING) {
        step.onStepPressed { result in
          switch result {
          case .failure(let error):
            print(error)
          case .success(let model):
            callback(model)
          }
        
        }
      }
    }
}
