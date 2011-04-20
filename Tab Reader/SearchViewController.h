//
//  SearchViewController.h
//  Tab Reader
//
//  Created by junkoo hea on 11. 3. 30..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Song : NSObject
{
	NSString* songId;
	NSString* songTitle;
	NSString* songArtist;
}

@property (nonatomic, assign) NSString* songId;
@property (nonatomic, assign) NSString* songTitle;
@property (nonatomic, assign) NSString* songArtist;

@end

@protocol SearchViewControllerDelegate <NSObject>
- (void)onNewFile:(NSString*)filepath;
@end

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate> {
	id<SearchViewControllerDelegate> delegate;
	IBOutlet UITableView *myTableView;
	NSString* mySearchText;
	NSString* parsingTag;
	NSString* parentTag;
	Song* aSong;
	NSMutableArray* songs;
	BOOL gpSearch;
	NSString* gpUrl;
}

@property (nonatomic, assign) id<SearchViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) NSString* mySearchText;
@property (nonatomic, retain) Song* aSong;

- (IBAction)close:(id) sender;

@end
