//
//  TodoNotificationManager.swift
//  TodocPro
//
//  Created by Vasilis Voyiadjis on 21/8/22.
//

import UIKit

class TodoNotificationManager {
	static func requestAuthorization(completion: @escaping  (Bool) -> Void) {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _  in
			completion(granted)
		}
	}
	
	static func addNotificationForTodo(todo: Todo, completion: @escaping ((Error?) -> Void)) {
		let content = UNMutableNotificationContent()
		content.title = "Todoc Notification"
		content.body = todo.shortText
		content.sound = .default
		
		// Configure the recurring date.
		let dateComponents = Calendar.current.dateComponents(
			[
				.second, .minute, .hour,
				.day, .month, .year
			],
			from: todo.notifyDateTime
		)
		   
		// Create the trigger as a repeating event.
		let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
		
		// Create the request
		let notificationId = todo.id
		let request = UNNotificationRequest(identifier: notificationId,
					content: content, trigger: trigger)

		// Schedule the request with the system.
		let notificationCenter = UNUserNotificationCenter.current()
		notificationCenter.add(request) { (error) in
			completion(error)
		}
	}
}
