//
//  ViewController.swift
//  LineTVInterviewProject
//
//  Created by 李泰儀 on 2021/5/5.
//

import UIKit
import Alamofire

class DramaListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    
    private var cancelButton: UIButton? {
        searchBar.value(forKey: "cancelButton") as? UIButton
    }
    
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    
    private var dramaViewModel = DramaViewModel()
    
    private var isShowSearchHistory = false {
        didSet {
            if oldValue != isShowSearchHistory {
                setRefresh(isRefresh: !isShowSearchHistory)
            }
            tableView.reloadData()
        }
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkManager.shared.delegate = self
        registerCell()
        configureUI()
        configureSearchBar()
        fetchDramas()
    }
    
    // MARK: - Basic setup
    private func registerCell() {
        tableView.register(UINib(nibName: "DramaTableViewCell", bundle: nil), forCellReuseIdentifier: "dramaTVCell")
        tableView.register(UINib(nibName: "HistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "historyTVCell")
    }
    
    private func configureUI() {
        navigationItem.title = "戲劇列表"
    }
    
    private func setRefresh(isRefresh: Bool) {
        if isRefresh {
            if !tableView.subviews.contains(refreshControl) {
                refreshControl.addTarget(self, action: #selector(refreshDevice), for: .valueChanged)
                tableView.addSubview(refreshControl)
            }
        }
        else {
            refreshControl.removeFromSuperview()
        }
    }
    
    @objc private func refreshDevice() {
        if !isShowSearchHistory {
            fetchDramas {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
                    self?.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    private func configureSearchBar() {
        cancelButton?.setImage(UIImage(systemName: "xmark"), for: .normal)
        cancelButton?.setTitle(nil, for: .normal)
        
        searchBar.text = dramaViewModel.searchHistory
        searchBar.setShowsCancelButton(!dramaViewModel.searchHistory.isEmpty, animated: true)
        showSearchBar(false)
    }
    
    private func showSearchBar(_ show: Bool) {
        searchBar.isHidden = !show
        searchBarTopConstraint.constant = show ? 0 : -56
    }
    
    private func showNoInternetUI() {
        let description = "無法連接網路"
        configureRefreshView(show: dramaViewModel.dramasCount == 0, description: description, buttonText: "請按一下重試")
    }
    
    // MARK: - Fetch Dramas
    private func fetchDramas(completion: (() -> ())? = nil) {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.style = .large
        activityIndicatorView.startAnimating()
        tableView.backgroundView = activityIndicatorView
        dramaViewModel.fetchDramas { [weak self] (result) in
            switch result {
            case .success(_):
                self?.tableView.reloadData()
                activityIndicatorView.stopAnimating()
                self?.tableView.backgroundView = nil
                self?.setRefresh(isRefresh: true)
                self?.showSearchBar(true)
            case .failure(let error):
                print("error = \(error.localizedDescription)")
                if NetworkManager.shared.status == .notReachable {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self?.showNoInternetUI()
                    }
                }
            }
            completion?()
        }
    }
    
    // MARK: - Refresh UI
    @IBOutlet var refreshView: UIView!
    @IBOutlet weak var refreshLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    
    private func configureRefreshView(show: Bool, description: String? = nil, buttonText: String? = nil) {
        tableView.backgroundView = show ? refreshView : nil
        refreshLabel.text = description
        refreshButton.setTitle(buttonText, for: .normal)
    }
    
    @IBAction func refreshButton(_ sender: UIButton) {
        fetchDramas()
    }
}

// MARK: - TableView
extension DramaListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isShowSearchHistory {
            return "最近搜尋"
        }
        else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShowSearchHistory {
            return dramaViewModel.searchHistoryCount
        }
        else {
            return dramaViewModel.dramasCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isShowSearchHistory {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "historyTVCell", for: indexPath) as? HistoryTableViewCell {
                cell.titleLabel.text = dramaViewModel.searchHistory(for: indexPath)
                cell.clickDelete = { [weak self] in
                    self?.dramaViewModel.deleteSearchHistory(indexPath: indexPath)
                    tableView.reloadData()
                }
                return cell
            }
        }
        else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "dramaTVCell", for: indexPath) as? DramaTableViewCell {
                cell.dramaTitleLabel.text = dramaViewModel.dramaName(for: indexPath)
                if let thumbData = dramaViewModel.dramaThumbData(for: indexPath) {
                    cell.dramaImageView.load(data: thumbData)
                }
                else {
                    cell.dramaImageView.load(urlString: dramaViewModel.dramaThumbString(for: indexPath),
                                             getImageData: { [weak self] in self?.dramaViewModel.setImageData(for: indexPath, urlString: $0, data: $1) })
                }
                cell.createdDateLabel.text = dramaViewModel.dramaCreatedDate(for: indexPath)
                cell.rateLabel.text = dramaViewModel.dramaRating(for: indexPath)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isShowSearchHistory {
            return 44
        }
        else {
            return 88
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isShowSearchHistory {
            let searchText = dramaViewModel.searchHistory(for: indexPath)
            dramaViewModel.searching(text: searchText)
            dramaViewModel.storeSearchHistory(text: searchText)
            isShowSearchHistory = searchText.isEmpty
            searchBar.text = searchText
        }
        else {
            if let searchText = searchBar.text, !searchText.isEmpty {
                dramaViewModel.storeSearchHistory(text: searchText)
            }
            if let dramaInfoViewController = DramaInfoViewController.create("DramaInfoViewController", fromStoryboard: "Main") {
                dramaInfoViewController.drama = dramaViewModel.getDrama(for: indexPath)
                navigationController?.pushViewController(dramaInfoViewController, animated: true)
            }
        }
    }
}

// MARK: - ScrollView
extension DramaListViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
        searchBar.searchTextField.resignFirstResponder()
        cancelButton?.isEnabled = true
    }
}

// MARK: - SearchBar
extension DramaListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("textDidChange")
        dramaViewModel.searching(text: searchText)
        isShowSearchHistory = searchText.isEmpty
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidBeginEditing")
        if let searchText = searchBar.text, searchText.isEmpty {
            isShowSearchHistory = true
        }
        
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidEndEditing")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarCancelButtonClicked")
        
        searchBar.resignFirstResponder()
        searchBar.text = ""
        if let searchText = searchBar.text {
            dramaViewModel.searching(text: searchText)
        }
        isShowSearchHistory = false
        
        cancelButton?.isEnabled = false
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text {
            dramaViewModel.storeSearchHistory(text: searchText)
        }
        
        cancelButton?.isEnabled = true
    }
}

// MARK: - NetworkObserver
extension DramaListViewController: NetworkObserver {
    func networkStateChanged(status: NetworkReachabilityManager.NetworkReachabilityStatus, networkManager: NetworkManager) {
        switch status {
        case .notReachable:
            print("notReachable")
            let description = "無法連接網路"
            showToast(message: description)
            showNoInternetUI()
        case .unknown :
            print("unknown")
        case .reachable(.ethernetOrWiFi):
            print("reachable(.ethernetOrWiFi)")
        case .reachable(.cellular):
            print("reachable(.cellular)")
        }
    }
}
