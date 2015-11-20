//
//  DetailViewController.m
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import "TPDetailViewController.h"
#import "TPPhoto.h"
#import "TPAlbum.h"

#import "TPDataFetcher.h"

@interface TPDetailViewController ()

@end

@implementation TPDetailViewController

#pragma mark - Managing the detail item

- (void) dealloc {
    self.detailItem = nil;
}

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        if (_detailItem) {
            [_detailItem removeObserver:self forKeyPath:kPhotoKeyPath_Image];
        }
        _detailItem = newDetailItem;
            
        // Update the view.
        if (self.isViewLoaded) {
            [self configureView];
        }
        
        
        if (_detailItem) {
            [_detailItem addObserver:self forKeyPath:kPhotoKeyPath_Image options:0 context:nil];
        }
        
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.title = self.detailItem.url;
        self.titleLabel.text = self.detailItem.title;
        self.albumLabel.text = self.detailItem.album.title;
        
        if (!self.photoImage.image) {
            if (self.detailItem.photoImage) {
                [UIView transitionWithView:self.photoImage
                                  duration:0.3f
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    self.photoImage.image = [UIImage imageWithData:self.detailItem.photoImage];
                                } completion:nil];
                
            } else {
                [[TPDataFetcher sharedInstance] loadImageForPhoto:self.detailItem thumbnail:NO];
            }
        }

    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    [self configureView];
}
@end
