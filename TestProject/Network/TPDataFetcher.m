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
    
    NSInteger networkActivity;
    BOOL _userIsValidated;
}

#pragma mark - Lifecycle

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
            
        }];
    }
    return self;
}

// **********************************************************************************************
//								Handle Network Indicator
// **********************************************************************************************

#pragma mark - Network Indicator

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

#pragma mark - Get Data

-(void) populateDataCompletionHandler: (void(^)(NSError *error)) completionHandler {
    [self populateAlbumsCompletionHandler:^(NSError *error) {
        if (error) {
            if (completionHandler) {
                completionHandler(error);
            }
            return;
        }
        
        NSArray *albumsToUpdate = [TPCoreData sharedInstance].allAlbums;
        
        [self populateAlbumPhotos: albumsToUpdate completionHandler:completionHandler];
        
    }];
}

#pragma mark - user

-(void) validateUserID: (NSInteger) userID completionHandler: (void(^)(BOOL validated, NSError *error)) completionHandler {
    NSString *validatePath = [NSString stringWithFormat:kUserURL,(long)userID];
    NSURL *validateURL = [NSURL URLWithString:validatePath];
    
    NSLog(@"%@",validateURL);
    
    NSURLSessionDataTask *task = [_foregroundSession dataTaskWithURL:validateURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self stopNetworkActivity];
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
                [self stopNetworkActivity];
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
}

-(BOOL) userIsValidated {
    return _userIsValidated;
}

#pragma mark - Albums

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
                if (completionHandler) {
                    completionHandler(error);
                }
            });
            return;
        }
        
        NSError *parseError = nil;
        NSArray *photos = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (parseError) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self stopNetworkActivity];
                if (completionHandler) {
                    completionHandler(parseError);
                }
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
            
            [[TPCoreData sharedInstance] contextSave];
            
            if (completionHandler) {
                completionHandler(nil);
            };
        });
    }];
    [self startNetworkActivity];
    [task resume];
}

#pragma mark - Photos

-(void) populateAlbumPhotos: (NSArray*) albums completionHandler: (void(^)(NSError *error)) completionHandler {
    if (!albums.count) {
        completionHandler(nil);
        return;
    }
    
    TPAlbum *todo = [albums firstObject];
    NSMutableArray *albumsRemaining = [albums mutableCopy];
    [albumsRemaining removeObject:todo];
    
    [self populatePhotosForAlbum: todo completionHandler:^(NSError *error) {
        if (error) {
            if (completionHandler) {
                completionHandler(error);
            }
            return;
        }
        
        [self populateAlbumPhotos:albumsRemaining completionHandler:completionHandler];
        
    }];
}

-(void) populatePhotosForAlbum: (TPAlbum*) album completionHandler: (void(^)(NSError *error)) completionHandler {
    
    NSManagedObjectID *albumObjectID = album.objectID;
    
    NSMutableSet *existingRecords = [NSMutableSet set];
    for (TPPhoto *photo in [TPCoreData sharedInstance].allPhotos) {
        [existingRecords addObject:photo.photoID];
    }
    
    NSString *photosPath = [NSString stringWithFormat:kPhotosURL,(long)[album.albumID integerValue]];
    NSURL *photosURL = [NSURL URLWithString:photosPath];
    
    NSLog(@"%@",photosURL);
    NSURLSessionDataTask *task = [_foregroundSession dataTaskWithURL:photosURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self stopNetworkActivity];
                if (completionHandler) {
                    completionHandler(error);
                }
            });
            return;
        }
        
        NSError *parseError = nil;
        NSArray *photos = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (parseError) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self stopNetworkActivity];
                if (completionHandler) {
                    completionHandler(parseError);
                }
            });
            return;
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self stopNetworkActivity];
            
            TPAlbum *album = [[TPCoreData sharedInstance].managedObjectContext existingObjectWithID:albumObjectID error:nil];
            if (!album) {
                // oops
                return;
            }
            for (NSDictionary *photoDict in photos) {
                NSNumber *photoID = [photoDict objectForKey:kDictionaryKeyPhoto_PhotoID];
                
                if (![existingRecords containsObject:photoID]) {
                    // guess we should add it then
                    TPPhoto *newPhoto = [[TPCoreData sharedInstance] addPhotoWithID:photoID];
                    [newPhoto populateFromDictionary: photoDict];
                    newPhoto.album = album;
                    [existingRecords addObject:photoID];
                }
            }
            
            [[TPCoreData sharedInstance] contextSave];
            
            if (completionHandler) {
                completionHandler(nil);
            };
        });
    }];
    [self startNetworkActivity];
    [task resume];
}

// **********************************************************************************************
//								Load Images
// **********************************************************************************************

#pragma mark - load images

-(void) loadImageForPhoto: (TPPhoto*) photo thumbnail: (BOOL) thumbnail {
    NSManagedObjectID *photoObjectID = photo.objectID;
    
    NSURL *imageURL = [NSURL URLWithString: thumbnail?photo.thumbnailURL:photo.url];
    
    NSLog(@"Loading URL %@",imageURL);
    
    NSURLSessionDataTask *task = [_foregroundSession dataTaskWithURL:imageURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self stopNetworkActivity];
            });
            return;
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self stopNetworkActivity];
            TPPhoto *mtPhoto = [[TPCoreData sharedInstance].managedObjectContext objectWithID:photoObjectID];
            if (mtPhoto) {
                if (thumbnail) {
                    photo.thumbnailImage = data;
                } else {
                    photo.photoImage = data;
                }
            }

        });

    }];
    [self startNetworkActivity];
    [task resume];
}
@end
