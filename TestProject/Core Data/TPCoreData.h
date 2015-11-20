//
//  DRCoreData.h
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "TPPhoto.h"
#import "TPAlbum.h"
#import "TPUser.h"

@class TPCoreData;

@protocol TPCoreDataDelegate <NSObject>

-(void) coreDataSingleton: (TPCoreData*) singleton didReportError: (NSError*) error;

@end

@interface TPCoreData : NSObject

-(instancetype) init NS_UNAVAILABLE;
+(instancetype) sharedInstance;

@property (weak,nonatomic) id<TPCoreDataDelegate> delegate;

- (NSManagedObjectContext *) managedObjectContext;
-(void) contextSave;

-(TPUser*) currentUser;
-(TPUser*) addUserWithID: (NSNumber*) userID;

-(NSArray*) allAlbums;
-(TPAlbum*) addAlbumWithID: (NSNumber*) albumID;

-(NSFetchRequest*) fetchRequest_photosForTitle: (NSString*) title;
-(NSArray*) allPhotos;
-(TPPhoto*) addPhotoWithID: (NSNumber*) photoID;


@end
