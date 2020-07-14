//
//  Spinner.swift
//  Course2FinalTask
//
//  Copyright © 2019 e-Legion. All rights reserved.
//

import UIKit

public class Spinner {
    
    internal static var spinner: UIActivityIndicatorView?
    internal static var blackScreen: UIView?
    internal static var backgroundColor = UIColor.black.withAlphaComponent(0.7)
    
    public static func start() {
        let window = UIApplication.shared.keyWindow
        let frame = UIScreen.main.bounds
        guard Spinner.spinner == nil else { return }
        let spinner = UIActivityIndicatorView(frame: frame)
        spinner.style = .whiteLarge
        spinner.backgroundColor = backgroundColor
        window?.addSubview(spinner)
        Spinner.spinner = spinner
        Spinner.spinner?.startAnimating()
    }
   
    public static func stop() {
        if spinner != nil {
            spinner?.stopAnimating()
            spinner?.removeFromSuperview()
            spinner = nil
        }
        
    }

}
