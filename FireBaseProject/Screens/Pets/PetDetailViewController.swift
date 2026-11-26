import UIKit
import SnapKit
import PhotosUI

final class PetDetailViewController: UIViewController {

    // MARK: - Properties

    private var pet: Pet
    var onDeleted: (() -> Void)?
    var onUpdated: ((Pet) -> Void)?

    private let avatarSize: CGFloat = 120

    // MARK: - UI

    private let headerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)
        return v
    }()

    private let avatarContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 110/255, green: 170/255, blue: 135/255, alpha: 0.35)
        v.layer.borderWidth = 3
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        return v
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isHidden = true
        return iv
    }()

    private let emojiLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 54)
        l.textAlignment = .center
        return l
    }()

    private let photoLoadingIndicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .medium)
        a.color = .white
        a.hidesWhenStopped = true
        return a
    }()

    // small camera badge on avatar
    private let cameraButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "camera.fill",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold))
        config.baseBackgroundColor = UIColor(red: 110/255, green: 170/255, blue: 135/255, alpha: 1)
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 7)
        let b = UIButton(configuration: config)
        b.layer.borderWidth = 2
        b.layer.borderColor = UIColor.white.cgColor
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.2
        b.layer.shadowRadius = 4
        b.layer.shadowOffset = CGSize(width: 0, height: 2)
        return b
    }()

    private let uploadIndicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .medium)
        a.color = .white
        a.hidesWhenStopped = true
        return a
    }()

    private let infoCard: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 245/255, green: 248/255, blue: 246/255, alpha: 1)
        return v
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 24, weight: .bold)
        l.textColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)
        l.textAlignment = .center
        return l
    }()

    private let breedLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        return l
    }()

    // white details card (name/breed/age rows)
    private let detailsCard: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        return v
    }()

    private let editButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Bilgileri Düzenle"
        config.image = UIImage(systemName: "pencil",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 13))
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseBackgroundColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        let b = UIButton(configuration: config)
        b.layer.shadowColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1).cgColor
        b.layer.shadowOpacity = 0.25
        b.layer.shadowRadius = 8
        b.layer.shadowOffset = CGSize(width: 0, height: 4)
        return b
    }()

    private let deleteButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Hayvanı Sil"
        config.image = UIImage(systemName: "trash",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 13))
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .systemRed
        config.cornerStyle = .large
        let b = UIButton(configuration: config)
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.06
        b.layer.shadowRadius = 8
        b.layer.shadowOffset = CGSize(width: 0, height: 3)
        return b
    }()

    // MARK: - Init

    init(pet: Pet) {
        self.pet = pet
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 245/255, green: 248/255, blue: 246/255, alpha: 1)
        navigationItem.largeTitleDisplayMode = .never

        // Nav bar: transparent, white text/icons over green header
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white

        // Fixed corner radii (don't wait for layout)
        avatarContainer.layer.cornerRadius = avatarSize / 2
        avatarImageView.layer.cornerRadius  = avatarSize / 2
        cameraButton.layer.cornerRadius     = 20

        configureUI()
        populatePet()
    }

    // MARK: - UI Setup

    private func configureUI() {
        view.addSubview(headerView)
        view.addSubview(infoCard)

        // avatarContainer view'a eklendi (headerView'a değil) — infoCard'ın önünde görünsün
        view.addSubview(avatarContainer)
        avatarContainer.addSubview(avatarImageView)
        avatarContainer.addSubview(emojiLabel)
        avatarContainer.addSubview(photoLoadingIndicator)
        view.addSubview(cameraButton)
        cameraButton.addSubview(uploadIndicator)

        infoCard.addSubview(nameLabel)
        infoCard.addSubview(breedLabel)
        infoCard.addSubview(detailsCard)
        infoCard.addSubview(editButton)
        infoCard.addSubview(deleteButton)

        cameraButton.addTarget(self, action: #selector(cameraTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(cameraTapped))
        avatarContainer.isUserInteractionEnabled = true
        avatarContainer.addGestureRecognizer(avatarTap)

        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(220)
        }

        // avatar merkezi headerView'ın alt kenarında — üst yarı header'da, alt yarı infoCard'da
        avatarContainer.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(headerView.snp.bottom)
            $0.width.height.equalTo(avatarSize)
        }
        avatarImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        emojiLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        photoLoadingIndicator.snp.makeConstraints { $0.center.equalToSuperview() }

        // camera badge: avatar'ın sağ alt köşesi
        cameraButton.snp.makeConstraints {
            $0.width.height.equalTo(40)
            $0.centerX.equalTo(avatarContainer.snp.trailing).offset(-8)
            $0.centerY.equalTo(avatarContainer.snp.bottom).offset(-8)
        }
        uploadIndicator.snp.makeConstraints { $0.center.equalToSuperview() }

        infoCard.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        // avatar ve kamera butonu her zaman önde
        view.bringSubviewToFront(avatarContainer)
        view.bringSubviewToFront(cameraButton)

        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(avatarSize / 2 + 20)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        breedLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        // details rows card
        detailsCard.snp.makeConstraints {
            $0.top.equalTo(breedLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        buildDetailsRows()

        // butonlar ekranın altına sabitlendi (floating action pattern)
        deleteButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        editButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
            $0.bottom.equalTo(deleteButton.snp.top).offset(-10)
        }
    }

    private func buildDetailsRows() {
        let items: [(String, String)] = [
            ("person.text.rectangle", "İsim"),
            ("pawprint", "Irk"),
            ("birthday.cake", "Yaş")
        ]
        var prev: UIView? = nil
        for (index, item) in items.enumerated() {
            let row = makeDetailRow(icon: item.0, titleText: item.1, tag: index)
            detailsCard.addSubview(row)
            row.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(56)
                if let p = prev { $0.top.equalTo(p.snp.bottom) }
                else { $0.top.equalToSuperview() }
                if index == items.count - 1 { $0.bottom.equalToSuperview() }
            }
            if index < items.count - 1 {
                let sep = UIView(); sep.backgroundColor = UIColor.systemGray5
                detailsCard.addSubview(sep)
                sep.snp.makeConstraints {
                    $0.leading.trailing.equalToSuperview().inset(16)
                    $0.top.equalTo(row.snp.bottom)
                    $0.height.equalTo(0.5)
                }
            }
            prev = row
        }
    }

    private func makeDetailRow(icon: String, titleText: String, tag: Int) -> UIView {
        let row = UIView()
        let iconImg = UIImageView()
        iconImg.image = UIImage(systemName: icon,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .medium))
        iconImg.tintColor = UIColor(red: 110/255, green: 170/255, blue: 135/255, alpha: 1)
        iconImg.contentMode = .scaleAspectFit

        let titleLbl = UILabel()
        titleLbl.text = titleText
        titleLbl.font = .systemFont(ofSize: 13)
        titleLbl.textColor = .secondaryLabel

        let valueLbl = UILabel()
        valueLbl.font = .systemFont(ofSize: 15, weight: .semibold)
        valueLbl.textColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)
        valueLbl.textAlignment = .right
        valueLbl.tag = 100 + tag  // 100=name, 101=breed, 102=age

        row.addSubview(iconImg); row.addSubview(titleLbl); row.addSubview(valueLbl)
        iconImg.snp.makeConstraints { $0.leading.equalToSuperview().offset(16); $0.centerY.equalToSuperview(); $0.width.height.equalTo(20) }
        titleLbl.snp.makeConstraints { $0.leading.equalTo(iconImg.snp.trailing).offset(10); $0.centerY.equalToSuperview() }
        valueLbl.snp.makeConstraints { $0.trailing.equalToSuperview().inset(16); $0.centerY.equalToSuperview(); $0.leading.equalTo(titleLbl.snp.trailing).offset(8) }
        return row
    }

    // MARK: - Populate

    private func populatePet() {
        title = pet.name
        nameLabel.text = pet.name
        breedLabel.text = pet.type.emoji + "  \(pet.type.rawValue.capitalized)"

        (detailsCard.viewWithTag(100) as? UILabel)?.text = pet.name
        (detailsCard.viewWithTag(101) as? UILabel)?.text = pet.breed
        (detailsCard.viewWithTag(102) as? UILabel)?.text = "\(pet.age) yaş"

        if let urlString = pet.photoURL {
            showPhotoLoading(true)
            loadImage(from: urlString)
        } else {
            showLocalImage()
        }
    }

    private func showLocalImage() {
        if let image = UIImage(named: pet.imageName) {
            avatarImageView.image = image
            avatarImageView.isHidden = false
            emojiLabel.isHidden = true
        } else {
            avatarImageView.isHidden = true
            emojiLabel.isHidden = false
            emojiLabel.text = pet.type.emoji
        }
    }

    private func showPhotoLoading(_ loading: Bool) {
        if loading {
            photoLoadingIndicator.startAnimating()
            avatarImageView.isHidden = true
            emojiLabel.isHidden = true
        } else {
            photoLoadingIndicator.stopAnimating()
        }
    }

    private func loadImage(from urlString: String) {
        // base64 data URI (Firestore'da saklanan)
        if urlString.hasPrefix("data:image") {
            let parts = urlString.components(separatedBy: ",")
            if parts.count == 2, let data = Data(base64Encoded: parts[1]),
               let image = UIImage(data: data) {
                showPhotoLoading(false)
                avatarImageView.image = image
                avatarImageView.isHidden = false
                emojiLabel.isHidden = true
            } else {
                showPhotoLoading(false)
                showLocalImage()
            }
            return
        }
        // normal URL
        guard let url = URL(string: urlString) else { showPhotoLoading(false); showLocalImage(); return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.showPhotoLoading(false)
                if let data, let image = UIImage(data: data) {
                    self.avatarImageView.image = image
                    self.avatarImageView.isHidden = false
                    self.emojiLabel.isHidden = true
                } else {
                    self.showLocalImage()
                }
            }
        }.resume()
    }

    // MARK: - Actions

    @objc private func cameraTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func editTapped() {
        let menu = UIAlertController(title: "Ne düzenlemek istiyorsun?", message: nil, preferredStyle: .actionSheet)

        menu.addAction(UIAlertAction(title: "İsim, Irk ve Yaş", style: .default) { [weak self] _ in
            self?.showInfoEditAlert()
        })
        menu.addAction(UIAlertAction(title: "Hayvan Türü", style: .default) { [weak self] _ in
            self?.showTypeSelectionAlert()
        })
        menu.addAction(UIAlertAction(title: "İptal", style: .cancel))
        present(menu, animated: true)
    }

    private func showInfoEditAlert() {
        let alert = UIAlertController(title: "Bilgileri Düzenle", message: nil, preferredStyle: .alert)
        alert.addTextField { [weak self] tf in tf.text = self?.pet.name; tf.placeholder = "İsim" }
        alert.addTextField { [weak self] tf in tf.text = self?.pet.breed; tf.placeholder = "Irk" }
        alert.addTextField { [weak self] tf in
            tf.text = "\(self?.pet.age ?? 0)"; tf.placeholder = "Yaş"; tf.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Kaydet", style: .default) { [weak self] _ in
            guard let self else { return }
            let name  = alert.textFields?[0].text?.trimmingCharacters(in: .whitespaces) ?? pet.name
            let breed = alert.textFields?[1].text?.trimmingCharacters(in: .whitespaces) ?? pet.breed
            let age   = Int(alert.textFields?[2].text ?? "") ?? pet.age
            guard !name.isEmpty, !breed.isEmpty else { return }
            pet.name = name; pet.breed = breed; pet.age = age
            PetService.shared.updatePet(pet) { _ in }
            populatePet()
            onUpdated?(pet)
        })
        present(alert, animated: true)
    }

    private func showTypeSelectionAlert() {
        let alert = UIAlertController(title: "Hayvan Türü Seç", message: nil, preferredStyle: .actionSheet)
        for petType in Pet.PetType.allCases {
            let title = "\(petType.emoji)  \(petType.rawValue.capitalized)"
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                guard let self else { return }
                pet.type = petType
                pet.imageName = petType.defaultImageName
                PetService.shared.updatePet(pet) { _ in }
                populatePet()
                onUpdated?(pet)
            })
        }
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func deleteTapped() {
        let alert = UIAlertController(
            title: "\(pet.name) Silinsin mi?",
            message: "Bu işlem geri alınamaz.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sil", style: .destructive) { [weak self] _ in
            guard let self else { return }
            PetService.shared.deletePet(id: pet.id) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.onDeleted?()
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        })
        present(alert, animated: true)
    }

    private func setUploadInProgress(_ inProgress: Bool) {
        cameraButton.isEnabled = !inProgress
        if inProgress {
            cameraButton.configuration?.image = nil
            uploadIndicator.startAnimating()
        } else {
            uploadIndicator.stopAnimating()
            cameraButton.configuration?.image = UIImage(
                systemName: "camera.fill",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold))
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension PetDetailViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self, let image = object as? UIImage else { return }

            DispatchQueue.main.async {
                self.avatarImageView.image = image
                self.avatarImageView.isHidden = false
                self.emojiLabel.isHidden = true
                self.setUploadInProgress(true)
            }

            PetService.shared.savePhoto(image, petId: self.pet.id) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.setUploadInProgress(false)
                    switch result {
                    case .success(let url):
                        self.pet.photoURL = url
                        PetService.shared.updatePet(self.pet) { _ in }
                        self.onUpdated?(self.pet)
                    case .failure(let error):
                        let alert = UIAlertController(title: "Yükleme Başarısız",
                                                     message: error.localizedDescription,
                                                     preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
import SwiftUI
struct PetDetailPreview: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            let nav = UINavigationController(rootViewController: PetDetailViewController(pet: Pet(
                id: "1", name: "Milka", breed: "Poodle", age: 2, imageName: "dog", type: .dog
            )))
            return nav
        }.ignoresSafeArea()
    }
}
