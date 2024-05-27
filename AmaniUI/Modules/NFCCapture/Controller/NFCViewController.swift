import AmaniSDK
import UIKit

typealias VoidCallback = () -> Void

@available(iOS 13, *)
class NFCViewController: BaseViewController {
  private var documentVersion: DocumentVersion?
  private var onFinishCallback: VoidCallback?

  // MARK: Outlets
  @IBOutlet var headerLabel: UILabel!
  @IBOutlet var continueButton: UIButton!
  @IBOutlet var desc1Label: UILabel!
  @IBOutlet var desc2Label: UILabel!
  @IBOutlet var desc3Label: UILabel!
  @IBOutlet var amaniLogo: UIImageView!
    let idCaptureModule =  Amani.sharedInstance.IdCapture()
    let amani:Amani = Amani.sharedInstance
    var isDone: Bool = false
    
    var nviData:NviModel? {
      didSet{
        Task { @MainActor in
          if let nviData = nviData {
              IDCapture.sharedInstance.setType(type: DocumentTypes.TurkishIdNew.rawValue)
//            amani.IdCapture().setType(type: DocumentTypes.TurkishIdNew.rawValue)
              let scannfc = await idCaptureModule.startNFC(nvi: nviData)
              if scannfc {
                  self.uploadNFCResult()
              }
          }
        }
      }
    }
    
    var mrzDocumentId:String?
    var mrzInfoDelegate: mrzInfoDelegate?
  
    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
        Task { @MainActor in
            await initialSetup()
        }
       
  }
  
    func initialSetup() async {
    guard let documentVersion = documentVersion else { return }
    
    amani.setMRZDelegate(delegate:self)
        
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
  
    @IBAction func continueButtonPressed(_ sender: Any) {
        Task { @MainActor in
            await scanNFC()
        }
    }
    
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
    let tryAgainText = try? Amani.sharedInstance.appConfig().getApplicationConfig().generalconfigs?.tryAgainText
//    let idCaptureModule = Amani.sharedInstance.IdCapture()
        
//    guard let nvi = AmaniUI.sharedInstance.nviData else { return }
//    let isDone = await idCaptureModule.startNFC(nvi: nvi)
//    self.doNext(done: isDone)
    
    if let nvi:NviModel = AmaniUI.sharedInstance.nviData {
      let isDone = await idCaptureModule.startNFC(nvi: nvi)
        self.doNext(done: isDone)
      
    } else {
        idCaptureModule.setNfcIcons(newReadIcon: "👀",newBlankIcon: "🚀")
        idCaptureModule.getMrz { mrzDocumentId in
            self.mrzDocumentId = mrzDocumentId
        }
   
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

extension NFCViewController: mrzInfoDelegate {
    func mrzInfo(_ mrz: AmaniSDK.MrzModel?, documentId: String?) {
        guard let mrz = mrz else  {return}
        let nviData = NviModel(mrzModel: mrz)
        self.nviData = nviData
   
    }
}
