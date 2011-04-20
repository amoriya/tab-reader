//
//  TrackViewController2.h
//  Tab Reader
//
//  Created by junkoo hea on 11. 3. 31..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TrackViewController2Delegate <NSObject>
- (void)selectTrack:(NSInteger)track;
@end

@interface TrackViewController2 : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UITableView *myTableView;
	id<TrackViewController2Delegate> delegate;
	NSArray *tracks;
}

@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, assign) id<TrackViewController2Delegate> delegate;
@property (nonatomic, retain) NSArray *tracks;

- (IBAction)closeClicked:(id) sender;

@end
