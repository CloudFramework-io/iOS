//
//  Manager.swift
//  Pods
//
//  Created by gabmarfer on 03/06/16.
//
//

import Foundation

public class Manager {
    private var languageVersionDict = [String: NSDate]()
    
    /// File URL to save current language and its version date
    private let fileURL: NSURL = {
        let documentDirectoryURLs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectoryURL = documentDirectoryURLs.first!
        return documentDirectoryURL.URLByAppendingPathComponent("languageVersion.archive")
    }()
    
    /// Load version date of saved language
    private func loadLanguageVersion() {
        if let versionDict = NSDictionary(contentsOfURL: fileURL) as? [String: NSDate] {
            languageVersionDict = versionDict
        }
    }
    
    /// Save language and version date
    private func saveLanguageVersion(lang: String, versionDate: NSDate) {
        print("Saving language: \(lang) with date: \(versionDate)")

        languageVersionDict.removeAll()
        languageVersionDict[lang] = versionDate
        
        let versionDict = languageVersionDict as NSDictionary
        if !versionDict.writeToURL(fileURL, atomically: true) {
            print("Could not save version dict")
        }
    }
    
    /// Data Controller to persist downloaded Tags
    private var dataController: DataController
    
    /// Language and Version Date
    private var languageVersion: (language: String?, versionDate: NSDate?)
    
    /// The language of the device
    var deviceLanguage: String {
        let language = NSLocale.preferredLanguages().first!
        let index = language.startIndex.advancedBy(2)
        return language.substringToIndex(index)
    }
    

    public init() {
        self.dataController = DataController()
        loadLanguageVersion()
    }
    
    deinit {
        print("SELF has been deinit")
    }
    
    // MARK: Public methods
    
    /**
        Set a given language
     
        If the language is already set, this method will check if there are available new tags and will download
        them if necessary. Otherway, this method will download the tags for the new language.
     
        - Parameter lang: The language to set
     */
    public func setLanguage(_ lang: String) {
        // If we are requesting same language as we currently have, check the version date
        if let currentLanguage = languageVersionDict.first?.0 where currentLanguage == lang {
            let apiClient = APIClient()
            apiClient.requestVersionDateOfLanguage(lang) {
                [weak self] (versionDate, error) in
                
                print("Checking version date of language \(lang)")
                if let newDate = versionDate, oldDate = self?.languageVersion.versionDate
                where newDate.compare(oldDate) == .OrderedDescending {
                    self?.p_downloadLanguage(lang)
                }
            }
        } else {
            p_downloadLanguage(lang)
        }
    }
    
    // MARK: Private methods
    
    /**
        Download language tags
     
        - Parameter lang: The language to download
     */
    private func p_downloadLanguage(_ lang: String) {
        let apiClient = APIClient()
        apiClient.requestLanguage(lang) {
            [weak self] (responseObject, error) in
            
            guard let responseTags = responseObject?[lang] as? [String: String] else {
                print(responseObject)
                return
            }
            
            print("Downloaded JSON with tags")
            
            // Save language and versionDate
            self?.saveLanguageVersion(lang, versionDate: NSDate())
            
            // Save tags
            self?.dataController.saveTags(responseTags)
            
            // Test translation
            print(self?.dataController.translationForKey("bloombees.mobileapp.welcome.message_welcome"))
        }
    }
}

/**
    Append dictionary elements to another dictionary
 
    - Parameter lhs: The dictionary in which append elements
    - Parameter rhs: The dictionary containing elements to be appended
 */
func +=<U, T>(inout lhs: [U:T], rhs: [U:T]) {
    for (key, value) in rhs {
        lhs[key] = value
    }
}