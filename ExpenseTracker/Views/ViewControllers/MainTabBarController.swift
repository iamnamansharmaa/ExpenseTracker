//
//  MainTabBarController.swift
//  ExpenseTracker
//
//  Created by Naman Sharma on 28/02/25.
//

import UIKit
class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dashboardVC = UINavigationController(rootViewController: DashboardVC())
        dashboardVC.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(systemName: "house.fill"), tag: 0)
        
        let logoutVC = UINavigationController(rootViewController: LogoutVC())
        logoutVC.tabBarItem = UITabBarItem(title: "Logout", image: UIImage(systemName: "power"), tag: 1)
        
        viewControllers = [dashboardVC, logoutVC]
    }
}
