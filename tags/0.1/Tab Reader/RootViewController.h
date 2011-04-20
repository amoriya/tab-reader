//
//  RootViewController.h
//  Tab Reader
//
//  Created by junkoo hea on 11. 3. 24..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import "TabViewController.h"
#import "SearchViewController.h"

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate, TabViewControllerDelegate, UISearchBarDelegate, SearchViewControllerDelegate> {
	IBOutlet UISearchBar *mySearchBar;
	NSString *mySearchText;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UISearchBar *mySearchBar; 
@property (nonatomic, retain) NSString* mySearchText;

- (void)syncFiles;

@end
