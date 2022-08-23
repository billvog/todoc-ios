//
//  EditTodoViewController.swift
//  TodocPro
//
//  Created by Vasilis Voyiadjis on 23/8/22.
//

import UIKit

class EditTodoViewController: UIViewController {
	
	var todo: Todo!
	
	@IBOutlet weak var todoShortTextField: UITextField!
	@IBOutlet weak var notifyMeSwitch: UISwitch!
	@IBOutlet weak var notifyDateTimeLabel: UILabel!
	@IBOutlet weak var notifyDateContainerView: UIView!
	@IBOutlet weak var notifyDatePicker: UIDatePicker!
	
	var saveTodoCallback: ((Todo) -> Bool)!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		self.dismissKeyboard()
		
		notifyDatePicker.minimumDate = Date.now
		didChangeNotifyDateTime(self)
		
		todoShortTextField.text = todo.shortText
		
		if (todo.notify) {
			notifyMeSwitch.isOn = true
			notifyDateContainerView.isHidden = false
			didTapNotifyMeSwitch(self)
			
			notifyDatePicker.date = todo.notifyDateTime
			didChangeNotifyDateTime(self)
		}
		else {
			notifyMeSwitch.isOn = false
			notifyDateContainerView.isHidden = true
		}
		
		startDateUpdateTimer()
    }
	
	func loadTodo(_ _todo: Todo) {
		todo = _todo
	}
	
	/// Keep date picker up to date.
	func startDateUpdateTimer() {
		let now = Date.timeIntervalSinceReferenceDate
		let delayFraction = trunc(now) - now
		let delay = 60.0 - Double(Int(now) % 60) + delayFraction

		func updateMinimumDate() {
			notifyDatePicker.minimumDate = Date.now
			if (notifyDatePicker.minimumDate! > notifyDatePicker.date) {
				notifyDatePicker.date = notifyDatePicker.minimumDate!
			}
			
			didChangeNotifyDateTime(self)
		}
		
		Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { timer in
			updateMinimumDate()
			Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
				updateMinimumDate()
			}
		}
	}
	
	@IBAction private func didTapDoneButton(_ sender: Any) {
		guard let todoShortText = todoShortTextField.text else { return }
		if (todoShortText.isEmpty) {
			showError(withTitle: "Task Failed", message: "Please fill in a short description for the todo.")
			return
		}
		
		todo.shortText = todoShortText
		todo.notify = notifyMeSwitch.isOn
		todo.notifyDateTime = notifyMeSwitch.isOn ? notifyDatePicker.date : Date.distantPast
		
		if (!saveTodoCallback(todo)) {
			showError(withTitle: "Task Failed", message: "Todoc encountered an error trying to update this todo.")
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
						self?.notifyDateContainerView.setIsHidden(false, animated: true)
					}
				}
			}
		}
		else {
			notifyDateContainerView.setIsHidden(true, animated: true)
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
