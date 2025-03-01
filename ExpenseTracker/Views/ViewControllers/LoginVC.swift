//
//  LoginVC.swift
//  ExpenseTracker
//
//  Created by Naman Sharma on 27/02/25.
//

import UIKit
import FirebaseAuth
import FirebaseCore

class LoginVC: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Expense Tracker App"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 3
        let text = "\"Track your expenses,\nSave smartly,\nAchieve financial freedom\""
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: 16), range: NSRange(location: 0, length: text.count))
        attributedText.addAttribute(.foregroundColor, value: UIColor.darkGray, range: NSRange(location: 0, length: text.count))
        label.attributedText = attributedText
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textContentType = .oneTimeCode
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        textField.textContentType = .oneTimeCode
        return textField
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 8
        button.applyGradient()
        button.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 8
        button.applyGradient()
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let currentUser = Auth.auth().currentUser {
            UserDefaults.standard.set(currentUser.uid, forKey: UserDefaultsKeys.uniqueUserUUID)
            navigateToMainTabBar()
        }
    }
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, signUpButton, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            stackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
        
        view.layoutIfNeeded()
    }
    
    @objc private func signUpTapped() {
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty else {
            showAlert(message: "Please enter valid email and password")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(message: "Sign Up Error: \(error.localizedDescription)")
                return
            }
            
            guard let user = authResult?.user else { return }
            
            LoginAPIManager.shared.registerUser(uuidString: user.uid, email: email, password: password) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        UserDefaults.standard.set(user.uid, forKey: UserDefaultsKeys.uniqueUserUUID)
                        self.navigateToMainTabBar()
                    case .failure(let error):
                        self.showAlert(message: "Backend Sign Up Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    @objc private func loginTapped() {
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty else {
            showAlert(message: "Please enter valid email and password")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(message: "Login Error: \(error.localizedDescription)")
                return
            }
            
            guard let user = authResult?.user else { return }
            
            UserDefaults.standard.set(user.uid, forKey: UserDefaultsKeys.uniqueUserUUID)
            
            LoginAPIManager.shared.loginUser(email: email, password: password) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let userResponse):
                        if user.uid != userResponse._id {
                            self.showAlert(message: "Firebase UUID does not match backend UUID")
                            return
                        }
                        UserDefaults.standard.set(userResponse.token, forKey: UserDefaultsKeys.uniqueAuthToken)
                        UserDefaults.standard.set(userResponse._id, forKey: UserDefaultsKeys.uniqueUserUUID)
                        self.navigateToMainTabBar()
                    case .failure(let error):
                        self.showAlert(message: "Backend Login Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func navigateToMainTabBar() {
        let mainTabBarVC = MainTabBarController()
        // This will explicitly reload each VC like LogoutVC and DashboardVC
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = mainTabBarVC
            })
            
            window.makeKeyAndVisible()
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension UIButton {
    func applyGradient() {
        DispatchQueue.main.async {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            gradientLayer.frame = self.bounds
            gradientLayer.cornerRadius = self.layer.cornerRadius
            
            self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}
