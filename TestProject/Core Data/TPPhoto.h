//
//  TPPhoto.h
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kDictionaryKeyPhoto_PhotoID;

@interface TPPhoto : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

-(void) populateFromDictionary: (NSDictionary*) dictionary;

@end

NS_ASSUME_NONNULL_END

#import "TPPhoto+CoreDataProperties.h"
