import UIKit
import AmaniSDK

/**
 The VersionViewController class is used to provide a user interface for version selection screen.
 */
class VersionViewController: BaseViewController {
  
  // MARK: - IBOutlets
  @IBOutlet weak var versionSeclectionTblView: UITableView!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var amaniLogo:UIImageView!
  
  // MARK: - Local properties
  
  /// This property holds the current instance of DocumentRunnerHelper
  var documentHandler: DocumentHandlerHelper?
  
  /// This property represents the Document title
  var docTitle: String = ""
  
  /// This property represents the Document description
  var docDescription: String = ""
  
  /// This property represents the step of the Document Belongs to
  var stepVM: KYCStepViewModel!
  
  // MARK: - Life cycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    self.initialSetUp()
  }
  
  // MARK: - initial set up methods
  /**
   This method used to set up initial state on view
   */
  func initialSetUp() {
    let generalConfigs = try! Amani.sharedInstance.appConfig().getApplicationConfig().generalconfigs
    let navFontColor = generalConfigs?.topBarFontColor ?? "ffffff"
    let textColor =  generalConfigs?.appFontColor ?? "ffffff"
    
    self.setNavigationBarWith(title: self.docTitle,textColor: UIColor(hexString: navFontColor))
    self.setNavigationLeftButton(TintColor: navFontColor)
    self.descriptionLabel.text = docDescription
    descriptionLabel.textColor = UIColor(hexString: textColor)
    amaniLogo.isHidden = generalConfigs?.hideLogo ?? false
    amaniLogo.tintColor = UIColor(hexString: textColor)
    versionSeclectionTblView.delegate = self
    versionSeclectionTblView.dataSource = self
    versionSeclectionTblView.register(UINib(nibName: String(describing: VersionSelectTableViewCell.self), bundle: Bundle(for: VersionViewController.self)), forCellReuseIdentifier: String(describing: VersionSelectTableViewCell.self))
    versionSeclectionTblView.reloadData()
  }
  
  // MARK: - Helper methods
  func bind(runnerHelper: DocumentHandlerHelper, docTitle: String, docDescription: String, step: KYCStepViewModel) {
    self.documentHandler = runnerHelper
    self.docTitle = docTitle
    self.docDescription = docDescription
    self.stepVM = step
  }
}

// MARK: - Table view datasource and delegate methods
extension VersionViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.documentHandler!.versionList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VersionSelectTableViewCell.self), for: indexPath) as? VersionSelectTableViewCell else {
      return UITableViewCell()
    }
    cell.bindViewWith(model: documentHandler!.versionList[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let runner = documentHandler else { return }
    
    let document: DocumentVersion = runner.versionList[indexPath.row]
    documentHandler?.onVersionPressed(version: document)
    
  }
  
}
