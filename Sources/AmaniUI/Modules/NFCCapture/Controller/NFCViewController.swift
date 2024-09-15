import AmaniSDK
import UIKit

typealias VoidCallback = () -> Void

@available(iOS 13, *)
class NFCViewController: BaseViewController {
    // MARK: Properties
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 22.0, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("CONTINUE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        
        return button
    }()
    
    private lazy var labelsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var desc1Label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .light)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private lazy var desc2Label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .light)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private lazy var desc3Label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .light)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private lazy var amaniLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_poweredBy", in: AmaniUI.sharedInstance.getBundle(), with: nil)?.withRenderingMode(.alwaysTemplate))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.tintAdjustmentMode = .normal
       
        return imageView
    }()
    
  private var documentVersion: DocumentVersion?
  private var onFinishCallback: VoidCallback?

  
//  @IBOutlet var headerLabel: UILabel!
//  @IBOutlet var continueButton: UIButton!
//  @IBOutlet var desc1Label: UILabel!
//  @IBOutlet var desc2Label: UILabel!
//  @IBOutlet var desc3Label: UILabel!
//  @IBOutlet var amaniLogo: UIImageView!
    let idCaptureModule =  Amani.sharedInstance.IdCapture()
    let amani:Amani = Amani.sharedInstance
    var isDone: Bool = false

    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
        Task { @MainActor in
            setupUI()
            await initialSetup()
            
            continueButton.addTarget(self, action: #selector(continueButtonPressed(_:)), for: .touchUpInside)
        }
       
  }
  
    func initialSetup() async {
    guard let documentVersion = documentVersion else { return }

    let generalConfigs = try? amani.appConfig().getApplicationConfig().generalconfigs
    
    let navFontColor = generalConfigs?.topBarFontColor ?? "ffffff"
    let textColor = generalConfigs?.appFontColor ?? "ffffff"
    
    setNavigationBarWith(title: (documentVersion.nfcTitle)!, textColor: UIColor(hexString: navFontColor))
    setNavigationLeftButton(TintColor: navFontColor)
    amaniLogo.isHidden = generalConfigs?.hideLogo ?? false
    amaniLogo.tintColor = UIColor(hexString: textColor)
    desc1Label.textColor = UIColor(hexString: textColor)
    desc2Label.textColor = UIColor(hexString: textColor)
    desc3Label.textColor = UIColor(hexString: textColor)
    headerLabel.textColor = UIColor(hexString: textColor)
    headerLabel.text = documentVersion.nfcTitle
    desc1Label.text = documentVersion.nfcDescription1
    desc2Label.text = documentVersion.nfcDescription2
    desc3Label.text = documentVersion.nfcDescription3
    desc1Label.numberOfLines = 0
    desc2Label.numberOfLines = 0
    desc3Label.numberOfLines = 0
    desc1Label.lineBreakMode = .byWordWrapping
    desc2Label.lineBreakMode = .byWordWrapping
    desc3Label.lineBreakMode = .byWordWrapping
    
    continueButton.alpha = 1
    continueButton.isEnabled = true
    continueButton.setTitleColor(UIColor(hexString: generalConfigs?.primaryButtonTextColor ?? ThemeColor.whiteColor.toHexString()), for: .normal)
    continueButton.backgroundColor = UIColor(hexString: generalConfigs?.primaryButtonBackgroundColor ?? ThemeColor.whiteColor.toHexString())
    continueButton.addCornerRadiousWith(radious: CGFloat(generalConfigs?.buttonRadius ?? 10))
    continueButton.setTitle(generalConfigs?.continueText ?? "Devam", for: .normal)
        await scanNFC()
  }
    
  func bind(documentVersion: DocumentVersion, callback: @escaping VoidCallback) {
    self.documentVersion = documentVersion
    self.onFinishCallback = callback
  }
  
    
    @objc func continueButtonPressed(_ sender: Any) {
        Task { @MainActor in
            await scanNFC()
        }
    }
    
