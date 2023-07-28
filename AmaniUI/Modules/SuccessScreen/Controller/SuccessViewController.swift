import AmaniSDK
import UIKit

class SuccessViewController: BaseViewController {
  @IBOutlet var successView: UIView!
  @IBOutlet var continueButton: UIButton!
  @IBOutlet var amaniLogo: UIImageView!
  @IBOutlet var headerTextView: UILabel!
  @IBOutlet var info1TextView: UILabel!
  @IBOutlet var info2TextView: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
  }

  func initialSetup() {
    let generalConfig = try? Amani.sharedInstance.appConfig().getApplicationConfig().generalconfigs
    let textColor = generalConfig?.appFontColor ?? "ffffff"
    setNavigationBarWith(title: generalConfig?.successTitle ?? "Adımları Tamamladınız", textColor: UIColor(hexString: textColor))
    setNavigationLeftButton(TintColor: textColor)
    continueButton.setTitleColor(UIColor(hexString: generalConfig?.primaryButtonTextColor ?? ThemeColor.whiteColor.toHexString()), for: .normal)
    continueButton.backgroundColor = UIColor(hexString: generalConfig?.primaryButtonBackgroundColor ?? ThemeColor.whiteColor.toHexString())
    continueButton.addCornerRadiousWith(radious: CGFloat(generalConfig?.buttonRadius ?? 10))
    amaniLogo.isHidden = generalConfig?.hideLogo ?? false
    amaniLogo.tintColor = UIColor(hexString: textColor)
    continueButton.setTitle(generalConfig?.continueText, for: .normal)
    headerTextView.textColor = UIColor(hexString: textColor)
    info1TextView.textColor = UIColor(hexString: textColor)
    info2TextView.textColor = UIColor(hexString: textColor)
    headerTextView.text = generalConfig?.successHeaderText ?? "Tebrikler"
    info1TextView.text = generalConfig?.successInfo1Text ?? "Bütün adımları tamamladınız."
    info2TextView.text = generalConfig?.successInfo2Text ?? "Evraklarınızı kontrol edip başvurunuzu değerlendireceğiz."
  }

  override func popViewController() {
    navigationController?.dismiss(animated: true, completion: nil)
  }

  @IBAction func continueBtnAction(_ sender: UIButton) {
    let customer = Amani.sharedInstance.customerInfo().getCustomer()
    guard let customerId: String = customer.id else { return }
    AmaniUI.sharedInstance.delegate?.onKYCSuccess(CustomerId: customerId)
    navigationController?.dismiss(animated: true, completion: nil)
  }
}
