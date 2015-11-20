//
//  AppDelegate.m
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import "TPAppDelegate.h"

#import "TPDetailViewController.h"

#import "TPDataFetcher.h"

@interface TPAppDelegate () <UISplitViewControllerDelegate, TPCoreDataDelegate, TPDataFetcherDelegate>

@end

@implementation TPAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [TPCoreData sharedInstance].delegate = self;
    [TPDataFetcher sharedInstance].delegate = self;
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[TPCoreData sharedInstance] contextSave];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (![TPDataFetcher sharedInstance].userIsValidated) {
        NSNumber *currentUserID = [TPCoreData sharedInstance].currentUser.userID;
        if (!currentUserID) {
            currentUserID = @1;
        }
        [[TPDataFetcher sharedInstance] validateUserID:[currentUserID integerValue] completionHandler:^(BOOL validated, NSError *error) {
            if (error) {
                [self reportError: error isTerminal: YES];
            } else {
                [[TPDataFetcher sharedInstance] populateDataCompletionHandler:^(NSError *error) {
                    if (error) {
                        [self reportError: error isTerminal: YES];
                    };
                }];
            }
        }];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[TPDetailViewController class]] && ([(TPDetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Delegates

-(void) reportError: (NSError*) error isTerminal: (BOOL) terminal {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             if (terminal) {
                                                                 abort();
                                                             }
                                                         }];
    
    [alert addAction:cancelAction];
    //
    //    alert.popoverPresentationController.sourceView = vc.view;
    //    alert.popoverPresentationController.sourceRect = CGRectMake(alert.popoverPresentationController.sourceView.frame.size.width / 2.0, alert.popoverPresentationController.sourceView.frame.size.height / 2.0, 1.0, 1.0);
    
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

-(void) fetcherSingleton: (TPDataFetcher*) singleton didReportError: (NSError*) error {
    [self reportError:error isTerminal:NO];
}

-(void) coreDataSingleton: (TPCoreData*) singleton didReportError: (NSError*) error {
    [self reportError:error isTerminal:YES];
}

@end
