import UIKit
import SnapKit

final class PetCardCell: UICollectionViewCell {

    static let identifier = "PetCardCell"

    // MARK: - Subviews

    private let imageBg: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 142/255, green: 191/255, blue: 168/255, alpha: 0.25)
        v.layer.cornerRadius = 18
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.clipsToBounds = true
        return v
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private let emojiLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 38)
        l.textAlignment = .center
        l.isHidden = true
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .bold)
        l.textColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    private let breedLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 18
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowRadius = 10
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)

        contentView.addSubview(imageBg)
        imageBg.addSubview(imageView)
        imageBg.addSubview(emojiLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(breedLabel)

        imageBg.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }

        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        emojiLabel.snp.makeConstraints { $0.center.equalToSuperview() }

        nameLabel.snp.makeConstraints {
            $0.top.equalTo(imageBg.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(8)
        }

        breedLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(2)
            $0.leading.trailing.equalToSuperview().inset(8)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Configure

    func configure(pet: Pet) {
        nameLabel.text = pet.name
        breedLabel.text = pet.breed

        // her configure'da eski görüntüyü temizle
        imageView.image = nil

        if let urlString = pet.photoURL {
            if let image = decodeBase64(urlString) {
                imageView.image = image
                imageView.isHidden = false
                emojiLabel.isHidden = true
            } else if let url = URL(string: urlString) {
                imageView.isHidden = false
                emojiLabel.isHidden = true
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    guard let data, let image = UIImage(data: data) else { return }
                    DispatchQueue.main.async { self?.imageView.image = image }
                }.resume()
            } else {
                showFallback(pet: pet)
            }
        } else if let image = UIImage(named: pet.imageName) {
            imageView.image = image
            imageView.isHidden = false
            emojiLabel.isHidden = true
        } else {
            showFallback(pet: pet)
        }
    }

    private func showFallback(pet: Pet) {
        imageView.isHidden = true
        emojiLabel.isHidden = false
        emojiLabel.text = pet.type.emoji
    }

    private func decodeBase64(_ urlString: String) -> UIImage? {
        guard urlString.hasPrefix("data:image") else { return nil }
        let parts = urlString.components(separatedBy: ",")
        guard parts.count == 2, let data = Data(base64Encoded: parts[1]) else { return nil }
        return UIImage(data: data)
    }
}
