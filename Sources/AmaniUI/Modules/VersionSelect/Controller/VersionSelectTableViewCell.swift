import UIKit
import AmaniSDK

/**
This class represents the cell class of Version Selector
*/
@objc(VersionSelectTableViewCell)
class VersionSelectTableViewCell: UITableViewCell {
   
    // MARK: - Properties
    private lazy var outerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()
    
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15.0, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textAlignment = .left
       return label
    }()
    
//    @IBOutlet private weak var outerView: UIView!
//    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: - Life cycle methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        self.selectionStyle = .none
    }
//    override func awakeFromNib() {
//      super.awakeFromNib()
//      let generalconfigs = try? Amani.sharedInstance.appConfig().getApplicationConfig().generalconfigs
//      
//
//    }

    // MARK: - Helper methods
    /**
     This method bind the data model with view
     - parameter model: DocumentVersion
     */
    func bindViewWith(model: DocumentVersion) {
        titleLabel.text = model.title ?? ""
    }
}

extension VersionSelectTableViewCell {
    private func setupUI() {
        let generalconfigs = try? Amani.sharedInstance.appConfig().getApplicationConfig().generalconfigs
        
        outerView.addShadowWithBorder(shadowRadius: 4, shadowColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.25), shadowOpacity: 1, borderColor: .clear, borderWidth: 0, cornerRadious: CGFloat(generalconfigs?.buttonRadius ?? 10))
           titleLabel.textColor = UIColor( hexString: generalconfigs?.primaryButtonTextColor ?? "000000")
           outerView.backgroundColor = UIColor( hexString: generalconfigs?.primaryButtonBackgroundColor ?? "ffffff")
           if let bordercolor:String = generalconfigs?.primaryButtonBorderColor {
               outerView.addBorder(borderWidth: 2, borderColor: UIColor(hexString: bordercolor).cgColor)
           }
        
        setConstraints()
    }
    
    private func setConstraints() {
        DispatchQueue.main.async {
            self.contentView.addSubview(self.outerView)
            self.outerView.addSubview(self.titleLabel)
            
            NSLayoutConstraint.activate([
                self.outerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
                self.outerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),
                self.outerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
                self.outerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
               
                
                self.titleLabel.leadingAnchor.constraint(equalTo: self.outerView.leadingAnchor, constant: 20),
                self.titleLabel.trailingAnchor.constraint(equalTo: self.outerView.trailingAnchor, constant: 65),
                self.titleLabel.bottomAnchor.constraint(equalTo: self.outerView.bottomAnchor),
                self.titleLabel.topAnchor.constraint(equalTo: self.outerView.topAnchor),
                self.titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 53),
                
            ])
        }
    }
    
}
