//
//  PetListCell.swift
//  FireBaseProject
//
//  Created by kübra demir on 1.06.2026.
//

import UIKit
import SnapKit

final class PetListCell: UITableViewCell {

    static let identifier = "PetListCell"

    // MARK: - UI

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.06
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        return view
    }()

    private let petImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 28
        iv.backgroundColor = UIColor(
            red: 142/255, green: 191/255, blue: 168/255, alpha: 0.25
        )
        return iv
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()

    private let chevron: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = UIColor(
            red: 142/255, green: 191/255, blue: 168/255, alpha: 1
        )
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(cardView)
        cardView.addSubview(petImageView)
        cardView.addSubview(emojiLabel)
        cardView.addSubview(nameLabel)
        cardView.addSubview(detailLabel)
        cardView.addSubview(chevron)

        makeConstraints()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Constraints

    private func makeConstraints() {

        cardView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        petImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(56)
        }

        emojiLabel.snp.makeConstraints {
            $0.edges.equalTo(petImageView)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(petImageView.snp.trailing).offset(14)
            $0.top.equalToSuperview().offset(18)
            $0.trailing.equalTo(chevron.snp.leading).offset(-8)
        }

        detailLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().offset(-18)
            $0.trailing.equalTo(nameLabel)
        }

        chevron.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(10)
            $0.height.equalTo(16)
        }
    }

    // MARK: - Helpers

    private func loadImage(from urlString: String) -> UIImage? {
        guard urlString.hasPrefix("data:image") else { return nil }
        let parts = urlString.components(separatedBy: ",")
        guard parts.count == 2, let data = Data(base64Encoded: parts[1]) else { return nil }
        return UIImage(data: data)
    }

    // MARK: - Configure

    func configure(with pet: Pet) {

        nameLabel.text = pet.name
        detailLabel.text = "\(pet.breed) · \(pet.age) yaşında"

        if let urlString = pet.photoURL {
            if let image = loadImage(from: urlString) {
                petImageView.image = image
                petImageView.isHidden = false
                emojiLabel.isHidden = true
            } else if let url = URL(string: urlString) {
                petImageView.isHidden = false
                emojiLabel.isHidden = true
                petImageView.image = nil
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    guard let data, let image = UIImage(data: data) else { return }
                    DispatchQueue.main.async { self?.petImageView.image = image }
                }.resume()
            }
        } else if let image = UIImage(named: pet.imageName) {
            petImageView.image = image
            petImageView.isHidden = false
            emojiLabel.isHidden = true
        } else {
            petImageView.isHidden = true
            emojiLabel.isHidden = false
            emojiLabel.text = pet.type.emoji
        }
    }
}
