//
//  ChatBubbleCell.swift
//  FireBaseProject
//
//  Created by kübra demir on 1.06.2026.
//

import UIKit
import SnapKit

final class ChatBubbleCell: UITableViewCell {

    static let identifier = "ChatBubbleCell"

    // MARK: - UI

    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.text = "🐾"
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()

    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        return view
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.hidesWhenStopped = true
        ai.color = .systemGray
        return ai
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(avatarLabel)
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(activityIndicator)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Configure

    func configure(with bubble: ChatBubble) {

        if bubble.isLoading {
            layoutAsAssistant()
            messageLabel.isHidden = true
            activityIndicator.startAnimating()
            bubbleView.snp.remakeConstraints {
                $0.top.equalToSuperview().offset(4)
                $0.bottom.equalToSuperview().offset(-4)
                $0.leading.equalTo(avatarLabel.snp.trailing).offset(8)
                $0.width.equalTo(60)
                $0.height.equalTo(40)
            }
            activityIndicator.snp.remakeConstraints {
                $0.center.equalToSuperview()
            }
            return
        }

        activityIndicator.stopAnimating()
        messageLabel.isHidden = false
        messageLabel.text = bubble.text

        switch bubble.role {
        case .user:
            layoutAsUser()
        case .assistant:
            layoutAsAssistant()
        }

        messageLabel.snp.remakeConstraints {
            $0.edges.equalToSuperview().inset(
                UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
            )
        }
    }

    // MARK: - Layout helpers

    private func layoutAsUser() {

        avatarLabel.isHidden = true
        bubbleView.backgroundColor = UIColor(
            red: 110/255, green: 170/255, blue: 135/255, alpha: 1
        )
        messageLabel.textColor = .white

        bubbleView.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.bottom.equalToSuperview().offset(-4)
            $0.trailing.equalToSuperview().offset(-16)
            $0.leading.greaterThanOrEqualToSuperview().offset(70)
        }

        avatarLabel.snp.remakeConstraints {
            $0.size.equalTo(CGSize.zero)
        }
    }

    private func layoutAsAssistant() {

        avatarLabel.isHidden = false
        bubbleView.backgroundColor = .white
        messageLabel.textColor = .label

        avatarLabel.snp.remakeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-8)
            $0.width.height.equalTo(28)
        }

        bubbleView.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.bottom.equalToSuperview().offset(-4)
            $0.leading.equalTo(avatarLabel.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().offset(-70)
        }
    }
}
