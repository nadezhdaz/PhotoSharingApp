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
        
        //networkHandler.login(login: username, password: password, completion: {
        //    self.authorizationToTabBarSegue()
        //})
        
        
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
    
    func authorizationToTabBarSegue() {
        DispatchQueue.main.async {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let tabbarController = mainStoryboard.instantiateViewController(withIdentifier: "tabVC") as! UITabBarController
            //let destinationController = mainStoryboard.instantiateViewController(withIdentifier: "feedVC") as! FeedViewController
            let navController = UINavigationController(rootViewController: tabbarController)
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            appDelegate.window?.rootViewController = tabbarController
            //UIApplication.shared.keyWindow?.rootViewController?.present(navController, animated: true, completion: nil)
            //UIApplication.shared.keyWindow?.rootViewController?.present(destinationController, animated: true, completion: nil)
            Spinner.start()
            navController.popToRootViewController(animated: true)
            
           /* guard let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "feedVC") as? FeedViewController else { return }
            guard let rootViewController = UIApplication.shared.windows.first!.rootViewController as? FeedViewController else { return }
        let navigationController = destinationController.navigationController
            let navigationControllerSecond = rootViewController.navigationController
        //navigationController?.setViewControllers([destinationController], animated: true)
            let tabBarController = destinationController.tabBarController
            tabBarController?.present(destinationController, animated: true)
        Spinner.start()
            navigationControllerSecond?.popToRootViewController(animated: true)*/
            
        //navigationController?.popToRootViewController(animated: true)
           // navigationControllerSecond?.pushViewController(destinationController, animated: true)
    }
        //self.navigationController!.pushViewController(destinationController, animated: true)
    }
    
   private func userSignIn(login: String, password: String) {
            networkService.signInRequest(login: login, password: password, completion: { [weak self] token, errorMessage in
                if let newToken = token {
                    SecureStorableService.safeSaveToken(account: login, token: newToken)
                    self?.authorizationToTabBarSegue()
                }
                else if let message = errorMessage  {
                 AlertController.showError(with: message)
                }
                else {
                 AlertController.showError()
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
