//
//  DetailViewController.h
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

