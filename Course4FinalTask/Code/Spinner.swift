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
    internal static var backColor = UIColor.black.withAlphaComponent(0.7)
    
    public static func start() {
        if spinner == nil, let window = UIApplication.shared.keyWindow {
            let frame = UIScreen.main.bounds
            blackScreen = UIView(frame: frame)
            blackScreen!.backgroundColor = backColor
            spinner = UIActivityIndicatorView(frame: frame)
            spinner!.center = window.center
            spinner!.hidesWhenStopped = true
            window.addSubview(blackScreen!)
            window.addSubview(spinner!)
            spinner!.startAnimating()
        }
    }
   
    public static func stop() {
        if spinner != nil {
            spinner!.stopAnimating()
            spinner!.removeFromSuperview()
            blackScreen!.removeFromSuperview()
            spinner = nil
        }
        
    }

}
