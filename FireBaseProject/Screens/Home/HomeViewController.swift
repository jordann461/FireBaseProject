import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

final class HomeViewController: UIViewController {

    // MARK: - Data

    private let petsViewModel = PetsViewModel()

    // MARK: - Header (outside scroll)

    private let headerCard: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)
        v.layer.cornerRadius = 32
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return v
    }()

    private let greetingLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = UIColor(white: 1, alpha: 0.70)
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 26, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let avatarView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 110/255, green: 170/255, blue: 135/255, alpha: 1)
        v.layer.cornerRadius = 22
        return v
    }()

    private let avatarLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    // MARK: - Scroll

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentView = UIView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 245/255, green: 248/255, blue: 246/255, alpha: 1)
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupHeader()
        setupScroll()
        // callback'i bir kez kur, veriler viewWillAppear'da yüklenecek
        petsViewModel.onUpdate = { [weak self] in
            self?.petsCollectionView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUser()
        petsViewModel.loadPets()
    }

    // MARK: - User Info

    private var timeGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning ☀️"
        case 12..<17: return "Good afternoon 🌤"
        default:      return "Good evening 🌙"
        }
    }

    private func populateUser() {
        greetingLabel.text = timeGreeting

        // If Firebase Auth already has the display name, use it immediately
        if let n = Auth.auth().currentUser?.displayName, !n.isEmpty {
            applyName(n)
            return
        }

        // Fallback: fetch from Firestore (handles users registered before display name was saved)
        guard let uid = Auth.auth().currentUser?.uid else {
            applyName("there")
            return
        }

        Firestore.firestore().collection("users").document(uid).getDocument { [weak self] snapshot, _ in
            let name = snapshot?.data()?["name"] as? String ?? "there"
            DispatchQueue.main.async { self?.applyName(name) }
        }
    }

    private func applyName(_ name: String) {
        nameLabel.text = name
        avatarLabel.text = String(name.prefix(1)).uppercased()
    }

    private func loadPets() {
        petsViewModel.onUpdate = { [weak self] in
            self?.petsCollectionView.reloadData()
        }
        petsViewModel.loadPets()
    }

    // MARK: - Header

    private func setupHeader() {
        view.addSubview(headerCard)
        headerCard.addSubview(greetingLabel)
        headerCard.addSubview(nameLabel)
        headerCard.addSubview(avatarView)
        avatarView.addSubview(avatarLabel)
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarTapped)))

        headerCard.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        avatarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(18)
            $0.trailing.equalToSuperview().inset(24)
            $0.width.height.equalTo(44)
        }
        avatarLabel.snp.makeConstraints { $0.center.equalToSuperview() }

        greetingLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(22)
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.lessThanOrEqualTo(avatarView.snp.leading).offset(-8)
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(greetingLabel.snp.bottom).offset(2)
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.lessThanOrEqualTo(avatarView.snp.leading).offset(-8)
            $0.bottom.equalToSuperview().inset(28)
        }
    }

    // MARK: - Scroll Setup

    private func setupScroll() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.snp.makeConstraints {
            $0.top.equalTo(headerCard.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        buildStatsRow()
        buildPetsSection()
        buildActionsSection()
        buildReminderSection()
        buildActivitySection()
    }

    // MARK: - Stats Row

    private lazy var statsRow: UIView = UIView()

    private func buildStatsRow() {
        contentView.addSubview(statsRow)

        statsRow.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(72)
        }

        let items: [(String, String, UIColor, Int)] = [
            ("3 Pets",     "pawprint.fill", UIColor(red: 95/255,  green: 173/255, blue: 142/255, alpha: 1), 1),
            ("1 Reminder", "bell.fill",     UIColor(red: 232/255, green: 168/255, blue: 124/255, alpha: 1), 1),
            ("AI Vet",     "stethoscope",   UIColor(red: 91/255,  green: 143/255, blue: 168/255, alpha: 1), 2)
        ]

        var previousCard: UIView? = nil
        items.forEach { title, icon, color, tabIndex in
            let card = makeStatCard(title: title, icon: icon, color: color, tabIndex: tabIndex)
            statsRow.addSubview(card)
            card.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
                if let prev = previousCard {
                    $0.leading.equalTo(prev.snp.trailing).offset(10)
                    $0.width.equalTo(prev)
                } else {
                    $0.leading.equalToSuperview()
                }
            }
            previousCard = card
        }
        previousCard?.snp.makeConstraints { $0.trailing.equalToSuperview() }
    }

    private func makeStatCard(title: String, icon: String, color: UIColor, tabIndex: Int) -> UIView {
        let card = UIControl()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.tag = tabIndex
        card.addTarget(self, action: #selector(actionTapped(_:)), for: .touchUpInside)
        card.addTarget(self, action: #selector(pressBegan(_:)), for: .touchDown)
        card.addTarget(self, action: #selector(pressEnded(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        let iconBg = UIView()
        iconBg.backgroundColor = color.withAlphaComponent(0.15)
        iconBg.layer.cornerRadius = 12
        iconBg.isUserInteractionEnabled = false

        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon,
                                 withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.isUserInteractionEnabled = false

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.isUserInteractionEnabled = false

        card.addSubview(iconBg)
        iconBg.addSubview(iconView)
        card.addSubview(label)

        iconBg.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(30)
        }
        iconView.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(14) }
        label.snp.makeConstraints {
            $0.top.equalTo(iconBg.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(4)
        }

        return card
    }

    // MARK: - Pets Section

    private lazy var petsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 14
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(PetCardCell.self, forCellWithReuseIdentifier: PetCardCell.identifier)
        return cv
    }()

    private func buildPetsSection() {
        let header = makeSectionHeader(title: "Your Pets", buttonTitle: "See all", action: #selector(seeAllPetsTapped))
        contentView.addSubview(header)
        contentView.addSubview(petsCollectionView)

        header.snp.makeConstraints {
            $0.top.equalTo(statsRow.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(28)
        }
        petsCollectionView.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(140)
        }
    }

    // MARK: - Quick Actions

    private lazy var topActionsRow = UIStackView()
    private lazy var bottomActionsRow = UIStackView()

    private func buildActionsSection() {
        let header = makeSectionHeader(title: "Quick Actions", buttonTitle: nil, action: nil)
        contentView.addSubview(header)
        contentView.addSubview(topActionsRow)
        contentView.addSubview(bottomActionsRow)

        for row in [topActionsRow, bottomActionsRow] {
            row.axis = .horizontal
            row.spacing = 14
            row.distribution = .fillEqually
        }

        let configs: [(String, String, UIColor, Int)] = [
            ("My Pets",  "pawprint.fill", UIColor(red: 95/255,  green: 173/255, blue: 142/255, alpha: 1), 1),
            ("Dr. Paws", "stethoscope",   UIColor(red: 91/255,  green: 143/255, blue: 168/255, alpha: 1), 2),
            ("Vaccines", "syringe.fill",  UIColor(red: 232/255, green: 168/255, blue: 124/255, alpha: 1), 1),
            ("Records",  "doc.text.fill", UIColor(red: 160/255, green: 126/255, blue: 200/255, alpha: 1), 1)
        ]

        topActionsRow.addArrangedSubview(makeActionCard(configs[0]))
        topActionsRow.addArrangedSubview(makeActionCard(configs[1]))
        bottomActionsRow.addArrangedSubview(makeActionCard(configs[2]))
        bottomActionsRow.addArrangedSubview(makeActionCard(configs[3]))

        header.snp.makeConstraints {
            $0.top.equalTo(petsCollectionView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(28)
        }
        topActionsRow.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(100)
        }
        bottomActionsRow.snp.makeConstraints {
            $0.top.equalTo(topActionsRow.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(100)
        }
    }

    private func makeActionCard(_ config: (String, String, UIColor, Int)) -> UIControl {
        let (title, icon, color, tabIndex) = config
        let card = UIControl()
        card.backgroundColor = color
        card.layer.cornerRadius = 20
        card.layer.shadowColor = color.cgColor
        card.layer.shadowOpacity = 0.30
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.tag = tabIndex

        let iconBg = UIView()
        iconBg.backgroundColor = UIColor(white: 1, alpha: 0.25)
        iconBg.layer.cornerRadius = 18
        iconBg.isUserInteractionEnabled = false

        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon,
                                 withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.isUserInteractionEnabled = false

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.isUserInteractionEnabled = false

        card.addSubview(iconBg)
        iconBg.addSubview(iconView)
        card.addSubview(label)

        iconBg.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(36)
        }
        iconView.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(18) }
        label.snp.makeConstraints {
            $0.top.equalTo(iconBg.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(4)
        }

        card.addTarget(self, action: #selector(actionTapped(_:)), for: .touchUpInside)
        card.addTarget(self, action: #selector(pressBegan(_:)), for: .touchDown)
        card.addTarget(self, action: #selector(pressEnded(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return card
    }

    @objc private func actionTapped(_ s: UIControl) { tabBarController?.selectedIndex = s.tag }
    @objc private func pressBegan(_ s: UIControl) {
        UIView.animate(withDuration: 0.1) { s.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) }
    }
    @objc private func pressEnded(_ s: UIControl) {
        UIView.animate(withDuration: 0.12) { s.transform = .identity }
    }
    @objc private func avatarTapped() { tabBarController?.selectedIndex = 3 }
    @objc private func seeAllPetsTapped() { tabBarController?.selectedIndex = 1 }

    // MARK: - Reminder

    private lazy var reminderCard = UIView()

    private func buildReminderSection() {
        let header = makeSectionHeader(title: "Upcoming Reminder", buttonTitle: nil, action: nil)
        contentView.addSubview(header)
        contentView.addSubview(reminderCard)

        reminderCard.backgroundColor = .white
        reminderCard.layer.cornerRadius = 20
        reminderCard.layer.shadowColor = UIColor.black.cgColor
        reminderCard.layer.shadowOpacity = 0.06
        reminderCard.layer.shadowRadius = 10
        reminderCard.layer.shadowOffset = CGSize(width: 0, height: 3)
        reminderCard.isUserInteractionEnabled = true
        reminderCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(seeAllPetsTapped)))

        let accent = UIView()
        accent.backgroundColor = UIColor(red: 110/255, green: 170/255, blue: 135/255, alpha: 1)
        accent.layer.cornerRadius = 3

        let iconCircle = UIView()
        iconCircle.backgroundColor = UIColor(red: 110/255, green: 170/255, blue: 135/255, alpha: 0.12)
        iconCircle.layer.cornerRadius = 20

        let iconImg = UIImageView()
        iconImg.image = UIImage(systemName: "syringe.fill",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))
        iconImg.tintColor = UIColor(red: 110/255, green: 170/255, blue: 135/255, alpha: 1)
        iconImg.contentMode = .scaleAspectFit

        let titleLbl = UILabel()
        titleLbl.text = "Rabies Vaccine"
        titleLbl.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLbl.textColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)

        let subtitleLbl = UILabel()
        subtitleLbl.text = "Luna  ·  Nov 28, 2026"
        subtitleLbl.font = .systemFont(ofSize: 12)
        subtitleLbl.textColor = .secondaryLabel

        let badge = UILabel()
        badge.text = "5 days"
        badge.font = .systemFont(ofSize: 12, weight: .semibold)
        badge.textColor = UIColor(red: 110/255, green: 170/255, blue: 135/255, alpha: 1)
        badge.backgroundColor = UIColor(red: 110/255, green: 170/255, blue: 135/255, alpha: 0.12)
        badge.layer.cornerRadius = 10
        badge.clipsToBounds = true
        badge.textAlignment = .center

        reminderCard.addSubview(accent)
        reminderCard.addSubview(iconCircle)
        iconCircle.addSubview(iconImg)
        reminderCard.addSubview(titleLbl)
        reminderCard.addSubview(subtitleLbl)
        reminderCard.addSubview(badge)

        accent.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview().inset(14)
            $0.width.equalTo(4)
        }
        iconCircle.snp.makeConstraints {
            $0.leading.equalTo(accent.snp.trailing).offset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        iconImg.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(16) }
        titleLbl.snp.makeConstraints {
            $0.leading.equalTo(iconCircle.snp.trailing).offset(12)
            $0.bottom.equalTo(iconCircle.snp.centerY).offset(-2)
            $0.trailing.lessThanOrEqualTo(badge.snp.leading).offset(-8)
        }
        subtitleLbl.snp.makeConstraints {
            $0.leading.equalTo(titleLbl)
            $0.top.equalTo(iconCircle.snp.centerY).offset(2)
            $0.trailing.lessThanOrEqualTo(badge.snp.leading).offset(-8)
        }
        badge.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(58)
            $0.height.equalTo(26)
        }

        header.snp.makeConstraints {
            $0.top.equalTo(bottomActionsRow.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(28)
        }
        reminderCard.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(80)
        }
    }

    // MARK: - Activity

    private func buildActivitySection() {
        let header = makeSectionHeader(title: "Recent Activity", buttonTitle: nil, action: nil)
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 10
        card.layer.shadowOffset = CGSize(width: 0, height: 3)

        contentView.addSubview(header)
        contentView.addSubview(card)

        let activities: [(String, String, UIColor)] = [
            ("Weight recorded",    "Today",       UIColor(red: 95/255,  green: 173/255, blue: 142/255, alpha: 1)),
            ("Vaccine scheduled",  "Yesterday",   UIColor(red: 232/255, green: 168/255, blue: 124/255, alpha: 1)),
            ("Vet chat completed", "2 days ago",  UIColor(red: 91/255,  green: 143/255, blue: 168/255, alpha: 1))
        ]

        var prev: UIView? = nil
        for (index, item) in activities.enumerated() {
            let row = makeActivityRow(text: item.0, time: item.1, color: item.2)
            card.addSubview(row)
            row.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(52)
                if let p = prev { $0.top.equalTo(p.snp.bottom) }
                else             { $0.top.equalToSuperview().offset(6) }
            }
            if index < activities.count - 1 {
                let sep = UIView()
                sep.backgroundColor = UIColor.systemGray5
                card.addSubview(sep)
                sep.snp.makeConstraints {
                    $0.leading.trailing.equalToSuperview().inset(20)
                    $0.top.equalTo(row.snp.bottom)
                    $0.height.equalTo(0.5)
                }
            }
            // Pin last row's bottom to card — this gives card its height
            if index == activities.count - 1 {
                row.snp.makeConstraints { $0.bottom.equalToSuperview().inset(6) }
            }
            prev = row
        }

        header.snp.makeConstraints {
            $0.top.equalTo(reminderCard.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(28)
        }
        card.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
            // This bottom constraint drives the entire contentView height → enables scrolling
            $0.bottom.equalToSuperview().inset(32)
        }
    }

    private func makeActivityRow(text: String, time: String, color: UIColor) -> UIView {
        let row = UIView()

        let dot = UIView()
        dot.backgroundColor = color.withAlphaComponent(0.18)
        dot.layer.cornerRadius = 13

        let fill = UIView()
        fill.backgroundColor = color
        fill.layer.cornerRadius = 5
        fill.isUserInteractionEnabled = false

        let textLbl = UILabel()
        textLbl.text = text
        textLbl.font = .systemFont(ofSize: 14, weight: .medium)
        textLbl.textColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1)

        let timeLbl = UILabel()
        timeLbl.text = time
        timeLbl.font = .systemFont(ofSize: 12)
        timeLbl.textColor = .tertiaryLabel

        row.addSubview(dot); dot.addSubview(fill)
        row.addSubview(textLbl); row.addSubview(timeLbl)

        dot.snp.makeConstraints  { $0.leading.centerY.equalToSuperview(); $0.width.height.equalTo(26) }
        fill.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(10) }
        textLbl.snp.makeConstraints { $0.leading.equalTo(dot.snp.trailing).offset(10); $0.centerY.equalToSuperview() }
        timeLbl.snp.makeConstraints { $0.trailing.centerY.equalToSuperview() }

        return row
    }

    // MARK: - Helpers

    private func makeSectionHeader(title: String, buttonTitle: String?, action: Selector?) -> UIView {
        let container = UIView()

        let lbl = UILabel()
        lbl.text = title
        lbl.font = .systemFont(ofSize: 18, weight: .bold)
        lbl.textColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)
        container.addSubview(lbl)
        lbl.snp.makeConstraints { $0.leading.centerY.equalToSuperview() }

        if let bt = buttonTitle, let sel = action {
            let btn = UIButton(type: .system)
            btn.setTitle(bt, for: .normal)
            btn.tintColor = UIColor(red: 110/255, green: 170/255, blue: 135/255, alpha: 1)
            btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            btn.addTarget(self, action: sel, for: .touchUpInside)
            container.addSubview(btn)
            btn.snp.makeConstraints { $0.trailing.centerY.equalToSuperview() }
        }

        return container
    }
}

// MARK: - UICollectionView

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        petsViewModel.pets.count
    }

    func collectionView(_ cv: UICollectionView, cellForItemAt ip: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: PetCardCell.identifier, for: ip) as! PetCardCell
        cell.configure(pet: petsViewModel.pets[ip.item])
        return cell
    }

    func collectionView(_ cv: UICollectionView, layout l: UICollectionViewLayout, sizeForItemAt ip: IndexPath) -> CGSize {
        CGSize(width: 140, height: 130)
    }

    func collectionView(_ cv: UICollectionView, didSelectItemAt ip: IndexPath) {
        let pet = petsViewModel.pets[ip.item]
        let vc = PetDetailViewController(pet: pet)
        vc.onDeleted = { [weak self] in self?.loadPets() }
        vc.onUpdated = { [weak self] _ in self?.loadPets() }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Preview

import SwiftUI

struct HomeViewControllerPreview: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview { HomeViewController() }
            .ignoresSafeArea()
    }
}

struct UIViewControllerPreview: UIViewControllerRepresentable {
    let make: () -> UIViewController
    func makeUIViewController(context: Context) -> UIViewController { make() }
    func updateUIViewController(_ vc: UIViewController, context: Context) {}
}
