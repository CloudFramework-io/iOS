//
//  SelectLanguageViewController.swift
//  Pods
//
//  Created by gabmarfer on 16/06/16.
//
//

import UIKit

class SelectLanguageViewController: UITableViewController {
    let languageCellIdentifier = "LanguageCell"
    var activityIndicator: UIActivityIndicatorView
    
    let manager = Manager()
    
    var languages = [Language]()
    
    weak var fromViewController: UIViewController?
    
    var selectedLanguage: Language?
    
    init(fromViewController: UIViewController, selectedLanguage: Language?) {
        self.fromViewController = fromViewController
        self.selectedLanguage = selectedLanguage
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        
        super.init(style: .Plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(localize),
                                                         name: Manager.Notification.didChangeLanguageKey,
                                                         object: nil)
        localize()
        
        requestLanguages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: Manager.Notification.didChangeLanguageKey,
                                                            object: nil)
    }
    
    // MARK: - Setup
    func setupUI() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: languageCellIdentifier)
        
        let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(handleTapCancelButton))
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        
        tableView.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        let screenBounds = UIScreen.mainScreen().bounds;
        activityIndicator.frame = CGRectMake(CGRectGetMidX(screenBounds) - CGRectGetMidX(activityIndicator.bounds),
                                             CGRectGetMidY(screenBounds) - CGRectGetMidY(activityIndicator.bounds),
                                             CGRectGetWidth(activityIndicator.bounds),
                                             CGRectGetHeight(activityIndicator.bounds))
    }
    
    func localize() {
        navigationItem.title = manager.translationForKey("bloombees.mobileapp.language.title_language")
    }
    
    // MARK: - Endpoints calls
    func requestLanguages() {
        activityIndicator.startAnimating()
        manager.getAvailableLanguages { [weak self] (languagesArray) in
            self?.activityIndicator.stopAnimating()
            
            self?.languages = languagesArray
            
            self?.selectedLanguage = self?.getLanguageWithISOCode(self?.manager.currentLanguageISOCode)
            
            self?.tableView.reloadData()
        }
    }
    
    func setLanguage(language: Language) {
        activityIndicator.startAnimating()

        manager.setLanguage(language.isoCode!) { [weak self] in
            self?.activityIndicator.stopAnimating()
            
            self?.fromViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: - Actions
    func handleTapCancelButton(sender: AnyObject?) {
        fromViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Suplementary methods
    func getLanguageWithISOCode(_ isoCode: String?) -> Language? {
        guard let code = isoCode else {
            return nil
        }
        
        var foundLanguage: Language?
        for lang in languages {
            if lang.isoCode! == code {
                foundLanguage = lang
                break
            }
        }
        return foundLanguage
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(languageCellIdentifier, forIndexPath: indexPath)

        // Configure the cell...
        let language = languages[indexPath.row]
        cell.textLabel?.text = language.name!
        
        cell.accessoryType = (language.isoCode == selectedLanguage?.isoCode) ? .Checkmark : .None

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        // Select new cell
        
        let language = languages[indexPath.row]
        if (language.isoCode == selectedLanguage?.isoCode) {
            self.performSelector(#selector(SelectLanguageViewController.handleTapCancelButton(_:)), withObject: nil)
            return
        }
        
        // Deselect old cell
        if let selectedLang = selectedLanguage,
            oldCellIdx = languages.indexOf({$0.isoCode == selectedLang.isoCode}),
        oldCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: oldCellIdx, inSection: 0)) {
            oldCell.accessoryType = .None
        }
        
        // Select new cell
        if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
            newCell.accessoryType = .Checkmark
        }
        
        // Set new language
        setLanguage(language)
    }
}
