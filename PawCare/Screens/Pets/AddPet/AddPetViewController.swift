//
//  AddPetViewController.swift
//  FireBaseProject
//
//  Created by kübra demir on 1.06.2026.
//

import UIKit
import SnapKit

final class AddPetViewController: UIViewController {

    // MARK: - Callback

    var onPetAdded: ((Pet) -> Void)?

    // MARK: - State

    private var selectedType: Pet.PetType = .dog

    // MARK: - UI

    private let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "Animal Type"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var typeScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return sv
    }()

    private lazy var typeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
    }()

    private let nameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "🐾 Pet name"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 16
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        return tf
    }()

    private let breedField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "🔍 Breed"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 16
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        return tf
    }()

    private let ageField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "🎂 Age (years)"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 16
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.keyboardType = .numberPad
        return tf
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Pet", for: .normal)
        button.backgroundColor = UIColor(
            red: 110/255, green: 170/255, blue: 135/255, alpha: 1
        )
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Pet"
        view.backgroundColor = UIColor(
            red: 245/255, green: 248/255, blue: 246/255, alpha: 1
        )

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )

        configureUI()
    }

    // MARK: - UI Setup

    private func configureUI() {

        view.addSubview(typeLabel)
        view.addSubview(typeScrollView)
        typeScrollView.addSubview(typeStack)
        view.addSubview(nameField)
        view.addSubview(breedField)
        view.addSubview(ageField)
        view.addSubview(saveButton)

        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        setupTypeButtons()
        makeConstraints()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func setupTypeButtons() {

        Pet.PetType.allCases.forEach { type in

            let button = UIButton(type: .system)
            button.setTitle("\(type.emoji)\n\(type.rawValue.capitalized)", for: .normal)
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
            button.tintColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)
            button.layer.cornerRadius = 14
            button.tag = Pet.PetType.allCases.firstIndex(of: type) ?? 0

            updateTypeButton(button, selected: type == selectedType)
            button.addTarget(self, action: #selector(typeTapped(_:)), for: .touchUpInside)

            typeStack.addArrangedSubview(button)
        }
    }

    private func updateTypeButton(_ button: UIButton, selected: Bool) {
        button.backgroundColor = selected
            ? UIColor(red: 142/255, green: 191/255, blue: 168/255, alpha: 0.5)
            : UIColor(red: 142/255, green: 191/255, blue: 168/255, alpha: 0.12)
        button.layer.borderWidth = selected ? 1.5 : 0
        button.layer.borderColor = UIColor(
            red: 110/255, green: 170/255, blue: 135/255, alpha: 1
        ).cgColor
    }

    private func makeConstraints() {

        typeLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.leading.equalToSuperview().offset(24)
        }

        typeScrollView.snp.makeConstraints {
            $0.top.equalTo(typeLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(72)
        }

        typeStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }

        // 5 buttons with equal width based on scroll view width
        Pet.PetType.allCases.forEach { type in
            let idx = Pet.PetType.allCases.firstIndex(of: type) ?? 0
            let button = typeStack.arrangedSubviews[idx]
            button.snp.makeConstraints {
                $0.width.equalTo(72)
            }
        }

        nameField.snp.makeConstraints {
            $0.top.equalTo(typeScrollView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }

        breedField.snp.makeConstraints {
            $0.top.equalTo(nameField.snp.bottom).offset(14)
            $0.leading.trailing.height.equalTo(nameField)
        }

        ageField.snp.makeConstraints {
            $0.top.equalTo(breedField.snp.bottom).offset(14)
            $0.leading.trailing.height.equalTo(nameField)
        }

        saveButton.snp.makeConstraints {
            $0.top.equalTo(ageField.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(55)
        }
    }

    // MARK: - Actions

    @objc private func typeTapped(_ sender: UIButton) {

        let newType = Pet.PetType.allCases[sender.tag]
        selectedType = newType

        typeStack.arrangedSubviews.enumerated().forEach { index, view in
            if let btn = view as? UIButton {
                updateTypeButton(btn, selected: index == sender.tag)
            }
        }
    }

    @objc private func saveTapped() {

        guard
            let name = nameField.text, !name.trimmingCharacters(in: .whitespaces).isEmpty,
            let breed = breedField.text, !breed.trimmingCharacters(in: .whitespaces).isEmpty,
            let ageText = ageField.text, let age = Int(ageText), age > 0
        else {
            let alert = UIAlertController(
                title: "Missing Info",
                message: "Please fill in all fields correctly.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let pet = Pet(
            name: name.trimmingCharacters(in: .whitespaces),
            breed: breed.trimmingCharacters(in: .whitespaces),
            age: age,
            imageName: selectedType.defaultImageName,
            type: selectedType
        )

        onPetAdded?(pet)
        dismiss(animated: true)
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
