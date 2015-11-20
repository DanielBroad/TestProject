//
//  TPDataFetcher.h
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPDataFetcher;

@protocol TPDataFetcherDelegate <NSObject>

-(void) fetcherSingleton: (TPDataFetcher*) singleton didReportError: (NSError*) error;

@end

@interface TPDataFetcher : NSObject

-(instancetype) init NS_UNAVAILABLE;
+(instancetype) sharedInstance;

@property (weak,nonatomic) id<TPDataFetcherDelegate> delegate;

-(void) validateUserID: (NSInteger) userID completionHandler: (void(^)(BOOL validated, NSError *error)) completionHandler;
-(BOOL) userIsValidated;

-(void) populateDataCompletionHandler: (void(^)(NSError *error)) completionHandler;

@end
