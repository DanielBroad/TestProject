//
//  TPPhotoTableViewCell.m
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import "TPPhotoTableViewCell.h"
#import "TPPhoto.h"

#import "TPDataFetcher.h"

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
    }
    
    self.titleLabel.text = photo.title;
    self.dateTimeLabel.text = [photoCellDateFormatter stringFromDate:photo.timeStamp];
    if (photo.thumbnailImage) {
        NSInteger expectedTagIfCellHasNotBeenReused = self.photoThumbnail.tag;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithData:photo.thumbnailImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (expectedTagIfCellHasNotBeenReused == self.photoThumbnail.tag) {
                    [UIView transitionWithView:self.photoThumbnail
                                      duration:0.1f
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{
                                        self.photoThumbnail.image = image;
                                    } completion:nil];
                    
                } else {
                    NSLog(@"Aborted image, the cell has been reused since");
                }
            });
        });
    } else {
        [[TPDataFetcher sharedInstance] loadImageForPhoto:photo thumbnail:YES];
    }
}

-(void) prepareForReuse {
    [super prepareForReuse];
    self.photoThumbnail.image = nil;
    self.titleLabel.text = nil;
    self.dateTimeLabel.text = nil;
    self.photoThumbnail.tag++;
}
@end
