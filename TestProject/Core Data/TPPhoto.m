//
//  TPPhoto.m
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import "TPPhoto.h"

NSString * const kPhotoKeyPath_Image = @"photoImage";
NSString * const kDictionaryKeyPhoto_PhotoID = @"id";
NSString * const kDictionaryKeyPhoto_AlbumID = @"albumId";
NSString * const kDictionaryKeyPhoto_Title = @"title";
NSString * const kDictionaryKeyPhoto_URL = @"url";
NSString * const kDictionaryKeyPhoto_ThumbnailURL = @"thumbnailUrl";

@implementation TPPhoto

// Insert code here to add functionality to your managed object subclass

-(void) populateFromDictionary: (NSDictionary*) dictionary {
    self.title = [dictionary objectForKey:kDictionaryKeyPhoto_Title];
    self.url = [dictionary objectForKey:kDictionaryKeyPhoto_URL];
    self.thumbnailURL = [dictionary objectForKey:kDictionaryKeyPhoto_ThumbnailURL];
    self.timeStamp = [NSDate date];
}
@end
