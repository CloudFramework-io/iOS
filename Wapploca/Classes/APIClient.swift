//
//  APIClient.swift
//  Pods
//
//  Created by gabmarfer on 02/06/16.
//
//

import Foundation
import Alamofire

public class APIClient {
    private static let baseURL = "https://wapploca.org/h/api/wapploca/dics/bloombees/mobileapp"
    
    private enum WapplocaInputParam: String {
        case lastUpdate = "lastupdate"
        case lang
        case export
    }
    
    private enum WapplocaResponseParam: String {
        case lastUpdate = "last_update"
    }
    
    private var headers: Dictionary<String, String> {
        let token = WPLHelper.getCFSecurityToken()
        return ["X-CLOUDFRAMEWORK-SECURITY": token!]
    }
    
    public init() {
        
    }
    
    public func requestVersionDateOfLanguage(_ lang: String, completionHandler: (versionDate: NSDate?, error: NSError?) -> ()) {
        assert(lang.characters.count == 2, "Language \(lang) should be a valid ISO Code of 2 characters length")
        
        let parameters = [WapplocaInputParam.lang.rawValue: lang,
                          WapplocaInputParam.lastUpdate.rawValue: ""]
        
        let request = Alamofire.request(.GET, APIClient.baseURL, parameters: parameters, headers: self.headers)
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
    
    public func requestLanguage(_ lang: String, completionHandler: (responseObject: AnyObject?, error: NSError?) -> ()) {
        assert(lang.characters.count == 2, "Language \(lang) should be a valid ISO Code of 2 characters length")
        
        let parameters = [WapplocaInputParam.lang.rawValue: lang,
                          WapplocaInputParam.export.rawValue: "mobile"]
        
        let request = Alamofire.request(.GET, APIClient.baseURL, parameters: parameters, headers: self.headers)
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
}
