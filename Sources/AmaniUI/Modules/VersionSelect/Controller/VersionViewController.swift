import UIKit
import AmaniSDK

/**
 The VersionViewController class is used to provide a user interface for version selection screen.
 */

class VersionViewController: BaseViewController {
    
  // MARK: - Properties
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15.0, weight: .light)
        return label
    }()
    
    private var versionSelectionTblView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var amaniLogo: UIImageView = {
       
        let imageView = UIImageView(image: UIImage(named: "ic_poweredBy", in: AmaniUI.sharedInstance.getBundle(), with: nil)?.withRenderingMode(.alwaysTemplate))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.tintAdjustmentMode = .normal
       
        return imageView
    }()

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
    self.setConstraints()
    self.setTableView()
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
    self.versionSelectionTblView.backgroundColor = UIColor(hexString: generalConfigs?.appBackground ?? "#EEF4FA")
    descriptionLabel.textColor = UIColor(hexString: textColor)
    amaniLogo.isHidden = generalConfigs?.hideLogo ?? false
    amaniLogo.tintColor = UIColor(hexString: textColor)
     
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
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "VersionSelectTableViewCell", for: indexPath) as? VersionSelectTableViewCell else {
          return UITableViewCell()
      }

    cell.bindViewWith(model: documentHandler!.versionList[indexPath.row])
    return cell
  }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 73
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 73
    }
    
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let runner = documentHandler else { return }
    
    let document: DocumentVersion = runner.versionList[indexPath.row]
    documentHandler?.onVersionPressed(version: document)
    
  }
  
}

extension VersionViewController {
    private func setTableView() {
        versionSelectionTblView.delegate = self
        versionSelectionTblView.dataSource = self
        versionSelectionTblView.register(VersionSelectTableViewCell.self, forCellReuseIdentifier: String(describing: VersionSelectTableViewCell.self))
        versionSelectionTblView.isScrollEnabled = false
        versionSelectionTblView.showsVerticalScrollIndicator = false
        versionSelectionTblView.showsHorizontalScrollIndicator = false
        versionSelectionTblView.separatorStyle = .none
        versionSelectionTblView.reloadData()
    }
    
    private func setConstraints() {
        
            self.view.addSubview(headerView)
            self.view.addSubview(descriptionLabel)
            self.view.addSubview(versionSelectionTblView)
            self.view.addSubview(amaniLogo)
            amaniLogo.tintColor = UIColor(hexString: "#D3D3D3")
            
            NSLayoutConstraint.activate([
                headerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
                headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                headerView.bottomAnchor.constraint(equalTo: self.descriptionLabel.topAnchor, constant: -40),
                headerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.059),
                
                descriptionLabel.topAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: 40),
                descriptionLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                descriptionLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
                descriptionLabel.bottomAnchor.constraint(equalTo: self.versionSelectionTblView.topAnchor, constant: -40),
                
                versionSelectionTblView.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 40),
                versionSelectionTblView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                versionSelectionTblView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
                versionSelectionTblView.bottomAnchor.constraint(equalTo: amaniLogo.topAnchor, constant: -20),
                
                amaniLogo.widthAnchor.constraint(equalToConstant: 114),
                amaniLogo.heightAnchor.constraint(equalToConstant: 13),
                amaniLogo.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                amaniLogo.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30)
                
            
            ])
        
    }
}
