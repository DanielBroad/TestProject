//
//  TPPhotoTableViewCell.m
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import "TPPhotoTableViewCell.h"
#import "TPPhoto.h"

static NSDateFormatter *photoCellDateFormatter;

@implementation TPPhotoTableViewCell

+(void) initialize {
    if (!photoCellDateFormatter) {
        photoCellDateFormatter = [[NSDateFormatter alloc] init];
//        photoCellDateFormatter.timeStyle = NSDateFormatterFullStyle;
//        photoCellDateFormatter.dateStyle = NSDateFormatterFullStyle;
        photoCellDateFormatter.dateFormat = @"dd-MM-yyyy HH:mm:ss";
    }
    
}

-(void) setPhoto:(TPPhoto *)photo {
    if (_photo != photo) {
        _photo = photo;
        self.titleLabel.text = photo.title;
        self.dateTimeLabel.text = [photoCellDateFormatter stringFromDate:photo.timeStamp];
    }
}
@end
