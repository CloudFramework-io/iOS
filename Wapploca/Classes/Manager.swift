//
//  Manager.swift
//  Pods
//
//  Created by gabmarfer on 03/06/16.
//
//

import Foundation

public class Manager {
    var deviceLanguage: String {
        let language = NSLocale.preferredLanguages().first!
        let index = language.startIndex.advancedBy(2)
        return language.substringToIndex(index)
    }
    
    private var dataController: DataController
    
    private var tagsDict = [String: String]()
    
    public var currentLanguage: String?
    
    public init() {
        self.dataController = DataController()
        self.currentLanguage = deviceLanguage
    }
    
    deinit {
        print("SELF has been deinit")
    }
    
    public func setLanguage(_ lang: String) {
//        guard lang != currentLanguage else {
//            print("Trying to set \(lang) but language is already set.")
//            return
//        }
        
        let apiClient = APIClient()
        apiClient.requestLanguage(lang) {
            [weak self] (responseObject, error) in
            
            guard let responseTags = responseObject?[lang] as? [String: String] else {
                print(responseObject)
                return
            }
            
            // TODO: Save JSON and set current language
            print("Downloaded JSON with tags")
            self?.currentLanguage = lang
            self?.tagsDict.removeAll()
            self?.tagsDict += responseTags
            self?.dataController.saveTags((self?.tagsDict)!)
            print(self?.dataController.translationForKey("bloombees.mobileapp.welcome.message_welcome"))
        }
    }
}

func +=<U, T>(inout lhs: [U:T], rhs: [U:T]) {
    for (key, value) in rhs {
        lhs[key] = value
    }
}