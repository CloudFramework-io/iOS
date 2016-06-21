//
//  APIClient.swift
//  Pods
//
//  Created by gabmarfer on 02/06/16.
//
//

import Foundation
import Alamofire

class APIClient {
    private static let baseURL = "https://wapploca.org/h/api/wapploca/dics/bloombees/mobileapp"
    private static let languagesBaseURL = "https://bloombees.com/api/v2/language"
    
    private enum WapplocaInputParam: String {
        case lastUpdate = "lastupdate"
        case lang
        case export
    }
    
    private enum WapplocaResponseParam: String {
        case lastUpdate = "last_update"
    }
    
    private var cloudHeaders: Dictionary<String, String> {
        let token = WPLHelper.getCFSecurityToken()
        return ["X-CLOUDFRAMEWORK-SECURITY": token!]
    }
    
    private var languageHeaders: Dictionary<String, String> {
        return [
            "X-REST-USERNAME": "20141212121212",
            "X-REST-PASSWORD": "6dde73cf3f668cbbf6f302e0def2413f193d94d3"
        ]
    }
    
    public init() {
        
    }
    
    func requestVersionDateOfLanguage(_ lang: String, completionHandler: (versionDate: NSDate?, error: NSError?) -> ()) {
        assert(lang.characters.count == 2, "Language \(lang) should be a valid ISO Code of 2 characters length")
        
        let parameters = [WapplocaInputParam.lang.rawValue: lang,
                          WapplocaInputParam.lastUpdate.rawValue: ""]
        
        let request = Alamofire.request(.GET, APIClient.baseURL, parameters: parameters, headers: self.cloudHeaders)
        .validate()
        .responseJSON { response in
            switch response.result {
            case .Success:
                if let responseDict = response.result.value as? [String: AnyObject],
                    langDate = responseDict[WapplocaResponseParam.lastUpdate.rawValue] as? String {
                        let parser = Parser()
                        let parsedDate = parser.parseDateFromString(langDate)
                        completionHandler(versionDate: parsedDate, error: nil)
                } else {
                    let errorNoDate = NSError(domain: String(APIClient),
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Could not parse version date"])
                    completionHandler(versionDate: nil, error: errorNoDate)
                }
                
            case .Failure(let error):
                completionHandler(versionDate: nil, error: error)
            }
        }
        debugPrint(request)
    }
    
    func requestLanguage(_ lang: String, completionHandler: (responseObject: AnyObject?, error: NSError?) -> ()) {
        assert(lang.characters.count == 2, "Language \(lang) should be a valid ISO Code of 2 characters length")
        
        let parameters = [WapplocaInputParam.lang.rawValue: lang,
                          WapplocaInputParam.export.rawValue: "mobile"]
        
        let request = Alamofire.request(.GET, APIClient.baseURL, parameters: parameters, headers: self.cloudHeaders)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    completionHandler(responseObject: response.result.value, error: response.result.error)
                case .Failure(let error):
                    completionHandler(responseObject: [:], error: error)
                }
        }
        debugPrint(request)
    }
    
    func requestLanguages(completionHandler: (languages: [Language], error: NSError?) -> ()) {
        let request = Alamofire.request(.GET, APIClient.languagesBaseURL, headers: self.languageHeaders)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let JSON):
                    if let responseDict = JSON as? [String: AnyObject],
                    let responseData = responseDict["data"] as? [String: AnyObject],
                    let responseLanguages = responseData["language"] as? [AnyObject] {
                        var parsedLanguages = [Language]()
                        for obj in responseLanguages {
                            let language = Language(attributes: obj as! [String : String])
                            parsedLanguages.append(language)
                        }
                        completionHandler(languages: parsedLanguages, error: nil)
                    } else {
                        let errorNoLanguages = NSError(domain: String(APIClient),
                            code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "Could not parse languages"])
                        completionHandler(languages: [], error: errorNoLanguages)
                    }
                case .Failure(let error):
                    completionHandler(languages: [], error: error)
                }
        }
        debugPrint(request)
    }
}
