import UIKit
import SnapKit

final class PetsViewController: UIViewController {

    // MARK: - Data

    private let viewModel = PetsViewModel()

    // MARK: - UI

    private let loadingIndicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .large)
        a.color = UIColor(red: 110/255, green: 170/255, blue: 135/255, alpha: 1)
        a.hidesWhenStopped = true
        return a
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 90
        tv.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
        tv.dataSource = self
        tv.delegate = self
        tv.isHidden = true
        tv.register(PetListCell.self, forCellReuseIdentifier: PetListCell.identifier)
        return tv
    }()

    private let emptyView: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Evcil Hayvanlarım"
        view.backgroundColor = UIColor(red: 245/255, green: 248/255, blue: 246/255, alpha: 1)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 110/255, green: 170/255, blue: 135/255, alpha: 1)

        configureUI()
        bindViewModel()
        loadingIndicator.startAnimating()
        viewModel.loadPets()
    }

    // MARK: - UI Setup

    private func configureUI() {
        view.addSubview(tableView)
        view.addSubview(emptyView)
        view.addSubview(loadingIndicator)

        buildEmptyView()

        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        emptyView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        loadingIndicator.snp.makeConstraints { $0.center.equalToSuperview() }
    }

    private func buildEmptyView() {
        let iconLabel = UILabel()
        iconLabel.text = "🐾"
        iconLabel.font = .systemFont(ofSize: 64)
        iconLabel.textAlignment = .center

        let titleLabel = UILabel()
        titleLabel.text = "Henüz hayvan yok"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = UIColor(red: 46/255, green: 95/255, blue: 73/255, alpha: 1)
        titleLabel.textAlignment = .center

        let subLabel = UILabel()
        subLabel.text = "Eklemek için sağ üstteki + butonuna dokun"
        subLabel.font = .systemFont(ofSize: 15)
        subLabel.textColor = .secondaryLabel
        subLabel.textAlignment = .center
        subLabel.numberOfLines = 2

        let addButton = UIButton(type: .system)
        addButton.setTitle("Hayvan Ekle", for: .normal)
        addButton.tintColor = .white
        addButton.backgroundColor = UIColor(red: 110/255, green: 170/255, blue: 135/255, alpha: 1)
        addButton.layer.cornerRadius = 22
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        emptyView.addSubview(iconLabel)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(subLabel)
        emptyView.addSubview(addButton)

        iconLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-80)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        subLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(40)
        }
        addButton.snp.makeConstraints {
            $0.top.equalTo(subLabel.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(160)
            $0.height.equalTo(44)
        }
    }

    private func bindViewModel() {

        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            loadingIndicator.stopAnimating()
            tableView.reloadData()
            let isEmpty = viewModel.pets.isEmpty
            emptyView.isHidden = !isEmpty
            tableView.isHidden = isEmpty
        }

        viewModel.onError = { [weak self] message in
            guard let self else { return }
            loadingIndicator.stopAnimating()
            emptyView.isHidden = false
            tableView.isHidden = true
            let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
        }
    }

    // MARK: - Actions

    @objc private func addTapped() {
        let vc = AddPetViewController()
        vc.onPetAdded = { [weak self] pet in self?.viewModel.addPet(pet) }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

// MARK: - UITableView

extension PetsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.pets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: PetListCell.identifier, for: indexPath) as! PetListCell
        cell.configure(with: viewModel.pets[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let pet = viewModel.pets[indexPath.row]
        let vc = PetDetailViewController(pet: pet)
        vc.onDeleted = { [weak self] in
            self?.viewModel.loadPets()
        }
        vc.onUpdated = { [weak self] updated in
            self?.viewModel.loadPets()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Sil") { [weak self] _, _, completion in
            self?.viewModel.deletePet(at: indexPath.row)
            completion(true)
        }
        delete.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
