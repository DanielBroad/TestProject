//
//  TPUser.h
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TPPhoto;

NS_ASSUME_NONNULL_BEGIN

@interface TPUser : NSManagedObject

-(void) populateFromDictionary: (NSDictionary*) dictionary;

@end

NS_ASSUME_NONNULL_END

#import "TPUser+CoreDataProperties.h"
