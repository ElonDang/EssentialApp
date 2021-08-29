//
//  ErrorView.swift
//  ErrorView
//
//  Created by Elon on 19/08/2021.
//

import UIKit

public final class ErrorView: UIButton {
    public var message: String? {
        get { return isVisible ? title(for: .normal) : nil }
        set { setMessageAnimated(newValue) }
    }
    
    public var onHide: (() -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func configure() {
        backgroundColor = UIColor.errorBackgroundColor
        addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
        
        configureLabel()
        hideMessage()
    }
    
    private func configureLabel() {
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .preferredFont(forTextStyle: .body)
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
        titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    private var isVisible: Bool {
        return alpha > 0
    }
    
    private func setMessageAnimated(_ message: String?) {
        if let message = message {
            showAnimated(message)
            contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        } else {
            hideMessageAnimated()
        }
    }
    
    private func showAnimated(_ message: String) {
        setTitle(message, for: .normal)
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    @objc private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed { self.hideMessage() }
            })
    }
    
    private func hideMessage() {
        setTitle(nil, for: .normal)
        alpha = 0
        contentEdgeInsets = .init(top: -2.5, left: 0, bottom: -2.5, right: 0)
        onHide?()
    }
}

private extension UIColor {
    static var errorBackgroundColor: UIColor {
        UIColor(red: 1, green: 118/255, blue: 138/255, alpha: 1)
    }
}
