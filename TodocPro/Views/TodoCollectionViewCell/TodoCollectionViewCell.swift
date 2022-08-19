//
//  TodoCollectionViewCell.swift
//  TodocPro
//
//  Created by Vasilis Voyiadjis on 18/8/22.
//

import UIKit

class TodoCollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var todoText: UILabel!
	
	static let identifier = "TodoCollectionViewCell"
	static func nib() -> UINib {
		return UINib(nibName: "TodoCollectionViewCell", bundle: nil)
	}
	
	override func awakeFromNib() {
        super.awakeFromNib()
    }
	
	func configure(withTodo todo: Todo) {
		self.todoText.text = todo.shortText
	}
}

extension TodoCollectionViewCell {
	// This makes sure the cell it's taking the full width of the screen.
	override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
		setNeedsLayout()
		layoutIfNeeded()
	   
		let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
		var frame = layoutAttributes.frame
		frame.size.height = ceil(size.height)
		layoutAttributes.frame = frame
	   
		return layoutAttributes
	}
}
