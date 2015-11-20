//
//  TPPhotoTableViewCell.h
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPPhoto;

@interface TPPhotoTableViewCell : UITableViewCell

@property (weak) IBOutlet UIImageView *photoThumbnail;
@property (weak) IBOutlet UILabel *titleLabel;
@property (weak) IBOutlet UILabel *dateTimeLabel;

@property (strong,nonatomic) TPPhoto *photo;

@end
