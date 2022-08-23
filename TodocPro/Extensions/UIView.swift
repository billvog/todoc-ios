//
//  UIView.swift
//  TodocPro
//
//  Created by Vasilis Voyiadjis on 23/8/22.
//

import Foundation
import UIKit

extension UIView {
	func setIsHidden(_ hidden: Bool, animated: Bool) {
		if (animated) {
			if (self.isHidden && !hidden) {
				self.alpha = 0.0
				self.isHidden = false
			}
			
			UIView.animate(withDuration: 0.2, animations: {
				self.alpha = hidden ? 0.0 : 1.0
			}) { (complete) in
				self.isHidden = hidden
			}
		} else {
			self.isHidden = hidden
		}
	}
}
