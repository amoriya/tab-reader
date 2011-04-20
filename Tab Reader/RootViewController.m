//
//  RootViewController.m
//  Tab Reader
//
//  Created by junkoo hea on 11. 3. 24..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "TabViewController.h"
#import "SearchViewController.h"

@interface RootViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation RootViewController

@synthesize fetchedResultsController=__fetchedResultsController;

@synthesize managedObjectContext=__managedObjectContext;

@synthesize mySearchBar, mySearchText;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Set up the edit and add buttons.
    self.title = @"Library";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshbjects)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
	
	mySearchText = [[NSString alloc] initWithString:@""];
    
    [self syncFiles];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	[self.navigationController setNavigationBarHidden:NO animated:NO];
	self.wantsFullScreenLayout = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if( (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) )
		return YES;
	else
		return (UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		//[cell.detailTextLabel setTextAlignment:UITextAlignmentRight];
	}

    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the managed object for the given index path
		NSError *error = nil;
		
		NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
		NSString* filename = [managedObject valueForKey:@"filename"];
		NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString* filepath = [docDir stringByAppendingFormat:@"/%@", filename];
		[[NSFileManager defaultManager] removeItemAtPath:filepath error:&error];
		
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        if (![context save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TabViewController *tabViewController = [[TabViewController alloc] initWithNibName:@"TabViewController" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
	tabViewController.delegate = self;
    tabViewController.tabFilename = [managedObject valueForKey:@"filename"];
	tabViewController.tabIPod = [managedObject valueForKey:@"ipod"];
	tabViewController.tabTitle = [managedObject valueForKey:@"title"];
	tabViewController.tabArtist = [managedObject valueForKey:@"artist"];
	tabViewController.tabTempo = [[managedObject valueForKey:@"tempo"] intValue];
	tabViewController.tabTrackNo = [[managedObject valueForKey:@"track"] intValue];
	tabViewController.startAt = [[managedObject valueForKey:@"startat"] floatValue];
    [self.navigationController pushViewController:tabViewController animated:YES];
    [tabViewController release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
	[mySearchText release];
    [__fetchedResultsController release];
    [__managedObjectContext release];
    [super dealloc];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[managedObject valueForKey:@"title"] description];
	cell.detailTextLabel.text = [[managedObject valueForKey:@"artist"] description];
}

- (void)refreshbjects
{
	[self syncFiles];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
    */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tab" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];

	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
        {
	    /*
	     Replace this implementation with code to handle the error appropriately.

	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)checkFile:(NSString*)filename isInbox:(BOOL)inbox {
	NSString *extension = [filename pathExtension];
	if (![extension isEqualToString:@"gtp"]
		&& ![extension isEqualToString:@"gp3"]
		&& ![extension isEqualToString:@"gp4"]
		&& ![extension isEqualToString:@"gp5"]
		&& ![extension isEqualToString:@"gp6"]) {
		return;
	}
	
	NSString *realFileName; 
	if (inbox) {
		realFileName = [NSString stringWithFormat:@"Inbox/%@", filename];
	}
	else {
		realFileName = filename;
	}
	
	
	NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tab" inManagedObjectContext:context];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filename == %@", realFileName];
	[request setPredicate:predicate];
	NSError *error = nil;
	NSArray *array = [context executeFetchRequest:request error:&error];
	if (array == nil) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	NSManagedObject* newManagedObject;
	if( [array count] == 0 ) {
		NSEntityDescription *entityNew = [[self.fetchedResultsController fetchRequest] entity];
		newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entityNew name] inManagedObjectContext:context];
		[newManagedObject setValue:realFileName forKey:@"filename"];
		[newManagedObject setValue:filename forKey:@"title"];
		if (![context save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}	
}

- (void)syncFiles {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docDir error:nil];
    for (int i = 0; i < [dirContents count]; i++) {
        NSString* filename = [dirContents objectAtIndex:i];
		if([filename isEqualToString:@"Inbox"]) {
			NSArray *inboxContents = [[NSFileManager defaultManager] 
									  contentsOfDirectoryAtPath:[docDir stringByAppendingString:@"/Inbox"] 
									  error:nil];
			for (int j = 0; j < [inboxContents count]; j++) {
				NSString *inboxFile = [inboxContents objectAtIndex:j];
				[self checkFile:inboxFile isInbox:YES];
			}
		}
		else {
			[self checkFile:filename isInbox:NO];
		}
    }
}

- (void)updateSongInfo:(NSString*)filename 
				 title:(NSString*)theTitle 
				artist:(NSString*)theArtist 
				 tempo:(NSInteger)theTempo 
				 track:(NSInteger)theTrack {
	
	NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tab" inManagedObjectContext:context];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filename == %@", filename];
	[request setPredicate:predicate];
	NSError *error = nil;
	NSArray *array = [context executeFetchRequest:request error:&error];
	if (array == nil) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}

	
	if ([array count]) {
		BOOL dirty = NO;
		NSManagedObject* selObject = [array objectAtIndex:0];
		NSString* aTitle = [selObject valueForKey:@"title"];
		if (![aTitle isEqualToString:theTitle]) {
			[selObject setValue:theTitle forKey:@"title"];
			dirty = YES;
		}
		NSString* aArtist = [selObject valueForKey:@"artist"];
		if (![aArtist isEqualToString:theArtist]) {
			[selObject setValue:theArtist forKey:@"artist"];
			dirty = YES;
		}
		int aTempo = [[selObject valueForKey:@"tempo"] intValue];
		if (aTempo != theTempo) {
			[selObject setValue:[NSNumber numberWithInt:theTempo] forKey:@"tempo"];
			dirty = YES;
		}
		int aTrack = [[selObject valueForKey:@"track"] intValue];
		if (aTrack != theTrack) {
			[selObject setValue:[NSNumber numberWithInt:theTrack] forKey:@"track"];
			dirty = YES;
		}
		if (dirty) {
			if (![context save:&error]) {
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
				abort();
			}			
		}
	}
}

- (void)updateIPodInfo:(NSString*)filename ipod:(NSNumber*)theIPod {
	NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tab" inManagedObjectContext:context];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filename == %@", filename];
	[request setPredicate:predicate];
	NSError *error = nil;
	NSArray *array = [context executeFetchRequest:request error:&error];
	if (array == nil) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	if ([array count]) {
		NSManagedObject* selObject = [array objectAtIndex:0];
		NSNumber* aIPod = [selObject valueForKey:@"ipod"];
		if (![aIPod isEqualToNumber:theIPod]) {
			[selObject setValue:theIPod forKey:@"ipod"];
			if (![context save:&error]) {
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
				abort();
			}	
		}
	}
}

- (void)updateStartInfo:(NSString*)filename aStartAt:(float)theStartAt {
	NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tab" inManagedObjectContext:context];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filename == %@", filename];
	[request setPredicate:predicate];
	NSError *error = nil;
	NSArray *array = [context executeFetchRequest:request error:&error];
	if (array == nil) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	if ([array count]) {
		NSManagedObject* selObject = [array objectAtIndex:0];
		NSNumber* aStartAt = [selObject valueForKey:@"startat"];
		if ([aStartAt floatValue] != theStartAt ) {
			[selObject setValue:[NSNumber numberWithFloat:theStartAt] forKey:@"startat"];
			if (![context save:&error]) {
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
				abort();
			}	
		}
	}	
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = YES;
	return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	searchBar.showsCancelButton = NO;
	
	SearchViewController *searchViewController = [[SearchViewController alloc] 
												initWithNibName:@"SearchViewController" bundle:nil];
	searchViewController.delegate = self;
	searchViewController.mySearchText = mySearchText;
	[self presentModalViewController:searchViewController animated:YES];
	[searchViewController release];	
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[mySearchText release];
	mySearchText = [[NSString alloc]  initWithString:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	searchBar.text = @"";
	searchBar.showsCancelButton = NO;
	[searchBar resignFirstResponder];
}

- (void)onNewFile:(NSString*)filepath {
	[self syncFiles];
}
@end
