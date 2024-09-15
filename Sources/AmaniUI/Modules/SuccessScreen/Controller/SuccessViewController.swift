import AmaniSDK
import UIKit

class SuccessViewController: BaseViewController {
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.axis = .vertical
        stack.distribution = .fillProportionally
//        stack.contentMode = .scaleToFill
        stack.spacing = 7
        
        return stack
    }()
    
    private lazy var approveImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.tintAdjustmentMode = .normal
        imageView.tintColor = UIColor(hexString: "#6FF7D1")
        
        return imageView
    }()
    
    private lazy var labelContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .red
        return view
    }()
   
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    private lazy var info1TextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .light)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        
        return label
    }()
    
    private lazy var info2TextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .light)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var amaniLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_poweredBy", in: AmaniUI.sharedInstance.getBundle(), with: nil)?.withRenderingMode(.alwaysTemplate))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.tintAdjustmentMode = .normal
        
        return imageView
    }()
    
    
//  @IBOutlet var successView: UIView!
//  @IBOutlet var continueButton: UIButton!
//  @IBOutlet var amaniLogo: UIImageView!
//  @IBOutlet var headerTextView: UILabel!
//  @IBOutlet var info1TextView: UILabel!
//  @IBOutlet var info2TextView: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
    setConstraints()
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

extension SuccessViewController {
    private func initialSetup() {
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
        continueButton.backgroundColor = UIColor(hexString: generalConfig?.primaryButtonBackgroundColor ?? "#EA3365")
        continueButton.layer.cornerRadius = 25
      headerLabel.textColor = UIColor(hexString: textColor)
      info1TextLabel.textColor = UIColor(hexString: textColor)
      info2TextLabel.textColor = UIColor(hexString: textColor)
      headerLabel.text = generalConfig?.successHeaderText ?? "Tebrikler"
      info1TextLabel.text = generalConfig?.successInfo1Text ?? "Bütün adımları tamamladınız."
      info2TextLabel.text = generalConfig?.successInfo2Text ?? "Evraklarınızı kontrol edip başvurunuzu değerlendireceğiz."
    }
    
    private func setConstraints() {
        DispatchQueue.main.async {
            self.view.addSubview(self.stackView)
            self.stackView.addArrangedSubview(self.approveImage)
            self.stackView.addArrangedSubview(self.labelContainerView)
//            self.stackView.addSubviews(self.approveImage, self.labelContainerView)
            self.labelContainerView.addSubviews(self.headerLabel, self.info1TextLabel, self.info2TextLabel)
            self.view.addSubview(self.continueButton)
            self.view.addSubview(self.amaniLogo)
            
            NSLayoutConstraint.activate([
                self.stackView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
//                self.stackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100),
                self.stackView.bottomAnchor.constraint(equalTo: self.continueButton.topAnchor, constant: -24),
                self.stackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
                self.stackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
                
                self.approveImage.heightAnchor.constraint(equalToConstant: 100),
                self.approveImage.widthAnchor.constraint(equalToConstant: 100),
                
                self.labelContainerView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor, multiplier: 0.9),
                
//                self.labelContainerView.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor),
//                self.labelContainerView.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor),
//                self.labelContainerView.topAnchor.constraint(equalTo: self.stackView.topAnchor),
//                self.labelContainerView.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor),
                
                self.headerLabel.leadingAnchor.constraint(equalTo: self.labelContainerView.leadingAnchor, constant: 16),
                self.headerLabel.trailingAnchor.constraint(equalTo: self.labelContainerView.trailingAnchor, constant: -16),
                self.headerLabel.topAnchor.constraint(equalTo: self.labelContainerView.topAnchor, constant: 16),
                self.headerLabel.bottomAnchor.constraint(equalTo: self.info1TextLabel.topAnchor, constant: -24),
                self.headerLabel.heightAnchor.constraint(equalToConstant: 24),
                
                self.info1TextLabel.topAnchor.constraint(equalTo: self.headerLabel.bottomAnchor, constant: 24),
                self.info1TextLabel.leadingAnchor.constraint(equalTo: self.labelContainerView.leadingAnchor, constant: -16),
                self.info1TextLabel.trailingAnchor.constraint(equalTo: self.labelContainerView.trailingAnchor, constant: 16),
                self.info1TextLabel.bottomAnchor.constraint(equalTo: self.info2TextLabel.topAnchor, constant: -24),
                self.info1TextLabel.heightAnchor.constraint(equalToConstant: 60),
                
                self.info2TextLabel.topAnchor.constraint(equalTo: self.info1TextLabel.bottomAnchor, constant: 24),
                self.info2TextLabel.leadingAnchor.constraint(equalTo: self.labelContainerView.leadingAnchor, constant: 16),
                self.info2TextLabel.trailingAnchor.constraint(equalTo: self.labelContainerView.trailingAnchor, constant: -16),
                self.info2TextLabel.bottomAnchor.constraint(equalTo: self.labelContainerView.bottomAnchor, constant: -16),
                
                self.continueButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                self.continueButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                self.continueButton.bottomAnchor.constraint(equalTo: self.amaniLogo.topAnchor, constant: -16),
                self.continueButton.heightAnchor.constraint(equalToConstant: 50),
                
                
                self.amaniLogo.widthAnchor.constraint(equalToConstant: 114),
                self.amaniLogo.heightAnchor.constraint(equalToConstant: 13),
                self.amaniLogo.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                self.amaniLogo.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30)
            
            ])
        }
       
    }
}
