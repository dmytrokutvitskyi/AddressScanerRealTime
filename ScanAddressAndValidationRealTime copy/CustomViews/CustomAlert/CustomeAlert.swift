//
//  CustomeAlert.swift
//  ScanAddressAndValidationRealTime
//

import UIKit

protocol CustomAlertDelegate: AnyObject {
    func okButtonPressed(_ alert: CustomeAlert, alertTag: Int)
    func cancelButtonPressed(_ alert: CustomeAlert, alertTag: Int)
}

class CustomeAlert: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var okButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var secondSeparatorLineView: UIView!
    
    var alertTitle: String? = nil
    var alertMessage = ""
    var okButtonTitle = ""
    var cancelButtonTitle = "Cancel"
    var alertTag = 0
    var statusImage = UIImage.init(named: "errorImage")
    var isCancelButtonHidden = false
    
    var okHandler: (() -> Void)?
    var cancelHandler: (() -> Void)?
    
    weak var delegate: CustomAlertDelegate?
    
    init() {
        super.init(nibName: "CustomeAlert", bundle: Bundle(for: CustomeAlert.self))
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupAlert()
        setupButton()
    }
    
    func show() {
        if #available(iOS 13, *) {
            UIApplication.shared.windows.first?.rootViewController?.present(self, animated: true, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.rootViewController!.present(self, animated: true, completion: nil)
        }
    }
    
    func dismissAlert() {
        if #available(iOS 13, *) {
            UIApplication.shared.windows.first?.rootViewController!.dismiss(animated: true)
        } else {
            UIApplication.shared.keyWindow?.rootViewController!.dismiss(animated: true)
        }
    }
    
    private func setupView() {
        contentView.layer.cornerRadius = 14
    }
    
    private func setupAlert() {
        if alertTitle == nil {
            titleLabel.isHidden = true
        }
        titleLabel.text = alertTitle
        imageView.image = statusImage
        messageLabel.text = alertMessage
    }
    
    private func setupButton() {
        okButton.setTitle(okButtonTitle, for: .normal)
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        
        cancelButton.isHidden = isCancelButtonHidden
        secondSeparatorLineView.isHidden = isCancelButtonHidden
    }
    
    @IBAction func actionOnOkButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.okButtonPressed(self, alertTag: alertTag)
        okHandler?()
    }
    
    @IBAction func actionOnCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.cancelButtonPressed(self, alertTag: alertTag)
        cancelHandler?()
    }
}
