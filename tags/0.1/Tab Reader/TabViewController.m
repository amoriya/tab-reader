//
//  TabViewController.m
//  Tab Reader
//
//  Created by junkoo hea on 11. 3. 24..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TabViewController.h"
#import "TrackViewController2.h"


@implementation TabViewController
@synthesize delegate, webView, toolBar, btnPlay, btnStop, btnMusic, btnHalf, btnSearch, btnLeft, btnLabel, btnRight, btnHide, tabFilename, tabIPod, tabTitle, tabArtist, tabTempo, tabTrackNo, startAt, tracks;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
	if (audioPlayer) {
		[audioPlayer release];
	}
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.tabTitle;
	//
	self.wantsFullScreenLayout = YES;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(selectTrack)];
    self.navigationItem.rightBarButtonItem = addButton;
	self.navigationItem.rightBarButtonItem.enabled = NO;
    [addButton release];
	
	// Do any additional setup after loading the view from its nib.
	audioPlayer = [[MPMusicPlayerController applicationMusicPlayer] retain];
	btnPlay.enabled = NO;
	btnStop.enabled = NO;
	btnMusic.enabled = NO;
	btnHalf.enabled = NO;
	btnSearch.enabled = NO;
	btnLeft.enabled = NO;
	btnLabel.enabled = NO;
	btnRight.enabled = NO;
	btnLabel.title = [NSString stringWithFormat:@"%0.1f", startAt];
	
	musicable = NO;
	musicOn = NO;
	playing = NO;

	CGRect bounds = [[UIScreen mainScreen] bounds];
	if( (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) )
		[btnHide setFrame:CGRectMake(bounds.size.width-60, bounds.size.height-64, 60,20)];
	else
		[btnHide setFrame:CGRectMake(bounds.size.height-60, bounds.size.width-64, 60,20)];
	
	//[self setBarsHidden:YES];
	
    NSURL *appURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"file" ofType:@"html"]];
    NSURLRequest *appReq = [NSURLRequest requestWithURL:appURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
	[self.webView loadRequest:appReq];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
	if ([audioPlayer playbackState] == MPMusicPlaybackStatePlaying) {
		[audioPlayer stop];
	}
	[webView stringByEvaluatingJavaScriptFromString:
	 [NSString stringWithFormat:@"api.stop();"]];

    [super viewWillDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if( (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) )
		return YES;
	else
		return (UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

- (void)setBarsHidden:(BOOL)hide {
	[[UIApplication sharedApplication] setStatusBarHidden:hide withAnimation:UIStatusBarAnimationNone];
	[self.navigationController setNavigationBarHidden:hide animated:NO];	
	[toolBar setHidden:hide];
}

- (void)webViewDidStartLoad:(UIWebView *)theWebView {
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}

- (BOOL)webView:(UIWebView *)theWebView 
shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
	if ([[url scheme] isEqualToString:@"tab"]) {
        if( [[url host] isEqualToString:@"load.song"] ) {
            [webView stringByEvaluatingJavaScriptFromString:
             [NSString stringWithFormat:@"var api = $('div.alphaTab').alphaTab({file: '../Documents/%@', track:%d, loadCallback: function(song) {var proto = 'tab://info.song/' + song.title + '/' + song.artist + '/' + song.tempo + '/';for( var i = 0; i < song.tracks.length; i++){proto += song.tracks[i].name + '/';}window.location=proto;}}).player({playerTickCallback:'onTickChanged'});function onTickChanged(tickPosition) {api.updateCaret(tickPosition);}", self.tabFilename, self.tabTrackNo]];
        }
		else if ( [[url host] isEqualToString:@"info.song"] ) {
			NSArray* args = [[url path] componentsSeparatedByString:@"/"];
			[self loadedSong:args];
		}
		else if ( [[url host] isEqualToString:@"log"] ) {
			NSLog(@"%@", [url path]);
		}
    }
	
	return YES;
}

- (void)loadedSong:(NSArray *)args {
	if (args == nil || [args count] < 4) {
		return;
	}
	
	NSString *title = [args objectAtIndex:1];
	self.tabArtist = [args objectAtIndex:2];
	self.tabTempo = [[args objectAtIndex:3] intValue];
	if (![title isEqualToString:self.tabTitle]) {
		self.tabTitle = title;
		self.title = title;
	}
	[delegate updateSongInfo:self.tabFilename 
					   title:self.tabTitle 
					  artist:self.tabArtist 
					   tempo:self.tabTempo
					   track:self.tabTrackNo];
	
	NSRange range = { 4, [args count] - 4 };
	self.tracks = [args subarrayWithRange:range];
	self.navigationItem.rightBarButtonItem.enabled = YES;
	
	[self searchSong:self.tabTitle];
}

- (void)selectTrack {
	TrackViewController2 *trackViewController = [[TrackViewController2 alloc] 
												  initWithNibName:@"TrackViewController2" bundle:nil];
	trackViewController.delegate = self;
	trackViewController.tracks = self.tracks;
	[self presentModalViewController:trackViewController animated:YES];
	[trackViewController release];		
}

- (void)selectTrack:(NSInteger)no {
	if (self.tabTrackNo != no) {
		self.tabTrackNo = no;
		[webView stringByEvaluatingJavaScriptFromString:
		 [NSString stringWithFormat:@"api.tablature.setTrack(api.tablature.track.song.tracks[%d]);", no]];
        
		[delegate updateSongInfo:self.tabFilename 
						   title:self.tabTitle 
						  artist:self.tabArtist 
						   tempo:self.tabTempo 
						   track:self.tabTrackNo];
	}
}

- (void)searchSong:(NSString *)title {
	NSNumber *zero = [NSNumber numberWithInt:0];
	MPMediaPropertyPredicate* songP;
	if ([self.tabIPod isEqualToNumber:zero]) {
		songP = [MPMediaPropertyPredicate predicateWithValue:title 
												 forProperty:MPMediaItemPropertyTitle];
	}
	else {
		songP = [MPMediaPropertyPredicate predicateWithValue:self.tabIPod 
												 forProperty:MPMediaItemPropertyPersistentID];
		
	}
	NSSet* set = [NSSet setWithObjects:songP, nil];
	
	MPMediaQuery* query = [[[MPMediaQuery alloc] initWithFilterPredicates:set] autorelease];
	if ([[query items] count] > 0) {
		[audioPlayer setQueueWithQuery:query];
		if ([self.tabIPod isEqualToNumber:zero]) {
			MPMediaItem* item = [[query items] objectAtIndex:0];
			self.tabIPod = [item valueForProperty:MPMediaItemPropertyPersistentID];
			[self.delegate updateIPodInfo:self.tabFilename ipod:self.tabIPod];
		}
		musicable = YES;
		musicOn = YES;
		UIImage *on = [UIImage imageWithContentsOfFile:
					   [[NSBundle mainBundle] pathForResource:@"on" ofType:@"png"]];
		[btnMusic setImage:on];
		[btnMusic setEnabled:YES];
	}
	btnPlay.enabled = YES;
	btnStop.enabled = YES;
	btnHalf.enabled = YES;
	btnSearch.enabled = YES;
	btnLeft.enabled = YES;
	btnLabel.enabled = YES;
	btnRight.enabled = YES;
	[webView stringByEvaluatingJavaScriptFromString:
	 [NSString stringWithFormat:@"api.setStartAt(%f);", startAt]];
}

- (IBAction)playSong:(id) sender {
	if (playing) {
		if (musicOn) {
			if (audioPlayer.playbackState == MPMoviePlaybackStatePlaying) {
				[audioPlayer pause];
			}
		}
		playing = NO;
		UIImage *play = [UIImage imageWithContentsOfFile:
						 [[NSBundle mainBundle] pathForResource:@"play" ofType:@"png"]];
		[btnPlay setImage:play];			
		[webView stringByEvaluatingJavaScriptFromString:
		 [NSString stringWithFormat:@"api.pause();"]];
	}
	else {
		if (musicOn) {
			if (audioPlayer.playbackState != MPMoviePlaybackStatePlaying) {
				[audioPlayer play];
			}
		}
		playing	= YES;
		UIImage *pause = [UIImage imageWithContentsOfFile:
						 [[NSBundle mainBundle] pathForResource:@"pause" ofType:@"png"]];
		[btnPlay setImage:pause];
		[webView stringByEvaluatingJavaScriptFromString:
		 [NSString stringWithFormat:@"api.play();"]];
	}
}

- (IBAction)stopSong:(id) sender {
	if (musicOn) {
		[audioPlayer stop];
	}
	playing = NO;
	UIImage *play = [UIImage imageWithContentsOfFile:
					 [[NSBundle mainBundle] pathForResource:@"play" ofType:@"png"]];
	[btnPlay setImage:play];
	[webView stringByEvaluatingJavaScriptFromString:
	 [NSString stringWithFormat:@"api.stop();"]];
}

- (IBAction)selectSong:(id) sender {
	MPMediaPickerController *picker = [[MPMediaPickerController alloc] 
									   initWithMediaTypes: MPMediaTypeAnyAudio];
	[picker setDelegate: self];
	[picker setAllowsPickingMultipleItems: NO];
	picker.prompt = NSLocalizedString (@"Add songs to play", "Prompt in media item picker");
	
	[self.navigationController presentModalViewController: picker animated: YES];
	[picker release];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
	[self dismissModalViewControllerAnimated: YES];
	btnPlay.enabled = YES;
	btnStop.enabled = YES;
	btnHalf.enabled = YES;
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker
   didPickMediaItems: (MPMediaItemCollection *) collection {
	
    [self dismissModalViewControllerAnimated: YES];
	if ([[collection items] count] > 0) {
		[audioPlayer setQueueWithItemCollection: collection];
		MPMediaItem* item = [[collection items] objectAtIndex:0];
		self.tabIPod = [item valueForProperty:MPMediaItemPropertyPersistentID];
		[self.delegate updateIPodInfo:self.tabFilename ipod:self.tabIPod];
		musicable = YES;
		musicOn = YES;
		UIImage *on = [UIImage imageWithContentsOfFile:
					   [[NSBundle mainBundle] pathForResource:@"on" ofType:@"png"]];
		[btnMusic setImage:on];
		[btnMusic setEnabled:YES];
	}
	btnPlay.enabled = YES;
	btnStop.enabled = YES;
	btnHalf.enabled = YES;
}

- (IBAction)hideToolbar:(id) sender {
	if (toolBar.hidden) {
		[self setBarsHidden:NO];
		UIImage *down = [UIImage imageWithContentsOfFile:
						  [[NSBundle mainBundle] pathForResource:@"down" ofType:@"png"]];
		[btnHide setImage:down forState:UIControlStateNormal];
		CGRect bounds = [[UIScreen mainScreen] bounds];
		if( (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) )
			[btnHide setFrame:CGRectMake(bounds.size.width-60, bounds.size.height-64, 60,20)];
		else
			[btnHide setFrame:CGRectMake(bounds.size.height-60, bounds.size.width-64, 60,20)];		
	}
	else {
		[self setBarsHidden:YES];
		UIImage *up = [UIImage imageWithContentsOfFile:
					   [[NSBundle mainBundle] pathForResource:@"up" ofType:@"png"]];
		[btnHide setImage:up forState:UIControlStateNormal];
		CGRect bounds = [[UIScreen mainScreen] bounds];
		if( (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) )
			[btnHide setFrame:CGRectMake(bounds.size.width-60, bounds.size.height-20, 60,20)];
		else
			[btnHide setFrame:CGRectMake(bounds.size.height-60, bounds.size.width-20, 60,20)];		
	}
}

- (IBAction)setMusicOn:(id) sender {
	if (musicable) {
		if (musicOn) {
			[self stopSong:nil];
			musicOn = NO;
			UIImage *off = [UIImage imageWithContentsOfFile:
						   [[NSBundle mainBundle] pathForResource:@"off" ofType:@"png"]];
			[btnMusic setImage:off];
		}
		else {
			[self stopSong:nil];
			musicOn = YES;
			UIImage *on = [UIImage imageWithContentsOfFile:
							[[NSBundle mainBundle] pathForResource:@"on" ofType:@"png"]];
			[btnMusic setImage:on];
			
			// set to spped 1.0
			[webView stringByEvaluatingJavaScriptFromString:
			 [NSString stringWithFormat:@"api.setSpeed(1.0);"]];
			[btnHalf setTitle:@"1"];
		}
		[self stopSong:nil];
	}
}

- (IBAction)halfSpeed:(id) sender {
	if (playing) {
		playing = NO;
		UIImage *play = [UIImage imageWithContentsOfFile:
						 [[NSBundle mainBundle] pathForResource:@"play" ofType:@"png"]];
		[btnPlay setImage:play];
		[webView stringByEvaluatingJavaScriptFromString:
		 [NSString stringWithFormat:@"api.pause();"]];
	}
	
	if ([btnHalf.title isEqualToString:@"1"]) {
		[webView stringByEvaluatingJavaScriptFromString:
		 [NSString stringWithFormat:@"api.setSpeed(0.5);"]];
		[btnHalf setTitle:@"1/2"];
		
		// sound off
		[self stopSong:nil];
		musicOn = NO;
		UIImage *off = [UIImage imageWithContentsOfFile:
						[[NSBundle mainBundle] pathForResource:@"off" ofType:@"png"]];
		[btnMusic setImage:off];
	}
	else {
		[webView stringByEvaluatingJavaScriptFromString:
		 [NSString stringWithFormat:@"api.setSpeed(1.0);"]];
		[btnHalf setTitle:@"1"];
	}
}

- (IBAction)moveLeft:(id) sender {
	startAt = startAt - 0.5;
	btnLabel.title = [NSString stringWithFormat:@"%.1f", startAt];
	[webView stringByEvaluatingJavaScriptFromString:
	 [NSString stringWithFormat:@"api.setStartAt(%f);", startAt]];
	[delegate updateStartInfo:self.tabFilename aStartAt:startAt];
}

- (IBAction)moveRight:(id) sender {
	startAt = startAt + 0.5;
	btnLabel.title = [NSString stringWithFormat:@"%.1f", startAt];
	[webView stringByEvaluatingJavaScriptFromString:
	 [NSString stringWithFormat:@"api.setStartAt(%f);", startAt]];
	[delegate updateStartInfo:self.tabFilename aStartAt:startAt];
}

@end
