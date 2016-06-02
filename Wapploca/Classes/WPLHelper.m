//
//  WPLHelper.m
//  Wapploca
//
//  Created by gabmarfer on 02/06/16.
//  Copyright © 2016 Bloombees. All rights reserved.
//

#import "WPLHelper.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

/**
 * Generate SHA1 HASH of plaintext with "key" key
 *
 * @param plaintext a string to encript
 * @param key the key used to generate SHA1 HASH
 * @return SHA1 HASH string
 */
NSString *hmacwithKey(NSString *plaintext, NSString *key) {
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [plaintext cStringUsingEncoding:NSASCIIStringEncoding];
    
    uint8_t cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSString *hash = @"";
    for (int i=0; i< CC_SHA1_DIGEST_LENGTH; i++)
    {
        hash = [hash stringByAppendingString:[NSString stringWithFormat:@"%02x", cHMAC[i]]];
    }
    return hash;
}

@implementation WPLHelper

+ (NSString *)getCFSecurityToken {
    NSTimeInterval time = round([[NSDate date] timeIntervalSince1970]);
    NSString *timeString = [NSString stringWithFormat:@"%d", (int) time];
    
    NSString *ret = [[NSArray arrayWithObjects:@"bloombeesMobile", @"__UTC__", timeString, nil] componentsJoinedByString:@""];
    
    NSString *hmac = hmacwithKey(ret, @"$2a$07$DRRRZ5WWxWKBFvKNjdSE.ovRMCTRD1x8AYA8Hf7yRzcye0BByC13tm");
    
    return [[NSArray arrayWithObjects:ret, @"__", hmac, nil] componentsJoinedByString:@""];
}
@end
