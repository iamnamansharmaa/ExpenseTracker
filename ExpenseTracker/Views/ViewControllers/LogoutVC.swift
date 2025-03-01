//
//  LogoutVC.swift
//  ExpenseTracker
//
//  Created by Naman Sharma on 28/02/25.
//

import UIKit
import FirebaseAuth

class LogoutVC: UIViewController {

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Logout"
        
        view.addSubview(logoutButton)
        setupConstraints()
        applyGradientToButton()
        
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func applyGradientToButton() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemOrange.cgColor, UIColor.systemPink.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        gradientLayer.cornerRadius = 25
        
        logoutButton.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @objc private func logoutTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.logoutButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.logoutButton.transform = .identity
            }
        }
        
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.navigateToLogin()
            }
        } catch {
            showAlert(message: "Logout Failed: \(error.localizedDescription)")
        }
    }
    
    private func navigateToLogin() {
        let loginVC = LoginVC()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
