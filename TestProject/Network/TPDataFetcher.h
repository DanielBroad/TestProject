//
//  TPDataFetcher.h
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPDataFetcher,TPPhoto;

@interface TPDataFetcher : NSObject

-(instancetype) init NS_UNAVAILABLE;
+(instancetype) sharedInstance;

-(void) validateUserID: (NSInteger) userID completionHandler: (void(^)(BOOL validated, NSError *error)) completionHandler;
-(BOOL) userIsValidated;

-(void) populateDataCompletionHandler: (void(^)(NSError *error)) completionHandler;

-(void) loadImageForPhoto: (TPPhoto*) photo thumbnail: (BOOL) thumbnail;

@end
