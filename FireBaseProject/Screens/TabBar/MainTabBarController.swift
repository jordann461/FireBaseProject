import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTabs()
    }

    private func configureTabs() {

        let homeVC = UINavigationController(
            rootViewController: HomeViewController()
        )

        let petsVC = UINavigationController(
            rootViewController: PetsViewController()
        )

        let vetVC = UINavigationController(
            rootViewController: VetViewController()
        )

        let profileVC = UINavigationController(
            rootViewController: ProfileViewController()
        )

        homeVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house.fill"),
            tag: 0
        )

        petsVC.tabBarItem = UITabBarItem(
            title: "Pets",
            image: UIImage(systemName: "pawprint.fill"),
            tag: 1
        )

        vetVC.tabBarItem = UITabBarItem(
            title: "Dr. Paws",
            image: UIImage(systemName: "stethoscope"),
            tag: 2
        )

        profileVC.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.fill"),
            tag: 3
        )

        tabBar.tintColor = UIColor(
            red: 110/255,
            green: 170/255,
            blue: 135/255,
            alpha: 1
        )

        setViewControllers(
            [
                homeVC,
                petsVC,
                vetVC,
                profileVC
            ],
            animated: true
        )
    }
}
