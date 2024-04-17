//
//  AnimationViewController.swift
//  AmaniUIv1
//
//  Created by Münir Ketizmen on 7.01.2023.
//

import Lottie
import UIKit
import AmaniSDK

class ContainerViewController: BaseViewController {
  private var animationName : String?
  private var callback: VoidCallback?
  private var disappearCallback: VoidCallback?
  private var docStep:DocumentStepModel?
  private var lottieAnimationView:LottieAnimationView?
  private var step:steps = .front
    private var isDissapeared = false

  @IBOutlet weak var btnContinue: UIButton!
  @IBOutlet weak var animationView: UIView!
  func bind(animationName:String?,
            docStep:DocumentStepModel,
            step:steps,
            callback: @escaping VoidCallback) {
    self.animationName = animationName
    self.callback = callback
    self.step = step
    self.docStep = docStep
  }
    
    private lazy var titleDescription: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16.0, weight: .light)
        label.text = "Click next to take a photo within the specified area"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor(hexString: "#20202F")
        return label
    }()
    
  func setDisappearCallback(_ callback: @escaping VoidCallback) {
    self.disappearCallback = callback
  }
  
  @IBAction func ActBtnContinue(_ sender: Any) {
    lottieAnimationView?.stop()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
      isDissapeared = false

    if let animationName = animationName {
      var side:String = "front"
      switch step {
      case .front:
        side = "front"
        break
      case .back:
        side = "back"
        break
      default:
        side = "front"
        break
      }
      var name = "\((animationName.lowercased()))_\(side)"
      
      if ((AmaniUI.sharedInstance.getBundle().url(forResource: name, withExtension: "json")?.isFileURL) == nil) {
        name = "xx_id_0_\(side)"
      }
      lottieInit(name: name) {[weak self] _ in
  //      print(finishedAnimation)
        self?.callback!()
      }
    } else {
      lottieAnimationView?.removeFromSuperview()
      self.callback!()

    }

  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

      view.addSubview(titleDescription)
      titleDescription.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        titleDescription.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
        titleDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        titleDescription.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      ])
      
    let appBackground = try? Amani.sharedInstance.appConfig().getApplicationConfig().generalconfigs?.appBackground
    
    self.initialSetup()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    // remove the sdk view on exiting by calling the callback
    print("Container View disappear")
    if let disappearCb = self.disappearCallback {
      disappearCb()
    }
      isDissapeared = true
    super.viewWillDisappear(animated)
  }
  
  func initialSetup() {
    let appConfig = try! Amani.sharedInstance.appConfig().getApplicationConfig()
    let buttonRadious = CGFloat(appConfig.generalconfigs?.buttonRadius ?? 10)

    // Navigation Bar
    self.setNavigationBarWith(title: docStep?.captureTitle ?? "", textColor: UIColor(hexString: appConfig.generalconfigs?.topBarFontColor ?? "ffffff"))
    self.setNavigationLeftButton(TintColor: appConfig.generalconfigs?.topBarFontColor ?? "ffffff")
    self.view.backgroundColor = UIColor(hexString: appConfig.generalconfigs?.appBackground ?? "#263B5B")
    btnContinue.backgroundColor = UIColor(hexString: appConfig.generalconfigs?.primaryButtonBackgroundColor ?? ThemeColor.primaryColor.toHexString())
    btnContinue.layer.borderColor = UIColor(hexString: appConfig.generalconfigs?.primaryButtonBorderColor ?? "#263B5B").cgColor
    btnContinue.setTitle(appConfig.generalconfigs?.continueText, for: .normal)
    btnContinue.setTitleColor(UIColor(hexString: appConfig.generalconfigs?.primaryButtonTextColor ?? ThemeColor.whiteColor.toHexString()), for: .normal)
    btnContinue.tintColor = UIColor(hexString: appConfig.generalconfigs?.primaryButtonTextColor ?? ThemeColor.whiteColor.toHexString())
    btnContinue.addCornerRadiousWith(radious: buttonRadious)
    
//    // For everything else
//      imgOuterView.isHidden = false
//      self.idImgView.image = image

//      self.previewHeightConstraints.constant = (UIScreen.main.bounds.width - 46) * CGFloat((documentVersion?.aspectRatio!)!)
//      self.previewHeightConstraints.isActive = true
//      self.view.layoutIfNeeded()
//      titleLabel.isHidden = false
//      selfieImageView.isHidden = true
//      physicalContractImageView.isHidden = true
//
//
  }

  private func lottieInit(name:String = "xx_id_0_front", completion:@escaping(_ finishedAnimation:Int)->()) {
    lottieAnimationView = .init(name: name,bundle: AmaniUI.sharedInstance.getBundle())
    lottieAnimationView!.frame = animationView.bounds
    lottieAnimationView!.backgroundColor = .clear
    animationView.addSubview(lottieAnimationView!)
    lottieAnimationView?.bringSubviewToFront(view)
      lottieAnimationView!.play {[weak self] (_) in
          self?.lottieAnimationView!.removeFromSuperview()
          if let isdp = self?.isDissapeared, !isdp{
              completion(steps.front.rawValue)
          }
      }
    
  }
  
}


