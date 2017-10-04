//
//  RSSelectionMenuController.swift
//  RSSelectionMenu
//
//  Created by Rushi on 29/09/17.
//  Copyright © 2017 Rushi Sangani. All rights reserved.
//

import UIKit

/// RSSelectionMenuController
class RSSelectionMenu: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    open static let `default`: RSSelectionMenu = {
        return UIStoryboard.instantiateRSSelectionMenu()
    }()
    
    /// datasource for tableView
    fileprivate var dataSource: RSSelectionMenuDataSource?
    
    /// delegate for tableView
    fileprivate var delegate: RSSelectionMenuDelegate?
    
    /// delegate for search controller
    fileprivate var searchControllerDelegate: RSSelectionMenuSearchDelegate?
    
    /// delegate for search bar search result
    fileprivate var searchBarResultDelegate: UISearchBarResult?
    
    /// selection type - default is single selection
    public var selectionType: SelectionType = .single
    
    /// unique key for comparision when datasource is other than String or Int array
    public var uniqueKey: String = ""
    
    /// controller should dissmiss on selection - default is true for single selection
    var shouldDismissOnSelect: Bool = true
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup
    fileprivate func setup() {
        tableView.dataSource = dataSource
        tableView.delegate = delegate
        tableView.tableFooterView = UIView()
        
        addSearchController()
    }
}

// MARK:- Public
extension RSSelectionMenu {
    
    /// Initialize
    
    /// default init
    func initWith(dataSource: DataSource, uniqueKey: String? = "", cellType: CellType? = .basic, configuration: @escaping UITableViewCellConfiguration) -> RSSelectionMenu {
        
        self.uniqueKey = uniqueKey!
        self.dataSource = RSSelectionMenuDataSource(dataSource: dataSource, forCellType: cellType!, configuration: configuration)
        return self
    }
    
    /// init with selection type
    func initWith(selectionType: SelectionType, dataSource: DataSource, uniqueKey: String? = "", cellType: CellType? = .basic, configuration: @escaping UITableViewCellConfiguration) -> RSSelectionMenu {
        
        self.selectionType = selectionType
        self.uniqueKey = uniqueKey!
        self.dataSource = RSSelectionMenuDataSource(dataSource: dataSource, forCellType: cellType!, configuration: configuration)
        return self
    }
    
    /// Selection event
    func didSelectRow(dismissOnSelect: Bool? = true, delegate: @escaping UITableViewCellSelection)  {
        self.shouldDismissOnSelect = dismissOnSelect!
        self.delegate = RSSelectionMenuDelegate(delegate: delegate)
    }
    
    /// Searchbar
    func addSearchBar(withCompletion: @escaping UISearchBarResult) {
        self.searchBarResultDelegate = withCompletion
    }
    
    /// Show
    func show(from: UIViewController) {
        from.present(self, animated: true, completion: nil)
    }
    
    /// show as popover
    func showAsPopover(from: UIView, with contentSize: CGSize, inViewController: UIViewController) {
        
        self.modalPresentationStyle = .popover
        self.preferredContentSize = contentSize
        
        let popover = self.popoverPresentationController!
        popover.delegate = self
        
        popover.permittedArrowDirections = .up
        popover.sourceView = from
        popover.sourceRect = (from.superview?.convert(from.bounds, to: nil))!
        
        inViewController.present(self, animated: true) {
            self.view.backgroundColor = UIColor.clear
        }
    }
    
    /// dismiss
    func dismiss() {
        
        if self.isPresented() {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//MARK:- Private
extension RSSelectionMenu {

    /// checks if searchbar needs to add
    fileprivate func addSearchBar() -> Bool {
        return (self.searchBarResultDelegate != nil)
    }
    
    /// adds search controller if search is enabled
    fileprivate func addSearchController() {
        guard addSearchBar() else { return }
        
        self.searchControllerDelegate = RSSelectionMenuSearchDelegate(controller: self, tableView: tableView)
        
        // search event
        self.searchControllerDelegate?.didSearch = { [weak self] (searchText) in
            self?.onDidStartSearch(text: searchText)
        }
    }
    
    /// called on searchcontroller search event
    fileprivate func onDidStartSearch(text: String) {
        
        let filteredDataSource = !text.isEmpty ? self.searchBarResultDelegate!(text) : []
        self.dataSource?.update(dataSource: filteredDataSource, inTableView: tableView)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension RSSelectionMenu : UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.dismiss()
    }
}