//    @IBAction func continueButtonPressed(_ sender: Any) {
//      
//    }
    
    func uploadNFCResult() {
        idCaptureModule.upload(location: nil) { isUploadSuccess in
            if isUploadSuccess != nil {
                self.isDone = true
                self.doNext(done: self.isDone)
            } else {
                self.isDone = false
                self.doNext(done: self.isDone)
            }
        }
       
    }
 
    func scanNFC() async {
//    let idCaptureModule = Amani.sharedInstance.IdCapture()
      self.continueButton.isEnabled = false
//    guard let nvi = AmaniUI.sharedInstance.nviData else { return }
//    let isDone = await idCaptureModule.startNFC(nvi: nvi)
//    self.doNext(done: isDone)
    if let nvi:NviModel = AmaniUI.sharedInstance.nviData {
      print(nvi)
      let isDone = await idCaptureModule.startNFC(nvi: nvi)
        self.doNext(done: isDone)
      
    }
    
  }
  
  func doNext(done:Bool) {
    let tryAgainText = try? Amani.sharedInstance.appConfig().getApplicationConfig().generalconfigs?.tryAgainText

     if done {
       DispatchQueue.main.async {
         if let onFinishCallback = self.onFinishCallback {
           onFinishCallback()
         }
       }
     } else {
       DispatchQueue.main.async {
         self.continueButton.setTitle(tryAgainText ?? "Tekrar Dene", for: .normal)
         self.continueButton.isEnabled = true
       }
     }
  }
  
}

extension NFCViewController {
    private func setupUI() {
        DispatchQueue.main.async {
            self.view.addSubviews(self.headerLabel, self.labelsContainerView, self.amaniLogo, self.continueButton )
            self.labelsContainerView.addSubviews(self.desc1Label, self.desc2Label, self.desc3Label)
            
            NSLayoutConstraint.activate([
                self.headerLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 47),
                self.headerLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 23),
                self.headerLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -23),
                self.headerLabel.bottomAnchor.constraint(equalTo: self.labelsContainerView.topAnchor, constant: -72),
                self.headerLabel.heightAnchor.constraint(equalToConstant: 30),
                
                self.labelsContainerView.topAnchor.constraint(equalTo: self.headerLabel.bottomAnchor, constant: 72),
                self.labelsContainerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                self.labelsContainerView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
                self.labelsContainerView.heightAnchor.constraint(equalToConstant: 229),
                
                self.desc1Label.leadingAnchor.constraint(equalTo: self.labelsContainerView.leadingAnchor),
                self.desc1Label.trailingAnchor.constraint(equalTo: self.labelsContainerView.trailingAnchor),
                self.desc1Label.centerXAnchor.constraint(equalTo: self.labelsContainerView.centerXAnchor),
                self.desc1Label.heightAnchor.constraint(equalToConstant: 60),
                
                self.desc2Label.topAnchor.constraint(equalTo: self.desc1Label.bottomAnchor, constant: 20),
                self.desc2Label.bottomAnchor.constraint(equalTo: self.desc3Label.topAnchor, constant: -20),
                self.desc2Label.leadingAnchor.constraint(equalTo: self.labelsContainerView.leadingAnchor),
                self.desc2Label.trailingAnchor.constraint(equalTo: self.labelsContainerView.trailingAnchor),
                self.desc2Label.centerXAnchor.constraint(equalTo: self.labelsContainerView.centerXAnchor),
                self.desc2Label.centerYAnchor.constraint(equalTo: self.labelsContainerView.centerYAnchor),
                
                self.desc3Label.topAnchor.constraint(equalTo: self.desc2Label.bottomAnchor, constant: 20),
                self.desc3Label.leadingAnchor.constraint(equalTo: self.labelsContainerView.leadingAnchor),
                self.desc3Label.trailingAnchor.constraint(equalTo: self.labelsContainerView.trailingAnchor),
                self.desc3Label.centerXAnchor.constraint(equalTo: self.labelsContainerView.centerXAnchor),
                
                self.continueButton.widthAnchor.constraint(equalToConstant: 333),
                self.continueButton.heightAnchor.constraint(equalToConstant: 50),
                self.continueButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                self.continueButton.bottomAnchor.constraint(equalTo: self.amaniLogo.topAnchor, constant: -20),
                
                self.amaniLogo.widthAnchor.constraint(equalToConstant: 114),
                self.amaniLogo.heightAnchor.constraint(equalToConstant: 13),
                self.amaniLogo.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                self.amaniLogo.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30)
                
            
            ])
        }
    }
}
