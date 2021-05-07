//
//  UIViewController+Extension.swift
//  LineTVInterviewProject
//
//  Created by 李泰儀 on 2021/5/5.
//

import UIKit

extension UIViewController {
    public static func create(_ viewController: String, fromStoryboard storyboard: String) -> Self? {
        return UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: viewController) as? Self
    }
    
    public func showToast(message : String) {
        let toastView = UIView(frame: CGRect(x: (view.frame.size.width / 2) - ((view.frame.size.width - 32) / 2),
                                        y: view.frame.size.height - 88,
                                        width: view.frame.size.width - 32,
                                        height: 44))
        let toastLabel = UILabel()
        toastLabel.text = message
        
        toastView.addSubview(toastLabel)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.centerYAnchor.constraint(equalTo: toastView.centerYAnchor).isActive = true
        toastLabel.centerXAnchor.constraint(equalTo: toastView.centerXAnchor).isActive = true
        
        toastView.backgroundColor = .darkGray
        toastView.layer.cornerRadius = 10
        
        view.addSubview(toastView)
        
        toastView.alpha = 0
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: {
            toastView.alpha = 1
        }, completion: { _ in
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 3) {
                toastView.alpha = 0
            } completion: { _ in
                toastView.removeFromSuperview()
            }
        })
    }
}
