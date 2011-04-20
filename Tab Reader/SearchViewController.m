//
//  SearchViewController.m
//  Tab Reader
//
//  Created by junkoo hea on 11. 3. 30..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"

@implementation Song

@synthesize songId, songTitle, songArtist;

@end


@implementation SearchViewController
@synthesize delegate, myTableView, mySearchText, aSong;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (void)doLoadList:(SearchViewController*) controller {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSURL *searchUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.songsterr.com/a/ra/songs.xml?pattern=%@", controller.mySearchText]];
	NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:searchUrl];
	[parser setDelegate:self];
	[parser parse];
	[controller.myTableView reloadData];
	[pool drain];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)doDownloadGP:(SearchViewController*) controller {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	NSURL *searchUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.songsterr.com/a/ra/player/song/%@.xml", controller.aSong.songId]];
	NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:searchUrl];
	[parser setDelegate:self];
	if ([parser parse]) {
		NSURL *downUrl = [NSURL URLWithString:gpUrl];
		NSData *downData = [NSData dataWithContentsOfURL:downUrl];
		NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *filePath = [NSString stringWithFormat:@"%@%@", docDir, [downUrl relativePath]];
		[downData writeToFile:filePath atomically:YES];
		[controller.delegate onNewFile:filePath];
		[controller dismissModalViewControllerAnimated:YES];
	};
	[pool drain];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	songs = [[NSMutableArray alloc] initWithCapacity:10];
	
	gpSearch = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	NSThread *myThread = [[NSThread alloc] initWithTarget:self selector:@selector(doLoadList:) object:self];
	[myThread start];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if( (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) )
		return YES;
	else
		return (UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [songs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"any-cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
	Song *song = [songs objectAtIndex:[indexPath row]];
	cell.textLabel.text = song.songTitle;
	cell.detailTextLabel.text = song.songArtist;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	aSong = [songs objectAtIndex:[indexPath row]];
	gpSearch = YES;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	NSThread *myThread = [[NSThread alloc] initWithTarget:self selector:@selector(doDownloadGP:) object:self];
	[myThread start];	
	/*
	NSURL *searchUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.songsterr.com/a/ra/player/song/%@.xml", aSong.songId]];
	NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:searchUrl];
	[parser setDelegate:self];
	if ([parser parse]) {
		NSURL *downUrl = [NSURL URLWithString:gpUrl];
		NSData *downData = [NSData dataWithContentsOfURL:downUrl];
		NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *filePath = [NSString stringWithFormat:@"%@%@", docDir, [downUrl relativePath]];
		[downData writeToFile:filePath atomically:YES];
		[delegate onNewFile:filePath];
		[self dismissModalViewControllerAnimated:YES];
	};
	*/
}

- (IBAction)close:(id) sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if (gpSearch) {
		parentTag = parsingTag;
	}
	else {
		if ([elementName isEqualToString:@"Song"]) {
			aSong = [[Song alloc] init];
			aSong.songId = [[NSString alloc] initWithString:[attributeDict objectForKey:@"id"]];
		}
	}
	parsingTag = elementName;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (gpSearch) {
		if ([parsingTag isEqualToString:@"attachmentUrl"]) {
			if ([parentTag isEqualToString:@"guitarProTab"]) {
				gpUrl = [[NSString alloc] initWithString:string];
			}
		}
	}
	else {
		if ([parsingTag isEqualToString:@"title"]) {
			aSong.songTitle = [[NSString alloc] initWithString:string];
		}
		else if([parsingTag isEqualToString:@"name"]) {
			aSong.songArtist = [[NSString alloc] initWithString:string];
		}
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	parsingTag = @"";
	if (gpSearch) {
	}
	else {
		if ([elementName isEqualToString:@"Song"]) {
			[songs addObject:aSong];
		}	
	}
}

@end
