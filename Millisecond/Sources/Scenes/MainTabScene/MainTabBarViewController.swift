//
//  MainTabBarViewController.swift
//  Millisecond
//
//  Created by RAFA on 9/28/24.
//

import UIKit

final class MainTabBarViewController: UITabBarController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .backgroundColor
        configureViewControllers()
    }

    // MARK: - UI

    private func configureViewControllers() {
        let home = createNavigationController(
            title: "홈",
            unselectedImage: "house",
            selectedImage: "house.fill",
            rootViewController: HomeViewController()
        )

        let leaderboard = createNavigationController(
            title: "리더보드",
            unselectedImage: "chart.bar",
            selectedImage: "chart.bar.fill",
            rootViewController: LeaderboardViewController()
        )

        let setting = createNavigationController(
            title: "설정",
            unselectedImage: "gearshape",
            selectedImage: "gearshape.fill",
            rootViewController: SettingViewController()
        )

        viewControllers = [home, leaderboard, setting]
    }

    // MARK: - Helpers

    private func createNavigationController(
        title: String,
        unselectedImage: String,
        selectedImage: String,
        rootViewController: UIViewController
    ) -> UINavigationController {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .backgroundColor
        appearance.shadowColor = .clear

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .white

        let tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: unselectedImage),
            selectedImage: UIImage(systemName: selectedImage)
        )

        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem = tabBarItem

        return navigationController
    }
}
