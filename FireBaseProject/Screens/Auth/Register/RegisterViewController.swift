import UIKit
import SnapKit

final class RegisterViewController: UIViewController {

    // MARK: - State

    private var isLoginMode = true  // varsayılan: giriş ekranı

    // MARK: - UI

    private let viewModel = RegisterViewModel()

    private let logoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 142/255, green: 191/255, blue: 168/255, alpha: 1)
        view.layer.cornerRadius = 45
        return view
    }()

    private let pawImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "pawprint.fill")
        iv.tintColor = .white
        return iv
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .large)
        a.color = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)
        a.hidesWhenStopped = true
        return a
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)
        return l
    }()

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 35
        return v
    }()

    private let nameTextField: UITextField = UITextField()
    private let emailTextField: UITextField = UITextField()
    private let passwordTextField: UITextField = UITextField()

    // Ana aksiyon butonu (Giriş Yap / Hesap Oluştur)
    private let primaryButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = UIColor(red: 110/255, green: 170/255, blue: 135/255, alpha: 1)
        b.tintColor = .white
        b.titleLabel?.font = .boldSystemFont(ofSize: 18)
        b.layer.cornerRadius = 25
        return b
    }()

    private let forgotButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Şifremi Unuttum", for: .normal)
        b.tintColor = .gray
        return b
    }()

    // Mod değiştirme satırı: "Hesabın yok mu? Kayıt Ol"
    private let toggleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        return l
    }()

    private let toggleButton: UIButton = {
        let b = UIButton(type: .system)
        b.tintColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)
        b.titleLabel?.font = .boldSystemFont(ofSize: 14)
        return b
    }()

    private let toggleStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center
        return sv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 234/255, green: 245/255, blue: 240/255, alpha: 1)
        configureUI()
        configureActions()
        hideKeyboardWhenTapped()
        applyMode(animated: false)
    }

    // MARK: - UI Setup

    private func configureUI() {
        view.addSubview(logoView)
        logoView.addSubview(pawImageView)
        view.addSubview(activityIndicator)
        view.addSubview(titleLabel)
        view.addSubview(cardView)

        [nameTextField, emailTextField, passwordTextField,
         primaryButton, forgotButton, toggleStack].forEach { cardView.addSubview($0) }

        toggleStack.addArrangedSubview(toggleLabel)
        toggleStack.addArrangedSubview(toggleButton)

        setupTextFields()
        makeConstraints()
    }

    private func setupTextFields() {
        [nameTextField, emailTextField, passwordTextField].forEach { tf in
            tf.backgroundColor = .systemGray6
            tf.layer.cornerRadius = 18
            tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
            tf.leftViewMode = .always
        }
        nameTextField.placeholder = "🐾 Ad Soyad"
        emailTextField.placeholder = "📧 E-posta"
        passwordTextField.placeholder = "🔒 Şifre"
        passwordTextField.isSecureTextEntry = true
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
    }

    private func makeConstraints() {
        logoView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(90)
        }
        pawImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(logoView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        cardView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(25)
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.height.equalTo(360)   // login yüksekliği (başlangıç)
        }

        nameTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(55)
        }
        emailTextField.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(20)
            $0.leading.trailing.height.equalTo(nameTextField)
        }
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(20)
            $0.leading.trailing.height.equalTo(nameTextField)
        }
        primaryButton.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(30)
            $0.leading.trailing.equalTo(nameTextField)
            $0.height.equalTo(55)
        }
        forgotButton.snp.makeConstraints {
            $0.top.equalTo(primaryButton.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
        }
        toggleStack.snp.makeConstraints {
            $0.top.equalTo(forgotButton.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    // MARK: - Mode

    private func applyMode(animated: Bool) {
        let loginHeight: CGFloat = 360
        let registerHeight: CGFloat = 440

        if isLoginMode {
            titleLabel.text = "Tekrar Hoş Geldin 👋"
            primaryButton.setTitle("Giriş Yap", for: .normal)
            toggleLabel.text = "Hesabın yok mu?"
            toggleButton.setTitle("Kayıt Ol", for: .normal)
            forgotButton.isHidden = false
        } else {
            titleLabel.text = "PawCare'e Hoş Geldin 🐾"
            primaryButton.setTitle("Hesap Oluştur", for: .normal)
            toggleLabel.text = "Zaten hesabın var mı?"
            toggleButton.setTitle("Giriş Yap", for: .normal)
            forgotButton.isHidden = true
        }

        let block = {
            self.nameTextField.isHidden = self.isLoginMode
            self.nameTextField.alpha   = self.isLoginMode ? 0 : 1
            self.cardView.snp.updateConstraints {
                $0.height.equalTo(self.isLoginMode ? loginHeight : registerHeight)
            }
            self.view.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: block)
        } else {
            block()
        }
    }

    // MARK: - Actions

    private func configureActions() {
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        forgotButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        toggleButton.addTarget(self, action: #selector(toggleModeTapped), for: .touchUpInside)
    }

    @objc private func toggleModeTapped() {
        isLoginMode.toggle()
        view.endEditing(true)
        applyMode(animated: true)
    }

    @objc private func primaryTapped() {
        if isLoginMode { loginTapped() } else { registerTapped() }
    }

    private func loginTapped() {
        let email    = emailTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password = passwordTextField.text ?? ""

        guard !email.isEmpty else {
            showAlert(title: "Hata", message: "E-posta adresi boş olamaz.")
            return
        }
        guard !password.isEmpty else {
            showAlert(title: "Hata", message: "Şifre boş olamaz.")
            return
        }

        view.endEditing(true)
        primaryButton.isEnabled = false
        activityIndicator.startAnimating()
        view.bringSubviewToFront(activityIndicator)

        AuthService.shared.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.activityIndicator.stopAnimating()
                self.primaryButton.isEnabled = true
                switch result {
                case .success:
                    self.navigateToMain()
                case .failure(let error):
                    self.showAlert(title: "Giriş Başarısız", message: error.localizedDescription)
                }
            }
        }
    }

    private func registerTapped() {
        let name     = nameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let email    = emailTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password = passwordTextField.text ?? ""

        guard !name.isEmpty else { showAlert(title: "Hata", message: "İsim boş olamaz."); return }
        guard !email.isEmpty else { showAlert(title: "Hata", message: "E-posta boş olamaz."); return }
        guard password.count >= 6 else {
            showAlert(title: "Hata", message: "Şifre en az 6 karakter olmalı.")
            return
        }

        view.endEditing(true)
        primaryButton.isEnabled = false
        activityIndicator.startAnimating()
        view.bringSubviewToFront(activityIndicator)

        viewModel.register(name: name, email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.activityIndicator.stopAnimating()
                self.primaryButton.isEnabled = true
                switch result {
                case .success:
                    self.navigateToMain()
                case .failure(let error):
                    self.showAlert(title: "Hata", message: error.localizedDescription)
                }
            }
        }
    }

    @objc private func forgotPasswordTapped() {
        let email = emailTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !email.isEmpty else {
            showAlert(title: "Hata", message: "Önce e-posta adresini gir.")
            return
        }
        AuthService.shared.resetPassword(email: email) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showAlert(title: "📩 E-posta Gönderildi", message: "Şifre sıfırlama bağlantısı gönderildi.")
                case .failure(let error):
                    self?.showAlert(title: "Hata", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Helpers

    private func hideKeyboardWhenTapped() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    private func navigateToMain() {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first
        else { return }
        window.rootViewController = MainTabBarController()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}
