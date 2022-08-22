//
//  Todo.swift
//  TodocPro
//
//  Created by Vasilis Voyiadjis on 19/8/22.
//

import Foundation

struct Todo {
	let id: String
	var shortText: String
	var done: Bool
	var notify: Bool
	var notifyDateTime: Date
	let createdAt: Date
	
	var onDoneChanged: ((Bool) -> Void)!
}
