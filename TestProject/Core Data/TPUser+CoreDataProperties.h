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

@interface TPUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *userID;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSSet<TPPhoto *> *photos;

@end

@interface TPUser (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(TPPhoto *)value;
- (void)removePhotosObject:(TPPhoto *)value;
- (void)addPhotos:(NSSet<TPPhoto *> *)values;
- (void)removePhotos:(NSSet<TPPhoto *> *)values;

@end

NS_ASSUME_NONNULL_END
