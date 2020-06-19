//
//  AuthorizationViewController.swift
//  
//
//  Created by Надежда Зенкова on 31.05.2020.
//

import UIKit

class AuthorizationViewController: UIViewController, UITextFieldDelegate {//}, SecureStorable {    
    
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
        
        networkHandler.login(login: username, password: password)
        authorizationToTabBarSegue()
        
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
    var keychainService = KeychainService()
    var networkHandler = SecureNetworkHandler()
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            print("No username or password received")
            return false
        }
        
        guard username.count > 0, password.count > 0 else {
            print("No username or password received")
            return false
        }
        
        //textField.resignFirstResponder()
        
        networkHandler.login(login: username, password: password)
        authorizationToTabBarSegue()
        
        //authorizationRequest(login: username, password: password)
        
        
        return true
    }
    
    func authorizationToTabBarSegue() {
        guard let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "feedVC") as? FeedViewController else { return }
        let navigationController = self.navigationController
        navigationController?.setViewControllers([destinationController], animated: true)
        Spinner.start()
        self.navigationController?.popToRootViewController(animated: true)
        //self.navigationController!.pushViewController(destinationController, animated: true)
    }
    
   /* private func authorizationRequest(login: String, password: String) {
        
        networkService.signInRequest(login: login, password: password, completion: { [weak self] token, errorMessage in
            if let token = token {
                do {
                keychainService.saveToken(account: login, token: token)
                }
                catch {
                    debugPrint(error)
                }
            }
            else if errorMessage != nil {
                self?.showError(with: errorMessage)
            }
            else {
                self?.showError()
            }
            
        })
    }*/
    
    
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
