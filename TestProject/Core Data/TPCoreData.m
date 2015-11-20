//
//  DRCoreData.m
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import "TPCoreData.h"

static TPCoreData *singleton;

static NSString * const kDataModelName = @"TestProject";
static NSString * const kDatabaseFilename = @"database.sqlite";

static NSString * const kPhotoEntityName = @"TPPhoto";
static NSString * const kUserEntityName = @"TPUser";
static NSString * const kAlbumEntityName = @"TPAlbum";

@implementation TPCoreData {
    NSManagedObjectContext			*_managedObjectContext;
    NSManagedObjectModel			*_managedObjectModel;
    NSPersistentStoreCoordinator	*_persistentStoreCoordinator;
}

+(instancetype) sharedInstance {
    if (!singleton) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            singleton = [[self alloc] init];
        });
    }
    return singleton;
}

-(id) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
// **********************************************************************************************
//								Utils
// **********************************************************************************************

-(NSString *)applicationCachesDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths firstObject];
}

// **********************************************************************************************
//								Core Data
// **********************************************************************************************

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store
 coordinator for the application.
 */

- (NSManagedObjectContext *) managedObjectContext {
    NSAssert([NSThread isMainThread],@"Bad Programmer! This project does not support multi-threaded core data.");
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectID*) managedObjectIDForURIRepresentation: (NSURL*) url {
    return [self.persistentStoreCoordinator managedObjectIDForURIRepresentation:url];
}
/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in
 application bundle.
 */

- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:kDataModelName ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    
    return _managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationCachesDirectory]
                                               stringByAppendingPathComponent: kDatabaseFilename]];
    
    NSError *error = nil;
    
    NSMutableDictionary *pragmaOptions = [NSMutableDictionary dictionary];
    [pragmaOptions setObject:@"DELETE" forKey:@"journal_mode"]; // easier to have 1 file for debugging?
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             pragmaOptions,NSSQLitePragmasOption,
                             nil];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:  NSSQLiteStoreType
                                                   configuration:nil URL:storeUrl options:options error:&error]) {
        [self.delegate coreDataSingleton:self didReportError:error];
    }
    
    return _persistentStoreCoordinator;
}

-(void) contextSave
{
    @try {
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            if (error) {
                [self.delegate coreDataSingleton:self didReportError:error];
            }
        }
    }
    @catch (NSException * e) {
        // oops
    }
    
}

-(NSFetchRequest*) fetchRequestForEntity: (NSString*) entityName
                           withPredicate: (NSPredicate*) predicate
                         sortDescriptors: (NSArray*) sortDescriptors
                           faultsAllowed: (BOOL) allowFaults {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:allowFaults];
    
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    if (sortDescriptors) {
        [fetchRequest setSortDescriptors:sortDescriptors];
    }
    
    return fetchRequest;
}

- (NSManagedObject *)addObjectForEntityName:(NSString *)entityName {
    NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
    return newObject;
};

// **********************************************************************************************
//								Methods
// **********************************************************************************************

-(TPUser*) currentUser {
    NSFetchRequest *fetchRequest = [self fetchRequestForEntity:kUserEntityName withPredicate:nil sortDescriptors:nil faultsAllowed:YES];
    
    NSError *error = nil;
    NSArray *users = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [self.delegate coreDataSingleton:self didReportError:error];
    }
    return [users firstObject]; // there can be only one, like highlander
}

-(TPUser*) addUserWithID: (NSNumber*) userID {
    TPUser *user = (TPUser*) [self addObjectForEntityName:kUserEntityName];
    user.userID = userID;
    return user;
}

-(NSArray*) allAlbums {
    NSFetchRequest *fetchRequest = [self fetchRequestForEntity:kAlbumEntityName withPredicate:nil sortDescriptors:nil faultsAllowed:YES];
    
    NSError *error = nil;
    NSArray *albums = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [self.delegate coreDataSingleton:self didReportError:error];
    }
    return albums;
}

-(TPAlbum*) addAlbumWithID: (NSNumber*) albumID {
    TPAlbum *album = (TPAlbum*) [self addObjectForEntityName:kAlbumEntityName];
    album.albumID = albumID;
    return album;
}

-(NSFetchRequest*) fetchRequest_photosForTitle: (NSString*) title {
    NSPredicate *predicate = nil;
    
    if (title.length) {
        predicate = [NSPredicate predicateWithFormat:
                    @"title contains[cd] %@",title];
    }
    
    NSArray *sortDescriptors = @[
                                 [NSSortDescriptor sortDescriptorWithKey:@"photoID" ascending:YES]
                                 ];
    NSFetchRequest *fetchRequest = [self fetchRequestForEntity:kPhotoEntityName withPredicate:predicate sortDescriptors:sortDescriptors faultsAllowed:YES];
    
    return fetchRequest;
}

-(NSArray*) allPhotos {
    NSFetchRequest *fetchRequest = [self fetchRequestForEntity:kPhotoEntityName withPredicate:nil sortDescriptors:nil faultsAllowed:YES];
    
    NSError *error = nil;
    NSArray *photos = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [self.delegate coreDataSingleton:self didReportError:error];
    }
    return photos;
}

-(TPPhoto*) addPhotoWithID: (NSNumber*) photoID {
    TPPhoto *photo = (TPPhoto*) [self addObjectForEntityName:kPhotoEntityName];
    photo.photoID = photoID;
    return  photo;
}

@end
