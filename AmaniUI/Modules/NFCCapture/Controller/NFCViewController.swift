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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    initialSetup()
  }
  
  func initialSetup() {
    guard let documentVersion = documentVersion else { return }
    
    let generalConfigs = try? Amani.sharedInstance.appConfig().getApplicationConfig().generalconfigs
    
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
    
    continueButton.alpha = 0.6
    continueButton.isEnabled = true
    continueButton.setTitleColor(UIColor(hexString: generalConfigs?.primaryButtonTextColor ?? ThemeColor.whiteColor.toHexString()), for: .normal)
    continueButton.backgroundColor = UIColor(hexString: generalConfigs?.primaryButtonBackgroundColor ?? ThemeColor.whiteColor.toHexString())
    continueButton.addCornerRadiousWith(radious: CGFloat(generalConfigs?.buttonRadius ?? 10))
    continueButton.setTitle(generalConfigs?.continueText ?? "Devam", for: .normal)
    scanNFC()
  }
  
  func bind(documentVersion: DocumentVersion, callback: @escaping VoidCallback) {
    self.documentVersion = documentVersion
    self.onFinishCallback = callback
  }
  
  @IBAction func continueButtonPressed(_ sender: Any) {
    scanNFC()
  }
 
  func scanNFC() {
    let tryAgainText = try? Amani.sharedInstance.appConfig().getApplicationConfig().generalconfigs?.tryAgainText
    let idCaptureModule = Amani.sharedInstance.IdCapture()
    guard let cardType = documentVersion?.type else {
      print("idCard Type error")
      return}
    if let nvi:NviModel = AmaniUI.sharedInstance.nviData {
      idCaptureModule.startNFC(nvi: nvi){[weak self] done in
        self?.doNext(done: done)
      }
    } else {
      idCaptureModule.startNFC() {[weak self]  done in
        self?.doNext(done: done)
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
