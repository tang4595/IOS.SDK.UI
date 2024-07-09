import UIKit
import AmaniSDK
/**
 This class represents the cell class of KYC step
 */
class KYCStepTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var loaderView: UIActivityIndicatorView!
    @IBOutlet private weak var outerView: UIView!

    // MARK: - Life cycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
      outerView.addShadowWithBorder(shadowRadius: 4, shadowColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.25), shadowOpacity: 1, borderColor: .clear, borderWidth: 0, cornerRadious: CGFloat(AmaniUI.sharedInstance.config?.generalconfigs?.buttonRadius ?? 10))
      if let bordercolor:String = AmaniUI.sharedInstance.config?.generalconfigs?.primaryButtonBorderColor {
            outerView.addBorder(borderWidth: 2, borderColor: UIColor(hexString: bordercolor).cgColor)
        }
    }
    // MARK: - Helper methods
    /**
     This method bind the data with view
     - parameter model: KYCRuleModel
     */
  func bind(model: KYCStepViewModel, alpha: CGFloat = 1) {
    DispatchQueue.main.async { [weak self] in
      
      var labelTest: String = model.title
      if let loaderView = self?.loaderView {
        if model.status == DocumentStatus.PROCESSING {
          labelTest = model.stepConfig.buttonText?.processing ?? model.title
          loaderView.startAnimating()
          
        }else if model.status == DocumentStatus.APPROVED{
          labelTest = model.stepConfig.buttonText?.approved ?? model.title
          loaderView.stopAnimating()
          
        }else if model.status == DocumentStatus.REJECTED{
          labelTest = model.stepConfig.buttonText?.rejected ?? model.title
          loaderView.stopAnimating()
          
        }else if model.status == DocumentStatus.AUTOMATICALLY_REJECTED{
          labelTest = model.stepConfig.buttonText?.autoRejected ?? model.title
          loaderView.stopAnimating()
          
        }else if model.status == DocumentStatus.NOT_UPLOADED{
          labelTest = model.stepConfig.buttonText?.notUploaded ?? model.title
          loaderView.stopAnimating()
          
        }else if model.status == DocumentStatus.PENDING_REVIEW{
          labelTest = model.stepConfig.buttonText?.pendingReview ?? model.title
          loaderView.stopAnimating()
          
        } else {
          if ((model.getRuleModel().errors?.count ?? 0) > 0){
              // TODO: Get the error name from the DocumentStepModel.
            labelTest += "xxxxxx"
            loaderView.stopAnimating()
          }
          
          loaderView.stopAnimating()
        }
      }
      
      self?.titleLabel.text = labelTest
      self?.titleLabel.textColor = model.textColor
      self?.outerView.backgroundColor = model.buttonColor
      self?.outerView.alpha = alpha
    }
  }

}
