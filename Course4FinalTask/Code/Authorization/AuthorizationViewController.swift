//
//  AuthorizationViewController.swift
//  
//
//  Created by Надежда Зенкова on 31.05.2020.
//

import UIKit

class AuthorizationViewController: UIViewController, UITextFieldDelegate {
    
    
    //
    // MARK: - Outlets
    //
    
    @IBOutlet weak var usernameTextField: UITextField! {
        didSet {
            usernameTextField.autocorrectionType = .no
            usernameTextField.keyboardType = .emailAddress
            usernameTextField.returnKeyType = .send
            usernameTextField.delegate = self
            usernameTextField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        }
        
    }
    
    @IBOutlet weak var passwordTextField: UITextField! {
           didSet {
            passwordTextField.autocorrectionType = .no
            passwordTextField.keyboardType = .asciiCapable
            passwordTextField.returnKeyType = .send
            passwordTextField.delegate = self
            passwordTextField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        }
       }
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            print("No username or password received")
            return
        }
        
        guard username.count > 0, password.count > 0 else {
            print("No username or password received")
            return
        }
        
        userSignIn(login: username, password: password)
    }
    
    @IBOutlet weak var signInButton: UIButton! {
        didSet {
            signInButton.isEnabled = false
            signInButton.setBackgroundColor(color: UIColor(red: 0.00, green: 0.48, blue: 1.00, alpha: 1.00), forState: .normal)
            signInButton.setBackgroundColor(color: UIColor(red: 0.00, green: 0.48, blue: 1.00, alpha: 0.3), forState: .disabled)
        }
    }
    
    @objc func textFieldDidChanged(_ textField: UITextField){
        if usernameTextField.hasText && passwordTextField.hasText {
            signInButton.isEnabled = true
        } else {
            signInButton.isEnabled = false
        }
        
    }
    
    var networkService = NetworkService()
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else {
            
            guard let username = usernameTextField.text, let password = passwordTextField.text else {
                print("No username or password received")
                return false
            }
        
            guard username.count > 0, password.count > 0 else {
                print("No username or password received")
                return false
            }
         
            userSignIn(login: username, password: password)
            textField.resignFirstResponder()
            }
        
        return true
    }
    
    private func authorizationToTabBarSegue() {
        DispatchQueue.main.async {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let tabbarController = mainStoryboard.instantiateViewController(withIdentifier: "tabVC") as! UITabBarController
            let navController = UINavigationController(rootViewController: tabbarController)
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            appDelegate.window?.rootViewController = tabbarController
            Spinner.start()
            navController.popToRootViewController(animated: true)
        }
    }
    
   private func userSignIn(login: String, password: String) {
            networkService.signInRequest(login: login, password: password, completion: { [weak self] result in
                switch result {
                case .success(let token):
                    SecureStorableService.safeSaveToken(account: login, token: token)
                    self?.authorizationToTabBarSegue()
                case .failure(let error):
                    AlertController.showError(for: error)
                }                
            })
    }
        
}


extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(origin: CGPoint.zero, size: size))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(colorImage, for: forState)
    }

}
