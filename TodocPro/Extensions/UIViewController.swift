//
//  UIViewController.swift
//  TodocPro
//
//  Created by Vasilis Voyiadjis on 19/8/22.
//

import Foundation
import UIKit

extension UIViewController {
	func showError(withTitle title: String, message: String) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alertController.addAction(okAction)
		present(alertController, animated: true, completion: nil)
	}
	
	
	/// Allow the user to click outside of a text field and dismiss the keyboard.
	func dismissKeyboard() {
	   let tap: UITapGestureRecognizer = UITapGestureRecognizer( target:self, action: #selector(UIViewController.dismissKeyboardTouchOutside))
	   tap.cancelsTouchesInView = false
	   view.addGestureRecognizer(tap)
	}
	
	@objc private func dismissKeyboardTouchOutside() {
	   view.endEditing(true)
	}
}
