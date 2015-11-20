//
//  TPUser+CoreDataProperties.h
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TPUser.h"

NS_ASSUME_NONNULL_BEGIN

@class TPAlbum;

@interface TPUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *userID;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSSet<TPAlbum *> *albums;

@end

@interface TPUser (CoreDataGeneratedAccessors)

- (void)addAlbumsObject:(TPAlbum *)value;
- (void)removeAlbumsObject:(TPAlbum *)value;
- (void)addAlbums:(NSSet<TPAlbum *> *)values;
- (void)removeAlbums:(NSSet<TPAlbum *> *)values;

@end

NS_ASSUME_NONNULL_END
