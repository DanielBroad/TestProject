//
//  DRCoreData.m
//  TestProject
//
//  Created by Daniel Broad on 20/11/2015.
//  Copyright © 2015 Dorada App Software Ltd. All rights reserved.
//

#import "TPCoreData.h"

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

#pragma mark - logging

-(void) log: (NSString*) log {
    Class quincy = NSClassFromString(@"BWQuincyManager");
    id<QuincyLogProtocol> quincyProtocol = (id)quincy;
    
    if ([quincyProtocol respondsToSelector:@selector(log:)]) {
        [quincyProtocol log:log,nil];
    }
}

-(void) log: (NSString*) log WithVar: (id) var {
    Class quincy = NSClassFromString(@"BWQuincyManager");
    id<QuincyLogProtocol> quincyProtocol = (id)quincy;
    
    if ([quincyProtocol respondsToSelector:@selector(log:)]) {
        [quincyProtocol log:log,var];
    }
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
    // this function is background thread aware
    
    if ([NSThread isMainThread]) {
        
        if (_managedObjectContext != nil) {
            return _managedObjectContext;
        }
        
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil) {
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [_managedObjectContext setPersistentStoreCoordinator: coordinator];
        }
        return _managedObjectContext;
    } else {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil) {
            NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
            [managedObjectContext setPersistentStoreCoordinator: coordinator];
            return managedObjectContext;
        }
    }
    
    return nil;
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
    
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:[self dataModelName] ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    
    /*[nc addObserver:self
     selector:@selector(modelChanged:)
     name:NSManagedObjectContextObjectsDidChangeNotification
     object:nil];*/
    
    return _managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */

// migrate the database and back again to solve corruption problems

- (BOOL) rebuildDatabase {
    NSError *error;
    
    NSPersistentStore *store = [[self.persistentStoreCoordinator persistentStores] objectAtIndex:0];
    
    NSURL *normalStoreUrl = [NSURL fileURLWithPath: [[DRApplicationPaths applicationHiddenDocumentsDirectory]
                                                     stringByAppendingPathComponent: [self databaseName]]];
    
    NSURL *tempStoreUrl = [NSURL fileURLWithPath: [[DRApplicationPaths applicationHiddenDocumentsDirectory]
                                                   stringByAppendingPathComponent: [self databaseName]]];
    
    [[NSFileManager defaultManager] removeItemAtURL:tempStoreUrl error:&error];
    
    NSMutableDictionary *pragmaOptions = [NSMutableDictionary dictionary];
    [pragmaOptions setObject:@"DELETE" forKey:@"journal_mode"];
    
    NSDictionary * options = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES], NSSQLiteAnalyzeOption,
                              [NSNumber numberWithBool:YES], NSSQLiteManualVacuumOption,
                              pragmaOptions,NSSQLitePragmasOption,
                              nil];
    
    if ([self.persistentStoreCoordinator migratePersistentStore:store toURL:tempStoreUrl options:options withType:NSSQLiteStoreType error:&error]) {
        if ([[NSFileManager defaultManager] removeItemAtURL:normalStoreUrl error:&error]) {
            store = [[self.persistentStoreCoordinator persistentStores] objectAtIndex:0];
            if ([self.persistentStoreCoordinator migratePersistentStore:store toURL:normalStoreUrl options:options withType:NSSQLiteStoreType error:&error]) {
                [[NSFileManager defaultManager] removeItemAtURL:tempStoreUrl error:&error];
                return YES;
            }
        }
    }
    
    return NO;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[DRApplicationPaths applicationHiddenDocumentsDirectory]
                                               stringByAppendingPathComponent: [self databaseName]]];
    
    NSError *error = nil;
    
    NSMutableDictionary *pragmaOptions = [NSMutableDictionary dictionary];
    [pragmaOptions setObject:@"DELETE" forKey:@"journal_mode"];
    
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             pragmaOptions,NSSQLitePragmasOption,
                             nil];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:  NSSQLiteStoreType
                                                   configuration:nil URL:storeUrl options:options error:&error]) {
        @throw [NSException exceptionWithName:@"Persistent Store" reason:[NSString stringWithFormat:@"Unresolved error %@, %@", error, [error userInfo]] userInfo:nil];
        abort();
    }
    
    return _persistentStoreCoordinator;
}

-(void) contextSave
{
    @try {
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity:4096];
            
            [buffer appendFormat:@"%@*%@**\n",[[UIDevice currentDevice] systemVersion],@"MOC"];
            [self log:@"Couldn't save MOC: %@" WithVar:[error localizedDescription]];
            
            NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
            if(detailedErrors != nil && [detailedErrors count] > 0) {
                for(NSError* detailedError in detailedErrors) {
                    [buffer appendFormat:@"  DetailedError: %@", [detailedError userInfo]];
                }
            }
            else {
                [buffer appendFormat:@"  %@", [error userInfo]];
            }
            
            [buffer appendFormat:@"MOC: end"];
            
            NSError *err;
            [buffer writeToFile:[DRApplicationPaths.applicationHiddenDocumentsDirectory stringByAppendingPathComponent:@"databaseError.log"] atomically:YES encoding:NSUTF8StringEncoding error:&err];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ContextCannotSave" object:nil]; // let any living objects know
        }
    }
    @catch (NSException * e) {
        // oops
        [self log:@"Exception saving context %@" WithVar:[e reason]];
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
}

// override

-(NSString*) dataModelName {
    return @"database";
}

-(NSString*) databaseName {
    return @"database.sqlite";
}
