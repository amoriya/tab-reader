//
//  TabViewController.h
//  Tab Reader
//
//  Created by junkoo hea on 11. 3. 24..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "TrackViewController2.h"

@protocol TabViewControllerDelegate <NSObject>
- (void)updateSongInfo:(NSString*)filename 
				 title:(NSString*)theTitle 
				artist:(NSString*)theArtist 
				 tempo:(NSInteger)theTempo 
				 track:(NSInteger)theTrack;
- (void)updateIPodInfo:(NSString*)filename ipod:(NSNumber*)theIPod; 
- (void)updateStartInfo:(NSString*)filename aStartAt:(float)theStartAt;
@end

@interface TabViewController : UIViewController <UIWebViewDelegate, TrackViewController2Delegate, MPMediaPickerControllerDelegate> {
	id<TabViewControllerDelegate> delegate;
	UIWebView* webView;    
	UIToolbar* toolBar;
	UIBarButtonItem* btnPlay;
	UIBarButtonItem* btnStop;
	UIBarButtonItem* btnMusic;
	UIBarButtonItem* btnHalf;
	UIBarButtonItem* btnSearch;
	UIBarButtonItem* btnLeft;
	UIBarButtonItem* btnLabel;
	UIBarButtonItem* btnRight;
	UIButton* btnHide;
    NSString* tabFilename;
	NSNumber* tabIPod;
    NSString* tabTitle;
	NSString* tabArtist;
	NSInteger tabTempo;
	NSInteger tabTrackNo;
	float startAt;
	NSArray* tracks;
	MPMusicPlayerController* audioPlayer;
	BOOL musicable;
	BOOL musicOn;
	BOOL playing;
}

@property (nonatomic, assign) id<TabViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *btnPlay;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *btnStop;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *btnMusic;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *btnHalf;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *btnSearch;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* btnLeft;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* btnLabel;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* btnRight;
@property (nonatomic, retain) IBOutlet UIButton *btnHide;
@property (nonatomic, retain) NSString *tabFilename;
@property (nonatomic, retain) NSNumber *tabIPod;
@property (nonatomic, retain) NSString *tabTitle;
@property (nonatomic, retain) NSString *tabArtist;
@property (nonatomic, assign) NSInteger tabTempo;
@property (nonatomic, assign) NSInteger tabTrackNo;
@property (nonatomic, assign) float startAt;
@property (nonatomic, retain) NSArray *tracks;


- (void)setBarsHidden:(BOOL)hide;
- (void)loadedSong:(NSArray *)args;
- (void)searchSong:(NSString *)title;
- (IBAction)playSong:(id) sender;
- (IBAction)stopSong:(id) sender;
- (IBAction)selectSong:(id) sender;
- (IBAction)hideToolbar:(id) sender;
- (IBAction)setMusicOn:(id) sender;
- (IBAction)halfSpeed:(id) sender;
- (IBAction)moveLeft:(id) sender;
- (IBAction)moveRight:(id) sender;


@end
