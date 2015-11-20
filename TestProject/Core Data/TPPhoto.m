//
//  TPPhoto.m
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import "TPPhoto.h"

NSString * const kDictionaryKeyPhotoID = @"id";
NSString * const kDictionaryKeyAlbumID = @"albumId";
NSString * const kDictionaryKeyTitle = @"title";
NSString * const kDictionaryKeyURL = @"url";
NSString * const kDictionaryKeyThumbnailURL = @"thumbnailUrl";

@implementation TPPhoto

// Insert code here to add functionality to your managed object subclass

-(void) populateFromDictionary: (NSDictionary*) dictionary {
    self.title = [dictionary objectForKey:kDictionaryKeyTitle];
    self.url = [dictionary objectForKey:kDictionaryKeyURL];
    self.thumbnailURL = [dictionary objectForKey:kDictionaryKeyThumbnailURL];
    self.timeStamp = [NSDate date];
}
@end
