import UIKit
import SnapKit
import FirebaseRemoteConfig

final class WelcomeViewController: UIViewController {

    // MARK: - UI Components

    private let onboardingImageView: UIImageView = {
        let imageView = UIImageView()

        imageView.image = UIImage(named: "onboardingScreen")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        return imageView
    }()

    private let getStartedButton: UIButton = {
        let button = UIButton(type: .custom)

        button.backgroundColor = .clear
        button.layer.cornerRadius = 29

      
        button.clipsToBounds = false

        return button
    }()

    private let highlightView: UIView = {
        let view = UIView()

        view.backgroundColor = .white
        view.alpha = 0

        view.layer.cornerRadius = 40
        view.isUserInteractionEnabled = false

        return view
    }()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureActions()
        
    }

    // MARK: - Configure UI
    private func checkVersion() {

        let remoteConfig = RemoteConfig.remoteConfig()

      
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600
        remoteConfig.configSettings = settings
        

        remoteConfig.fetchAndActivate { [weak self] status, error in

            if let error = error {
                print(error.localizedDescription)
                return
            }

            let latestVersion =
            remoteConfig.configValue(
                forKey: "ios_app_version"
            ).stringValue

            let currentVersion =
            Bundle.main.infoDictionary?[
                "CFBundleShortVersionString"
            ] as? String ?? ""
            
            print("Current Version: \(currentVersion)")
            print("Latest Version: \(latestVersion)")

            if currentVersion.compare(
                latestVersion,
                options: .numeric
            ) == .orderedAscending {

                DispatchQueue.main.async {

                    let alert = UIAlertController(
                        title: "Update Required",
                        message: "A newer version of the app is available.",
                        preferredStyle: .alert
                    )

                    alert.addAction(
                        UIAlertAction(
                            title: "OK",
                            style: .default
                        )
                    )

                    self?.present(
                        alert,
                        animated: true
                    )
                }
            }
        }
    }
    private func configureUI() {

        navigationController?.setNavigationBarHidden(
            true,
            animated: false
        )

        view.backgroundColor = UIColor(
            red: 234/255,
            green: 245/255,
            blue: 240/255,
            alpha: 1
        )

        view.addSubview(onboardingImageView)
        view.addSubview(getStartedButton)

        getStartedButton.addSubview(highlightView)

        makeConstraints()
    }

    private func makeConstraints() {

        onboardingImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        getStartedButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()

            make.bottom.equalTo(
                view.safeAreaLayoutGuide
            ).offset(-14)

            make.width.equalTo(270)
            make.height.equalTo(58)
        }

        highlightView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - Actions

    private func configureActions() {

        getStartedButton.addTarget(
            self,
            action: #selector(buttonTouchDown),
            for: .touchDown
        )

        getStartedButton.addTarget(
            self,
            action: #selector(buttonTouchUp),
            for: [.touchUpInside,
                  .touchUpOutside,
                  .touchCancel]
        )

        getStartedButton.addTarget(
            self,
            action: #selector(getStartedTapped),
            for: .touchUpInside
        )
    }

    @objc
    private func buttonTouchDown() {

        UIView.animate(withDuration: 0.12) {

            self.highlightView.alpha = 0.15

            self.highlightView.transform =
            CGAffineTransform(
                scaleX: 1.12,
                y: 1.12
            )
        }
    }

    @objc
    private func buttonTouchUp() {

        UIView.animate(withDuration: 0.18) {

            self.highlightView.alpha = 0

            self.highlightView.transform = .identity
        }
    }

    @objc
    private func getStartedTapped() {

        print("Get Started tapped")

         let vc = RegisterViewController()
         navigationController?.pushViewController(vc,animated: true)
    }
}
