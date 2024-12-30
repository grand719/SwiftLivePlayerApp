//
//  ErrorLabel.swift
//  LivePlayerAppliaction
//
//  Created by Łukasz Pawłowski on 26/12/2024.
//

import UIKit

class ErrorLabel: UIView {
    private var isErrorPresent = false
    
    lazy var errorLabel:UILabel = {
        let label = UILabel();
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isHidden = true
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setLabelErrorMessage(message: String) {
        errorLabel.text = message
        isErrorPresent = true
        self.isHidden = false
    }
    
    public func clearLabelErrorMessageError() {
        errorLabel.text = nil
        isErrorPresent = false
        print("Error is cleared")
        self.isHidden = true
    }
    
    public func getIsErrorPresent() -> Bool {
        return isErrorPresent
    }
    
    private func setupUI() {
        self.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    
}
