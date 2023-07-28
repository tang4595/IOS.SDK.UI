import UIKit
import AmaniSDK

/**
This class represents the cell class of Version Selector
*/
class VersionSelectTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var outerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: - Life cycle methods
    override func awakeFromNib() {
      super.awakeFromNib()
      let generalconfigs = try? Amani.sharedInstance.appConfig().getApplicationConfig().generalconfigs
      
        outerView.addShadowWithBorder(shadowRadius: 4, shadowColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.25), shadowOpacity: 1, borderColor: .clear, borderWidth: 0, cornerRadious: CGFloat(generalconfigs?.buttonRadius ?? 10))
        titleLabel.textColor = UIColor( hexString: generalconfigs?.primaryButtonTextColor ?? "000000")
        outerView.backgroundColor = UIColor( hexString: generalconfigs?.primaryButtonBackgroundColor ?? "ffffff")
        if let bordercolor:String = generalconfigs?.primaryButtonBorderColor {
            outerView.addBorder(borderWidth: 2, borderColor: UIColor(hexString: bordercolor).cgColor)
        }
    }

    // MARK: - Helper methods
    /**
     This method bind the data model with view
     - parameter model: DocumentVersion
     */
    func bindViewWith(model: DocumentVersion) {
        titleLabel.text = model.title ?? ""
    }
}
