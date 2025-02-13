import UIKit
import AmaniSDK
import MobileCoreServices
/**
 This class represents the KYC step list view
 */
@objc(KYCStepTblView)
class KYCStepTblView: UITableView {

    // MARK: - Local properties

    /// This property represents the rule selection callback
  fileprivate var callback: ((KYCStepViewModel) -> Void)?
  
    /// This property represents the list of KYC rules
  fileprivate var kycSteps: [KYCStepViewModel] = []
  
    // MARK: - Life cycle methods
    //    override func awakeFromNib() {
    //        self.delegate = self
    //        self.dataSource = self
    //        self.backgroundColor = .clear
    //    }
  
  override init(frame: CGRect, style: UITableView.Style) {
    super.init(frame: frame, style: style)
    self.delegate = self
    self.dataSource = self
    self.backgroundColor = .clear
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
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
        //      self.register(UINib(nibName: String(describing: KYCStepTableViewCell.self), bundle: AmaniUI.sharedInstance.getBundle()), forCellReuseIdentifier: String(describing: KYCStepTableViewCell.self))
        //      self.reloadData()
      self.register(KYCStepTableViewCell.self, forCellReuseIdentifier: String(describing: KYCStepTableViewCell.self))
      self.isScrollEnabled = false
      self.showsVerticalScrollIndicator = false
      self.showsHorizontalScrollIndicator = false
      self.separatorStyle = .none
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
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "KYCStepTableViewCell", for: indexPath) as? KYCStepTableViewCell else {
      return UITableViewCell()
    }
      //      guard let cell: KYCStepTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: KYCStepTableViewCell.self), for: indexPath) as? KYCStepTableViewCell else {
      //        return UITableViewCell()
      //      }
    
    let stepViewModel = self.kycSteps[indexPath.row]
    
    if !stepViewModel.isEnabled() {
      cell.bind(model: stepViewModel, alpha: 1, isEnabled: false)
    } else {
      cell.bind(model: stepViewModel, isEnabled: true)
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 73
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 73
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let step = self.kycSteps[indexPath.row]
    
    if self.kycSteps[indexPath.row].getRuleModel().documentClasses!.first == "IB" && !(self.kycSteps[indexPath.row].getRuleModel().status == "APPROVED")  {
        // Specify only PDF type
      let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: .import)
      documentPicker.delegate = self
      documentPicker.allowsMultipleSelection = false
      
      if let parentViewController = self.findViewController() {
        parentViewController.present(documentPicker, animated: true)
      }
    } else {
      guard let callback = callback else { return }
      if (step.status != DocumentStatus.APPROVED && step.status != DocumentStatus.PROCESSING && step.isEnabled()) {
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
}

extension KYCStepTblView: UIDocumentPickerDelegate {
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard let filePath = urls.first else { return }
    guard let step = self.kycSteps.first(where: { $0.getRuleModel().documentClasses?.first == "IB" }) else { return }
    
      // Check if the file is actually a PDF
    guard filePath.pathExtension.lowercased() == "pdf" else {
      print("Selected file is not a PDF")
      self.updateStatus(for: step, status: .NOT_UPLOADED)
      controller.dismiss(animated: true)
      return
    }
    
    do {
      let fileData = try Data(contentsOf: filePath)
      
      let documentsModule = Amani.sharedInstance.document()
      documentsModule.setType(type: step.getRuleModel().documentClasses?.first ?? "IB")
      
      let files = [FileWithType(data: fileData, dataType: acceptedFileTypes.pdf.rawValue)]
      
      self.updateStatus(for: step, status: .PROCESSING)
      
        // Upload the file
      documentsModule.upload(
        location: AmaniUI.sharedInstance.location,
        files: files) { [weak self] result, error in
          DispatchQueue.main.async {
            if result == true {
                // Success case
              self?.updateStatus(for: step, status: .APPROVED)
              
                // Call the callback
              guard let callback = self?.callback else { return }
              callback(step)
              
                // Dismiss and navigate back
              controller.dismiss(animated: true) {
                if let parentVC = self?.findViewController(),
                   let navigationController = parentVC.navigationController {
                  if let homeVC = navigationController.viewControllers.first(where: { $0 is HomeViewController }) {
                    navigationController.popToViewController(homeVC, animated: true)
                  }
                }
              }
            } else {
                // Error case
              self?.updateStatus(for: step, status: .NOT_UPLOADED)
              print("Upload failed: \(error ?? [:])")
              controller.dismiss(animated: true)
            }
          }
        }
      
    } catch {
      print("Error reading file data: \(error)")
      self.updateStatus(for: step, status: .NOT_UPLOADED)
      controller.dismiss(animated: true)
    }
  }
  
  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    print("Document picker cancelled")
    controller.dismiss(animated: true)
  }
  
  private func findViewController() -> UIViewController? {
    var responder: UIResponder? = self
    while let nextResponder = responder?.next {
      if let viewController = nextResponder as? UIViewController {
        return viewController
      }
      responder = nextResponder
    }
    return nil
  }
}
