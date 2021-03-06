//
//  LoginViewController.swift
//  Study Notes
//
//  Created by Chad Rutherford on 7/14/20.
//

import CoreData
import UIKit

class StudyModeViewController: UIViewController {
	
	let cardView: CardView = {
		let view = CardView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .systemBackground
		view.layer.borderWidth = 2
		view.layer.borderColor = UIColor.label.cgColor
		view.layer.cornerRadius = 10
		view.layer.masksToBounds = true
		return view
	}()
	
	let nextButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		let attributes: [NSAttributedString.Key : Any] = [
			NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .semibold),
			NSAttributedString.Key.foregroundColor : UIColor.white
		]
		button.setAttributedTitle(NSAttributedString(string: "Next", attributes: attributes), for: .normal)
		button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
		return button
	}()
	
	let newButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(systemName: "plus")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)), for: .normal)
		button.tintColor = .white
		button.addTarget(self, action: #selector(addCardTapped), for: .touchUpInside)
		return button
	}()
	
	var showing = true
	var index = 0
	var category: Category?
	var results: [Note]? {
		didSet {
			updateViews()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configureUI()
		updateViews()
		performFetch()
		setupTapGestures()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.isNavigationBarHidden = true
		index = 0
		performFetch()
		updateViews()
	}
	
	private func configureUI() {
		let gradient = CAGradientLayer()
		gradient.frame = view.bounds
		gradient.colors = [
			UIColor.systemTeal.cgColor,
			UIColor.systemBlue.cgColor
		]
		view.layer.insertSublayer(gradient, at: 0)
		view.addSubview(nextButton)
		view.addSubview(cardView)
		view.addSubview(newButton)
		
		NSLayoutConstraint.activate([
			newButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
			newButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
			
			cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
			cardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
			cardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			cardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
			
			nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
			nextButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
		])
	}
	
	private func performFetch() {
		guard let category = category,
			  let title = category.title else { return }
		let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "category.title == %@", "\(title)")
		let results = try! CoreDataStack.shared.mainContext.fetch(fetchRequest)
		self.results = results
	}
	
	private func updateViews() {
		guard let results = results,
			  index <= results.count - 1 else { return }
		cardView.answerLabel.text = results[index].answer
		cardView.cluesStackView.isHidden = true
		let clues = results[index].clues?.array as! [Clue]
		for view in cardView.cluesStackView.arrangedSubviews {
			view.removeFromSuperview()
		}
		for clue in clues {
			let label = UILabel()
			label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
			label.textColor = .label
			label.text = "- \(clue.text ?? "")"
			label.numberOfLines = 0
			cardView.cluesStackView.addArrangedSubview(label)
		}
		cardView.setNeedsLayout()
	}
	
	private func setupTapGestures() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
		tap.numberOfTapsRequired = 1
		cardView.addGestureRecognizer(tap)
		cardView.isUserInteractionEnabled = true
	}
	
	@objc private func viewTapped(_ recognizer: UITapGestureRecognizer) {
		if showing {
			UIView.transition(with: self.cardView, duration: 1, options: .transitionFlipFromRight, animations: {
				self.cardView.answerLabel.isHidden = true
				self.cardView.cluesStackView.isHidden = false
				self.showing = false
			})
		} else {
			UIView.transition(with: self.cardView, duration: 1, options: .transitionFlipFromRight, animations: {
				self.cardView.answerLabel.isHidden = false
				self.cardView.cluesStackView.isHidden = true
				self.showing = true
			})
		}
	}
	
	@objc private func nextButtonTapped() {
		index += 1
		updateViews()
	}
	
	@objc private func addCardTapped() {
		let addCardVC = AddCardViewController(nibName: nil, bundle: nil)
		self.navigationController?.pushViewController(addCardVC, animated: true)
	}
}
