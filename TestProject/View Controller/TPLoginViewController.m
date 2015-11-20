//
//  TPLoginViewController.m
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import "TPLoginViewController.h"

#import "TPDataFetcher.h"

@interface TPLoginViewController ()

@end

@implementation TPLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.useridTextField becomeFirstResponder];
}

-(void) cancel: (id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)login:(id)sender {
    [self.useridTextField resignFirstResponder];
    NSInteger userID = [self.useridTextField.text integerValue];
    if (userID) {
        [[TPDataFetcher sharedInstance] validateUserID:userID completionHandler:^(BOOL validated, NSError *error) {
            if (!validated) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                               message:NSLocalizedString(@"Sorry, could not validate your user id", nil)
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction *action) {
                                                                         [self.useridTextField becomeFirstResponder];
                                                                     }];
                
                [alert addAction:cancelAction];
                
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                [[TPDataFetcher sharedInstance] populateDataCompletionHandler:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            
        }];
    }
}

@end
