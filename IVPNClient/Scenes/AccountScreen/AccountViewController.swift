//
//  AccountViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 23/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import JGProgressHUD

class AccountViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var accountView: AccountView!
    
    // MARK: - Properties -
    
    private let hud = JGProgressHUD(style: .dark)
    private var viewModel = AccountViewModel(serviceStatus: Application.shared.serviceStatus, authentication: Application.shared.authentication)
    private var serviceType: ServiceType = Application.shared.serviceStatus.currentPlan == "IVPN Pro" ? .pro : .standard
    
    // MARK: - @IBActions -
    
    @IBAction func addMoreTime(_ sender: Any) {
        present(NavigationManager.getSubscriptionViewController(), animated: true, completion: nil)
    }
    
    @IBAction func logOut(_ sender: Any) {
        showActionAlert(title: "Logout", message: "Are you sure you want to log out?", action: "Log out") { _ in
            self.logOut()
        }
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
        initNavigationBar()
        addObservers()
        accountView.setupView(viewModel: viewModel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        accountView.initQRCode(viewModel: viewModel)
    }
    
    deinit {
        removeObservers()
    }
    
    // MARK: - Observers -
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActivated), name: Notification.Name.SubscriptionActivated, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.SubscriptionActivated, object: nil)
    }
    
    // MARK: - Private methods -
    
    private func initNavigationBar() {
        if isPresentedModally {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissViewController(_:)))
        }
    }
    
    @objc private func subscriptionActivated() {
        let viewModel = AccountViewModel(serviceStatus: Application.shared.serviceStatus, authentication: Application.shared.authentication)
        accountView.setupView(viewModel: viewModel)
    }
    
}

// MARK: - UITableViewDelegate -

extension AccountViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 && serviceType == .standard {
            return 220
        }
        
        if indexPath.row == 0 && serviceType == .pro {
            return 150
        }
        
        return 71
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footer = view as? UITableViewHeaderFooterView {
            footer.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
    }
    
}

// MARK: - SessionManagerDelegate -

extension AccountViewController {
    
    override func deleteSessionStart() {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Removing session from IVPN server..."
        hud.show(in: (navigationController?.view)!)
    }
    
    override func deleteSessionSuccess() {
        hud.delegate = self
        hud.dismiss()
    }
    
    override func deleteSessionFailure() {
        hud.delegate = self
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.detailTextLabel.text = "There was an error with removing session"
        hud.show(in: (navigationController?.view)!)
        hud.dismiss(afterDelay: 2)
    }
    
    override func deleteSessionSkip() {
        tableView.reloadData()
        showAlert(title: "Session removed from IVPN server", message: "You are successfully logged out") { _ in
            self.navigationController?.dismiss(animated: true)
        }
    }
    
}

// MARK: - JGProgressHUDDelegate -

extension AccountViewController: JGProgressHUDDelegate {
    
    func progressHUD(_ progressHUD: JGProgressHUD, didDismissFrom view: UIView) {
        tableView.reloadData()
        showAlert(title: "Session removed from IVPN server", message: "You are successfully logged out") { _ in
            self.navigationController?.dismiss(animated: true)
        }
    }
    
}