//
//  TPAlbum.m
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import "TPAlbum.h"
#import "TPPhoto.h"
#import "TPUser.h"

NSString * const kDictionaryKeyAlbum_AlbumID = @"id";
NSString * const kDictionaryKeyAlbum_Title = @"title";

@implementation TPAlbum

// Insert code here to add functionality to your managed object subclass

-(void) populateFromDictionary: (NSDictionary*) dictionary {
    self.title = [dictionary objectForKey:kDictionaryKeyAlbum_Title];
    self.albumID = [dictionary objectForKey:kDictionaryKeyAlbum_AlbumID];
}

@end