//import UIKit
//import Lottie
//import AmaniSDK
//
//class ContainerViewController: BaseViewController {
//    private var animationName: String?
//    private var callback: VoidCallback?
//    private var disappearCallback: VoidCallback?
//    private var docStep: DocumentStepModel?
//    private var lottieAnimationView: LottieAnimationView?
//    private var step: steps = .front
//    private var isDissapeared = false
//
//    lazy var btnContinue: UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(ActBtnContinue(_:)), for: .touchUpInside)
//        return button
//    }()
//
//    lazy var animationView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    lazy var titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textAlignment = .center
//        label.textColor = .white
//        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//        return label
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        initialSetup()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        isDissapeared = false
//
//        if let animationName = animationName {
//            var side: String = "front"
//            switch step {
//            case .front:
//                side = "front"
//                break
//            case .back:
//                side = "back"
//                break
//            default:
//                side = "front"
//                break
//            }
//            var name = "\((animationName.lowercased()))_\(side)"
//
//            let appConfig = try! Amani.sharedInstance.appConfig().getApplicationConfig() // Move appConfig declaration here
//
//            if ((AmaniUI.sharedInstance.getBundle().url(forResource: name, withExtension: "json")?.isFileURL) == nil) {
//                name = "xx_id_0_\(side)"
//            }
//            lottieInit(name: name) {[weak self] _ in
//                self?.callback?()
//            }
//        } else {
//            lottieAnimationView?.removeFromSuperview()
//            self.callback?()
//        }
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        print("Container View disappear")
//        disappearCallback?()
//        isDissapeared = true
//    }
//
//    func bind(animationName: String?, docStep: DocumentStepModel, step: steps, callback: @escaping VoidCallback) {
//        self.animationName = animationName
//        self.callback = callback
//        self.step = step
//        self.docStep = docStep
//    }
//
//    func setDisappearCallback(_ callback: @escaping VoidCallback) {
//        self.disappearCallback = callback
//    }
//
//    @objc func ActBtnContinue(_ sender: Any) {
//        lottieAnimationView?.stop()
//    }
//
//    func initialSetup() {
//        let appConfig = try! Amani.sharedInstance.appConfig().getApplicationConfig() // Move appConfig declaration here
//
//        view.backgroundColor = UIColor(hexString: appConfig.generalconfigs?.appBackground ?? "#263B5B")
//
//        // Navigation Bar
//        setNavigationBarWith(title: docStep?.captureTitle ?? "", textColor: UIColor(hexString: appConfig.generalconfigs?.topBarFontColor ?? "ffffff"))
//        setNavigationLeftButton(TintColor: appConfig.generalconfigs?.topBarFontColor ?? "ffffff")
//
//        // Button setup
//        let buttonRadious = CGFloat(appConfig.generalconfigs?.buttonRadius ?? 10)
//        btnContinue.backgroundColor = UIColor(hexString: appConfig.generalconfigs?.primaryButtonBackgroundColor ?? ThemeColor.primaryColor.toHexString())
//        btnContinue.layer.borderColor = UIColor(hexString: appConfig.generalconfigs?.primaryButtonBorderColor ?? "#263B5B").cgColor
//        btnContinue.setTitle(appConfig.generalconfigs?.continueText, for: .normal)
//        btnContinue.setTitleColor(UIColor(hexString: appConfig.generalconfigs?.primaryButtonTextColor ?? ThemeColor.whiteColor.toHexString()), for: .normal)
//        btnContinue.tintColor = UIColor(hexString: appConfig.generalconfigs?.primaryButtonTextColor ?? ThemeColor.whiteColor.toHexString())
//        btnContinue.addCornerRadiousWith(radious: buttonRadious)
//
//        // Add subviews
//        view.addSubview(btnContinue)
//        view.addSubview(animationView)
//
//        // Positioning subviews
//        NSLayoutConstraint.activate([
//            btnContinue.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            btnContinue.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20), // Adjust bottom constant as needed
//            btnContinue.widthAnchor.constraint(equalToConstant: 200), // Adjust width as needed
//            btnContinue.heightAnchor.constraint(equalToConstant: 50), // Adjust height as needed
//
//            animationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20), // Adjust top constant as needed
//            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20), // Adjust leading constant as needed
//            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20), // Adjust trailing constant as needed
//            animationView.bottomAnchor.constraint(equalTo: btnContinue.topAnchor, constant: -20) // Adjust bottom constant as needed
//        ])
//
//        // Set up label
//        titleLabel.text = "Your Label Text"
//        animationView.addSubview(titleLabel)
//
//        // Position label
//        NSLayoutConstraint.activate([
//            titleLabel.centerXAnchor.constraint(equalTo: animationView.centerXAnchor),
//            titleLabel.centerYAnchor.constraint(equalTo: animationView.centerYAnchor),
//            titleLabel.leadingAnchor.constraint(equalTo: animationView.leadingAnchor, constant: 20), // Adjust leading constant as needed
//            titleLabel.trailingAnchor.constraint(equalTo: animationView.trailingAnchor, constant: -20) // Adjust trailing constant as needed
//        ])
//    }
//
//    private func lottieInit(name: String = "xx_id_0_front", completion: @escaping(_ finishedAnimation: Int) -> ()) {
//        lottieAnimationView = .init(name: name, bundle: AmaniUI.sharedInstance.getBundle())
//        lottieAnimationView!.frame = animationView.bounds
//        lottieAnimationView!.backgroundColor = .clear
//        animationView.addSubview(lottieAnimationView!)
//        lottieAnimationView?.bringSubviewToFront(view)
//        lottieAnimationView!.play {[weak self] (_) in
//            self?.lottieAnimationView!.removeFromSuperview()
//            if let isdp = self?.isDissapeared, !isdp {
//                completion(steps.front.rawValue)
//            }
//        }
//    }
//}
