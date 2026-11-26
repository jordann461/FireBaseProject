import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

final class ProfileViewController: UIViewController {

    // MARK: - UI

    private let avatarView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 142/255, green: 191/255, blue: 168/255, alpha: 1)
        v.layer.cornerRadius = 50
        return v
    }()

    private let avatarLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 36, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)
        l.textAlignment = .center
        return l
    }()

    private let emailLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        return l
    }()

    private let editNameButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "pencil.circle.fill",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        config.baseForegroundColor = UIColor(red: 110/255, green: 170/255, blue: 135/255, alpha: 1)
        let b = UIButton(configuration: config)
        return b
    }()

    private let signOutButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Sign Out", for: .normal)
        b.tintColor = .white
        b.backgroundColor = .systemRed
        b.layer.cornerRadius = 25
        b.titleLabel?.font = .boldSystemFont(ofSize: 18)
        return b
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 245/255, green: 248/255, blue: 246/255, alpha: 1)
        title = "Profile"
        configureUI()
        populateUser()
    }

    // MARK: - UI Setup

    private func configureUI() {
        view.addSubview(avatarView)
        avatarView.addSubview(avatarLabel)
        view.addSubview(nameLabel)
        view.addSubview(editNameButton)
        view.addSubview(emailLabel)
        view.addSubview(signOutButton)

        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
        editNameButton.addTarget(self, action: #selector(editNameTapped), for: .touchUpInside)

        avatarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(100)
        }
        avatarLabel.snp.makeConstraints { $0.center.equalToSuperview() }

        nameLabel.snp.makeConstraints {
            $0.top.equalTo(avatarView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        editNameButton.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.leading.equalTo(nameLabel.snp.trailing).offset(4)
        }
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
        }
        signOutButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(240)
            $0.height.equalTo(55)
        }
    }

    // MARK: - Populate

    private func populateUser() {
        guard let user = Auth.auth().currentUser else { return }
        emailLabel.text = user.email

        if let name = user.displayName, !name.isEmpty {
            applyName(name)
        } else {
            // Fetch from Firestore for users registered before display name was set
            Firestore.firestore().collection("users").document(user.uid).getDocument { [weak self] snap, _ in
                let name = snap?.data()?["name"] as? String ?? ""
                DispatchQueue.main.async { self?.applyName(name.isEmpty ? "Set your name" : name) }
            }
        }
    }

    private func applyName(_ name: String) {
        nameLabel.text = name
        let initial = name.first.map { String($0).uppercased() } ?? "?"
        avatarLabel.text = initial
    }

    // MARK: - Actions

    @objc private func editNameTapped() {
        let alert = UIAlertController(title: "Your Name", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Full name"
            tf.text = Auth.auth().currentUser?.displayName
            tf.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let name = alert.textFields?.first?.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            self?.saveName(name.trimmingCharacters(in: .whitespaces))
        })
        present(alert, animated: true)
    }

    private func saveName(_ name: String) {
        guard let user = Auth.auth().currentUser else { return }

        // Update Firebase Auth display name
        let req = user.createProfileChangeRequest()
        req.displayName = name
        req.commitChanges { _ in }

        // Update Firestore
        Firestore.firestore().collection("users").document(user.uid).updateData(["name": name])

        applyName(name)
    }

    @objc private func signOutTapped() {
        do {
            try Auth.auth().signOut()
            guard
                let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window = scene.windows.first
            else { return }
            let nav = UINavigationController(rootViewController: WelcomeViewController())
            window.rootViewController = nav
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        } catch {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
