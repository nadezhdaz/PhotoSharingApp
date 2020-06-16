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
            usernameTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)}
    }
    @IBOutlet weak var passwordTextField: UITextField! {
           didSet {
            passwordTextField.autocorrectionType = .no
            passwordTextField.returnKeyType = .send
            passwordTextField.delegate = self
            passwordTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)}
       }
    @IBOutlet weak var signInButton: UIButton! {
        didSet {
            signInButton.isEnabled = false
            signInButton.backgroundColor = UIColor(red: 0.00, green: 0.48, blue: 1.00, alpha: 1.00)//, for: .normal
            //signInButton.setBackground(UIColor(red: 0.00, green: 0.48, blue: 1.00, alpha: 0.3), for: .disabled)
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        signInButton.isEnabled = true
        print("Text changed")
        
    }
    
    var networkService = NetworkService()
    var keychainService = KeychainService()
    var networkHandler = SecureNetworkHandler()
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            print("No username or password received")
            return true
        }
        
        guard username.count > 0, password.count > 0 else {
            print("No username or password received")
            return false
        }
        
        networkHandler.login(login: username, password: password)
        
        //authorizationRequest(login: username, password: password)
        
        print("TextField should return method called")
        textField.resignFirstResponder();
        return true
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
