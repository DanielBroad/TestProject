//
//  TPAlbum.h
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TPPhoto, TPUser;

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kDictionaryKeyAlbum_AlbumID;

@interface TPAlbum : NSManagedObject

-(void) populateFromDictionary: (NSDictionary*) dictionary;

@end

NS_ASSUME_NONNULL_END

#import "TPAlbum+CoreDataProperties.h"
