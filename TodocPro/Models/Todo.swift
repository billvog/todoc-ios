//
//  Todo.swift
//  TodocPro
//
//  Created by Vasilis Voyiadjis on 19/8/22.
//

import Foundation
import SQLite

struct Todo {
	let id: String
	var shortText: String
	var done: Bool
	let createdAt: Date
	
	var onDoneChanged: ((Bool) -> Void)!
}
