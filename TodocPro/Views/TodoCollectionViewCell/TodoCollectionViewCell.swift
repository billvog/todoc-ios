//
//  TodoCollectionViewCell.swift
//  TodocPro
//
//  Created by Vasilis Voyiadjis on 18/8/22.
//

import UIKit

class TodoCollectionViewCell: UICollectionViewCell {

	var todo: Todo!
	@IBOutlet weak var todoText: UILabel!
	@IBOutlet weak var isTodoDoneButton: UIButton!
	
	static let identifier = "TodoCollectionViewCell"
	static func nib() -> UINib {
		return UINib(nibName: "TodoCollectionViewCell", bundle: nil)
	}
	
	override func awakeFromNib() {
        super.awakeFromNib()
		self.isTodoDoneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
    }
	
	func configure(withTodo _todo: Todo) {
		self.todo = _todo
		self.setTodoDone(isDone: todo.done)
	}
	
	@objc private func didTapDoneButton() {
		todo.onDoneChanged(!todo.done)
	}
	
	private func setTodoDone(isDone: Bool) {
		todoText.attributedText = NSAttributedString(string: todo.shortText).withStrikeThrough(isDone ? 1 : 0)
		isTodoDoneButton.setImage(
			.init(systemName: isDone ? "circle.inset.filled" : "circle"),
			for: .normal
		)
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
