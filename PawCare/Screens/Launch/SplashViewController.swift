//
//  Untitled.swift
//  FireBaseProject
//
//  Created by kübra demir on 21.05.2026.
//

import UIKit
import SnapKit
import FirebaseAuth

final class SplashViewController: UIViewController {

    // MARK: - UI

    private let logoContainer: UIView = {
        let view = UIView()

        view.backgroundColor = UIColor(
            red: 142/255,
            green: 191/255,
            blue: 168/255,
            alpha: 1
        )

        view.layer.cornerRadius = 40

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 12
        view.layer.shadowOffset = CGSize(width: 0, height: 6)

        return view
    }()

    private let pawImageView: UIImageView = {
        let imageView = UIImageView()

        imageView.image = UIImage(systemName: "pawprint.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()

        label.text = "PawCare"
        label.font = .systemFont(
            ofSize: 38,
            weight: .bold
        )

        label.textColor = UIColor(
            red: 46/255,
            green: 95/255,
            blue: 73/255,
            alpha: 1
        )

        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()

        label.text = "Happy pets, happy life."
        label.font = .systemFont(ofSize: 18)

        label.textColor = .gray

        return label
    }()

    private let progressBackground: UIView = {
        let view = UIView()

        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 4

        return view
    }()

    private let progressBar: UIView = {
        let view = UIView()

        view.backgroundColor = UIColor(
            red: 70/255,
            green: 153/255,
            blue: 110/255,
            alpha: 1
        )

        view.layer.cornerRadius = 4

        return view
    }()

    private var progressWidth: Constraint?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        startAnimation()
    }

    // MARK: - UI

    private func configureUI() {

        view.backgroundColor = .white

        view.addSubview(logoContainer)
        logoContainer.addSubview(pawImageView)

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        view.addSubview(progressBackground)
        progressBackground.addSubview(progressBar)

        makeConstraints()
    }

    private func makeConstraints() {

        logoContainer.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-120)

            $0.width.height.equalTo(140)
        }

        pawImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(60)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(logoContainer.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }

        progressBackground.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-100)

            $0.centerX.equalToSuperview()

            $0.width.equalTo(240)
            $0.height.equalTo(8)
        }

        progressBar.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()

            progressWidth = $0.width.equalTo(0).constraint
        }
    }

    // MARK: - Animation

    private func startAnimation() {

        // logo dönmesi

        let rotation = CABasicAnimation(
            keyPath: "transform.rotation"
        )

        rotation.toValue = Double.pi * 2
        rotation.duration = 2
        rotation.repeatCount = .infinity

        logoContainer.layer.add(
            rotation,
            forKey: "rotation"
        )

        // progress

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.2
        ) {

            self.progressWidth?.update(
                offset: 240
            )

            UIView.animate(
                withDuration: 2
            ) {
                self.view.layoutIfNeeded()
            }
        }

        // ekran geçişi

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 2.3
        ) {

            if Auth.auth().currentUser != nil {
                self.setRootViewController(MainTabBarController())
            } else {
                self.navigationController?
                    .pushViewController(
                        WelcomeViewController(),
                        animated: true
                    )
            }
        }
    }

    private func setRootViewController(_ vc: UIViewController) {

        guard
            let windowScene = UIApplication.shared
                .connectedScenes
                .first as? UIWindowScene,
            let window = windowScene.windows.first
        else { return }

        window.rootViewController = vc

        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }
}
