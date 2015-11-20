//
//  TPUser.m
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import "TPUser.h"
#import "TPPhoto.h"

NSString * const kDictionaryKeyUserID = @"id";
NSString * const kDictionaryKeyName = @"name";
NSString * const kDictionaryKeyEmail = @"email";

@implementation TPUser

// Insert code here to add functionality to your managed object subclass

-(void) populateFromDictionary: (NSDictionary*) dictionary {
    self.name = [dictionary objectForKey:kDictionaryKeyName];
    self.email = [dictionary objectForKey:kDictionaryKeyEmail];
}
@end
