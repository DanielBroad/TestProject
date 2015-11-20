//
//  TPDataFetcher.m
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPDataFetcher.h"
#import "TPCoreData.h"

static NSString * const kPhotosURL = @"http://jsonplaceholder.typicode.com/photos?albumId=%ld";
static NSString * const kUserURL = @"http://jsonplaceholder.typicode.com/users/%ld";
static NSString * const kAlbumsURL = @"http://jsonplaceholder.typicode.com/albums?userId=%ld";


static TPDataFetcher *singleton;

@implementation TPDataFetcher {
    NSURLSession *_foregroundSession;
    NSMutableArray *_activeDownloadTasks;
    
    NSInteger networkActivity;
}

+(instancetype) sharedInstance {
    if (!singleton) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            singleton = [[self alloc] init];
        });
    }
    return singleton;
}

-(id) init {
    self = [super init];
    if (self) {
        _foregroundSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        [_foregroundSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            [_activeDownloadTasks addObjectsFromArray:downloadTasks];
        }];
    }
    return self;
}

// **********************************************************************************************
//								Handle Network Indicator
// **********************************************************************************************

-(void) startNetworkActivity
{
    networkActivity++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void) stopNetworkActivity
{
    networkActivity--;
    NSAssert(networkActivity>=0,@"Unbalanced network activity!");
    if (networkActivity == 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

// **********************************************************************************************
//								Get Data from Network (No Background Downloads)
// **********************************************************************************************

-(void) validateUserID: (NSInteger) userID {
    NSString *validatePath = [NSString stringWithFormat:kUserURL,(long)userID];
    NSURL *validateURL = [NSURL URLWithString:validatePath];
    
    NSURLSessionDataTask *task = [_foregroundSession dataTaskWithURL:validateURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *parseError = nil;
        NSArray *users = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (parseError) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate fetcherSingleton:self didReportError:error];
            });
            return;
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self stopNetworkActivity];

            NSDictionary *userDict = [users firstObject];
            
            if (error) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.delegate fetcherSingleton:self didReportError:error];
                });
                return;
            }
            
            NSNumber *userID = [userDict objectForKey:kDictionaryKeyPhotoID];
            
            TPUser *user = [[TPCoreData sharedInstance] currentUser];
            if ([user.userID compare:userID]!=NSOrderedSame) {
                
            }
        });
        
    }];
    [self startNetworkActivity];
    [task resume];
    [_activeDownloadTasks addObject:task];
}

-(void) populateAlbums {
    
}

-(void) populateData {
    NSMutableSet *existingRecords = [NSMutableSet set];
    for (TPPhoto *photo in [TPCoreData sharedInstance].allPhotos) {
        [existingRecords addObject:photo.photoID];
    }
    
    NSURL *url = [NSURL URLWithString:kPhotosURL];
    
    NSURLSessionDataTask *task = [_foregroundSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate fetcherSingleton:self didReportError:error];
            });
            return;
        }
        
        NSError *parseError = nil;
        NSArray *photos = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (parseError) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate fetcherSingleton:self didReportError:error];
            });
            return;
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self stopNetworkActivity];
            
            for (NSDictionary *photoDict in photos) {
                NSNumber *photoID = [photoDict objectForKey:kDictionaryKeyPhotoID];
                
                if (![existingRecords containsObject:photoID]) {
                    // guess we should add it then
                    TPPhoto *newPhoto = [[TPCoreData sharedInstance] addPhotoWithID:photoID];
                    [newPhoto populateFromDictionary: photoDict];
                    [existingRecords addObject:photoID];
                }
            }
            
            [[TPCoreData sharedInstance] contextSave];
        });
    }];
    [self startNetworkActivity];
    [task resume];
    [_activeDownloadTasks addObject:task];
}

@end
