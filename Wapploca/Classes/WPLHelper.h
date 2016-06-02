//
//  WPLHelper.h
//  Wapploca
//
//  Created by gabmarfer on 02/06/16.
//  Copyright © 2016 Bloombees. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WPLHelper : NSObject
/*!
 * Generate a security token for using Cloud Framework
 *
 * @param
 * @return
 */
+ (NSString *)getCFSecurityToken;
@end
