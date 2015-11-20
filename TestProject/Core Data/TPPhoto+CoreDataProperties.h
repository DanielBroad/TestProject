//
//  TPPhoto+CoreDataProperties.h
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TPPhoto.h"

NS_ASSUME_NONNULL_BEGIN

@class TPAlbum;

@interface TPPhoto (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *photoID;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSString *thumbnailURL;
@property (nullable, nonatomic, retain) NSDate *timeStamp;
@property (nullable, nonatomic, retain) NSData *thumbnailImage;
@property (nullable, nonatomic, retain) NSData *photoImage;
@property (nullable, nonatomic, retain) TPAlbum *album;

@end

NS_ASSUME_NONNULL_END
