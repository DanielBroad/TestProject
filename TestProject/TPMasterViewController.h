//
//  MasterViewController.h
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPDetailViewController;

@interface TPMasterViewController : UITableViewController

@property (strong, nonatomic) TPDetailViewController *detailViewController;


@end

