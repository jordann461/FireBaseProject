import UIKit
import SnapKit

// MARK: - Model

struct ChatBubble {
    enum Role { case user, assistant }
    let role: Role
    var text: String
    var isLoading: Bool = false
}

// MARK: - ViewController

final class VetViewController: UIViewController {

    // MARK: - Data

    private var messages: [ChatBubble] = []

    // MARK: - Unavailability state

    private let unavailableView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private let unavailableIconLabel: UILabel = {
        let label = UILabel()
        label.text = "🤖"
        label.font = .systemFont(ofSize: 56)
        label.textAlignment = .center
        return label
    }()

    private let unavailableTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Apple Intelligence Gerekli"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)
        label.textAlignment = .center
        return label
    }()

    private let unavailableMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - UI

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.keyboardDismissMode = .interactive
        tv.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 80
        tv.dataSource = self
        tv.register(ChatBubbleCell.self, forCellReuseIdentifier: ChatBubbleCell.identifier)
        return tv
    }()

    private let inputBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.07
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        return view
    }()

    private let chipsScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return sv
    }()

    private let chipsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        return sv
    }()

    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Dr. Paws'a sor..."
        tf.backgroundColor = UIColor(
            red: 245/255, green: 248/255, blue: 246/255, alpha: 1
        )
        tf.layer.cornerRadius = 22
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.returnKeyType = .send
        return tf
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        button.setImage(
            UIImage(systemName: "arrow.up.circle.fill", withConfiguration: config),
            for: .normal
        )
        button.tintColor = UIColor(red: 110/255, green: 170/255, blue: 135/255, alpha: 1)
        return button
    }()

    private var inputBarBottomConstraint: Constraint?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Dr. Paws 🐾"
        view.backgroundColor = UIColor(
            red: 245/255, green: 248/255, blue: 246/255, alpha: 1
        )

        configureUI()
        configureKeyboard()
        checkAIAvailability()
    }

    // MARK: - UI Setup

    private func configureUI() {

        // Unavailable state
        view.addSubview(unavailableView)
        unavailableView.addSubview(unavailableIconLabel)
        unavailableView.addSubview(unavailableTitleLabel)
        unavailableView.addSubview(unavailableMessageLabel)

        unavailableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        unavailableIconLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-40)
        }
        unavailableTitleLabel.snp.makeConstraints {
            $0.top.equalTo(unavailableIconLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        unavailableMessageLabel.snp.makeConstraints {
            $0.top.equalTo(unavailableTitleLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(32)
        }

        view.addSubview(tableView)
        view.addSubview(inputBar)

        inputBar.addSubview(chipsScrollView)
        chipsScrollView.addSubview(chipsStack)
        inputBar.addSubview(textField)
        inputBar.addSubview(sendButton)

        textField.delegate = self
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        setupChips()
        makeConstraints()
    }

    private func setupChips() {

        let quickActions = [
            "🤒 Evcil hayvan hasta",
            "💉 Aşı takvimi",
            "🚨 Acil belirtiler",
            "🍽️ Beslenme önerisi",
            "😾 Davranış sorunları"
        ]

        quickActions.forEach { title in
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
            button.tintColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)
            button.backgroundColor = UIColor(
                red: 142/255, green: 191/255, blue: 168/255, alpha: 0.2
            )
            button.layer.cornerRadius = 15
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 14, bottom: 7, trailing: 14)
            button.configuration = config
            button.configurationUpdateHandler = { btn in
                btn.configuration?.baseForegroundColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)
            }
            button.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
            chipsStack.addArrangedSubview(button)
        }
    }

    private func makeConstraints() {

        tableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(inputBar.snp.top)
        }

        inputBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            inputBarBottomConstraint = $0.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }

        chipsScrollView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(36)
        }

        chipsStack.snp.makeConstraints {
            $0.edges.height.equalToSuperview()
        }

        textField.snp.makeConstraints {
            $0.top.equalTo(chipsScrollView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(sendButton.snp.leading).offset(-8)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().offset(-10)
        }

        sendButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(textField)
            $0.width.height.equalTo(44)
        }
    }

    // MARK: - Availability Check

    private func checkAIAvailability() {
        if #available(iOS 26.0, *) {
            if VetAIService.shared.isAvailable {
                unavailableView.isHidden = true
                tableView.isHidden = false
                inputBar.isHidden = false
                addGreeting()
            } else {
                showUnavailableState(VetAIService.shared.unavailabilityMessage)
            }
        } else {
            showUnavailableState("Dr. Paws AI, Apple Intelligence etkin iOS 26 veya üzerini gerektirir.")
        }
    }

    private func showUnavailableState(_ message: String) {
        unavailableView.isHidden = false
        tableView.isHidden = true
        inputBar.isHidden = true
        unavailableMessageLabel.text = message
    }

    // MARK: - Messages

    private func addGreeting() {
        let greeting = "Merhaba! Ben Dr. Paws, cihaz üzerinde çalışan yapay zeka veterinerinizim 🐾\n\nTamamen cihazınızda çalışıyorum — internet gerekmez. Belirtiler, aşılar, beslenme, ilaç bilgisi ve daha fazlası konusunda yardımcı olabilirim. Bugün evcil hayvanınız için nasıl yardımcı olabilirim?"
        messages.append(ChatBubble(role: .assistant, text: greeting))
        tableView.reloadData()
    }

    private func send(_ text: String) {
        guard #available(iOS 26.0, *) else { return }

        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        messages.append(ChatBubble(role: .user, text: trimmed))

        // Typing indicator
        messages.append(ChatBubble(role: .assistant, text: "", isLoading: true))
        tableView.reloadData()
        scrollToBottom()

        Task {
            do {
                let reply = try await VetAIService.shared.send(trimmed)
                await MainActor.run {
                    self.messages.removeLast()
                    self.messages.append(ChatBubble(role: .assistant, text: reply))
                    self.tableView.reloadData()
                    self.scrollToBottom()
                }
            } catch {
                await MainActor.run {
                    self.messages.removeLast()
                    self.messages.append(ChatBubble(
                        role: .assistant,
                        text: "Üzgünüm, bir hata oluştu. Lütfen tekrar deneyin.\n\n(\(error.localizedDescription))"
                    ))
                    self.tableView.reloadData()
                    self.scrollToBottom()
                }
            }
        }
    }

    private func scrollToBottom() {
        guard messages.count > 0 else { return }
        tableView.scrollToRow(
            at: IndexPath(row: messages.count - 1, section: 0),
            at: .bottom,
            animated: true
        )
    }

    // MARK: - Actions

    @objc private func sendTapped() {
        let text = textField.text ?? ""
        textField.text = ""
        textField.resignFirstResponder()
        send(text)
    }

    @objc private func chipTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        textField.text = ""
        textField.resignFirstResponder()
        send(title)
    }

    // MARK: - Keyboard

    private func configureKeyboard() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {

        guard
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        let offset = -(keyboardFrame.height - view.safeAreaInsets.bottom)

        UIView.animate(withDuration: duration) {
            self.inputBarBottomConstraint?.update(offset: offset)
            self.view.layoutIfNeeded()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToBottom()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {

        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        UIView.animate(withDuration: duration) {
            self.inputBarBottomConstraint?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDataSource

extension VetViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        messages.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatBubbleCell.identifier,
            for: indexPath
        ) as! ChatBubbleCell

        cell.configure(with: messages[indexPath.row])
        return cell
    }
}

// MARK: - UITextFieldDelegate

extension VetViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped()
        return true
    }
}
