//
//  AddTodoViewController.swift
//  TodocPro
//
//  Created by Vasilis Voyiadjis on 21/8/22.
//

import UIKit

class AddTodoViewController: UIViewController {
	
	@IBOutlet weak var todoShortTextField: UITextField!
	@IBOutlet weak var notifyMeSwitch: UISwitch!
	@IBOutlet weak var notifyDateTimeLabel: UILabel!
	@IBOutlet weak var notifyDateContainerView: UIView!
	@IBOutlet weak var notifyDatePicker: UIDatePicker!
	
	var addTodoCallback: ((Todo) -> Bool)!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		notifyDatePicker.minimumDate = Date.now
		didChangeNotifyDateTime(self)
		
		notifyDateContainerView.isHidden = true
		notifyMeSwitch.isOn = false
		
		self.dismissKeyboard()
    }
	
	@IBAction private func didTapAddButton(_ sender: Any) {
		guard let todoShortText = todoShortTextField.text else { return }
		
		if (todoShortText.isEmpty) {
			self.showError(withTitle: "Task Failed", message: "Please fill in the \"Todo Brief Description\" field to proceed.")
			return
		}
		
		let newTodo = Todo(
			id: "",
			shortText: todoShortText,
			done: false,
			notify: notifyMeSwitch.isOn,
			notifyDateTime: notifyMeSwitch.isOn ? notifyDatePicker.date : Date.distantPast,
			createdAt: Date.now
		)
		
		if (!self.addTodoCallback(newTodo)) {
			return
		}
		
		dismiss(animated: true)
	}
	
	@IBAction private func didTapCancelButton(_ sender: Any) {
		dismiss(animated: true)
	}
	
	@IBAction private func didTapNotifyMeSwitch(_ sender: Any) {
		if (notifyMeSwitch.isOn) {
			// if the switch is on, check if we have authorization to send notifications
			// if not, turn the swift back to off and display a message
			TodoNotificationManager.requestAuthorization { [weak self] granted in
				if (!granted) {
					DispatchQueue.main.async { [weak self] in
						self?.notifyMeSwitch.isOn = false
						self?.showError(
							withTitle: "Permission denied",
							message: "Todoc is not able to schedule local notifications.\nIf you want to get notified for this todo, please give Todoc permission in Settings."
						)
					}
				}
				else {
					DispatchQueue.main.async { [weak self] in
						self?.notifyDateContainerView.isHidden = false
					}
				}
			}
		}
		else {
			notifyDateContainerView.isHidden = true
		}
	}
	
	@IBAction private func didChangeNotifyDateTime(_ sender: Any) {
		let notifyDate = notifyDatePicker.date
		
		let calendar = Calendar.current
		let notifyDateComponents = calendar.dateComponents([.year], from: notifyDate)
		let todayDateComponents = calendar.dateComponents([.year], from: Date.now)
		
		let dateFormatter = DateFormatter()
		if (notifyDateComponents.year! > todayDateComponents.year!) {
			// in case of different year include it in format
			dateFormatter.dateFormat = "dd MMMM YYYY, HH:mm"
		} else {
			dateFormatter.dateFormat = "dd MMMM, HH:mm"
		}
		
		let formattedDate = dateFormatter.string(from: notifyDatePicker.date)
		
		notifyDateTimeLabel.text = "You'll get notified at: \(formattedDate)"
	}
}
