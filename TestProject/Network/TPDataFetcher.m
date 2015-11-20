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
    BOOL _userIsValidated;
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

-(void) populateDataCompletionHandler: (void(^)(NSError *error)) completionHandler {
    [self populateAlbumsCompletionHandler:^(NSError *error) {
        if (error) {
            completionHandler(error);
            return;
        }
        
        
    }];
}

-(void) validateUserID: (NSInteger) userID completionHandler: (void(^)(BOOL validated, NSError *error)) completionHandler {
    NSString *validatePath = [NSString stringWithFormat:kUserURL,(long)userID];
    NSURL *validateURL = [NSURL URLWithString:validatePath];
    
    NSLog(@"%@",validateURL);
    
    NSURLSessionDataTask *task = [_foregroundSession dataTaskWithURL:validateURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (completionHandler) {
                    completionHandler(NO,error);
                }
            });
            return;
        }
        
        NSError *parseError = nil;
        NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (parseError) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (completionHandler) {
                    completionHandler(NO,parseError);
                }
            });
            return;
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self stopNetworkActivity];
            
            NSNumber *userID = [userDict objectForKey:kDictionaryKeyPhoto_PhotoID];
            
            TPUser *user = [[TPCoreData sharedInstance] currentUser];
            if (!user || [user.userID compare:userID]!=NSOrderedSame) {
                if (user) {
                    [[TPCoreData sharedInstance].managedObjectContext deleteObject:user];
                }
                user = [[TPCoreData sharedInstance] addUserWithID: userID];
                [user populateFromDictionary: userDict];
            }
            
            if ([[TPCoreData sharedInstance] currentUser]) {
                _userIsValidated = YES;
            }
            if (completionHandler) {
                completionHandler(_userIsValidated,nil);
            }
            
            
        });
        
    }];
    [self startNetworkActivity];
    [task resume];
    [_activeDownloadTasks addObject:task];
}

-(BOOL) userIsValidated {
    return _userIsValidated;
}

-(void) populateAlbumsCompletionHandler: (void(^)(NSError *error)) completionHandler {
    TPUser *user = [TPCoreData sharedInstance].currentUser;
    
    NSString *albumsPath = [NSString stringWithFormat:kAlbumsURL,(long)[user.userID integerValue]];
    NSURL *albumsURL = [NSURL URLWithString:albumsPath];
    
    NSMutableSet *existingAlbums = [NSMutableSet set];
    for (TPAlbum *album in [TPCoreData sharedInstance].allAlbums) {
        [existingAlbums addObject:album.albumID];
    }
    
    NSLog(@"%@",albumsURL);
    
    NSURLSessionDataTask *task = [_foregroundSession dataTaskWithURL:albumsURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self stopNetworkActivity];
                [self.delegate fetcherSingleton:self didReportError:error];
            });
            return;
        }
        
        NSError *parseError = nil;
        NSArray *photos = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (parseError) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self stopNetworkActivity];
                [self.delegate fetcherSingleton:self didReportError:error];
            });
            return;
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self stopNetworkActivity];
            
            TPUser *currentUser = [TPCoreData sharedInstance].currentUser; //getting this again as we've crossed a thread boundary and back.
            
            for (NSDictionary *photoDict in photos) {
                NSNumber *albumID = [photoDict objectForKey:kDictionaryKeyAlbum_AlbumID];
                
                if (![existingAlbums containsObject:albumID]) {
                    // guess we should add it then
                    TPAlbum *newAlbum = [[TPCoreData sharedInstance] addAlbumWithID:albumID];
                    newAlbum.user = currentUser;
                    [newAlbum populateFromDictionary: photoDict];
                    [existingAlbums addObject:albumID];
                }
            }

        });
    }];
    [self startNetworkActivity];
    [task resume];
    [_activeDownloadTasks addObject:task];
}

-(void) populatePhotos {
    NSMutableSet *existingRecords = [NSMutableSet set];
    for (TPPhoto *photo in [TPCoreData sharedInstance].allPhotos) {
        [existingRecords addObject:photo.photoID];
    }
    
    NSURL *photosURL = [NSURL URLWithString:kPhotosURL];
    NSLog(@"%@",photosURL);
    NSURLSessionDataTask *task = [_foregroundSession dataTaskWithURL:photosURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self stopNetworkActivity];
                [self.delegate fetcherSingleton:self didReportError:error];
            });
            return;
        }
        
        NSError *parseError = nil;
        NSArray *photos = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (parseError) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self stopNetworkActivity];
                [self.delegate fetcherSingleton:self didReportError:error];
            });
            return;
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self stopNetworkActivity];
            
            for (NSDictionary *photoDict in photos) {
                NSNumber *photoID = [photoDict objectForKey:kDictionaryKeyPhoto_PhotoID];
                
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
