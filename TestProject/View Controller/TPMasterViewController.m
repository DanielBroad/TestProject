//
//  MasterViewController.m
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import "TPMasterViewController.h"
#import "TPDetailViewController.h"

#import "TPCoreData.h"

#import "TPPhotoTableViewCell.h"

@interface TPMasterViewController () <NSFetchedResultsControllerDelegate>
@end

@implementation TPMasterViewController {
    NSFetchedResultsController *_fetchedResultsController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.detailViewController = (TPDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    self.tableView.rowHeight = 110.0f;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:[[TPCoreData sharedInstance] fetchRequest_photosForTitle:nil]
                                 managedObjectContext:[TPCoreData sharedInstance].managedObjectContext
                                 sectionNameKeyPath:nil
                                 cacheName:nil];
    _fetchedResultsController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        abort();
    }
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TPPhoto *photo = [_fetchedResultsController objectAtIndexPath:indexPath];
        TPDetailViewController *controller = (TPDetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:photo];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; // no sections at the moment
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fetchedResultsController.fetchedObjects.count;
}

- (void) configureCell: (TPPhotoTableViewCell*) cell atIndexPath: (NSIndexPath*) indexPath withNillablePhoto: (TPPhoto*) photo {
    if (!photo) {
        photo = [_fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    cell.photo = photo;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TPPhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath withNillablePhoto:nil];
    return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath withNillablePhoto:anObject];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView  deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView  insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSAssert(false,@"There are sections now? You didn't write code for that!");
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
