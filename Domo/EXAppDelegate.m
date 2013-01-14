//
//  EXAppDelegate.m
//  Feel Better: Depression
//
//  Created by Alexander List on 1/4/13.
//  Copyright (c) 2013 ExoMachina. All rights reserved.
//

#import "EXAppDelegate.h"

@interface EXAppDelegate ()
-(EXAuthor*) generateLocalUser;
@end

@implementation EXAppDelegate

@synthesize navSideBarPad, navTabBarPod;
@synthesize managedObjectContext = _managedObjectContext;
//@synthesize managedObjectModel = _managedObjectModel;
//@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize authorForCurrentUser = _authorForCurrentUser, userComManager,qidsManager;

@synthesize trackVC, analyzeVC, improveVC;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//	[MagicalRecord setupCoreDataStackWithiCloudContainer:@"A7426L9B95.com.exomachina.domodepression.ubiquitycoredata" localStoreNamed:@"Domo_Depression.sqlite"];
	[MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"Domo_Depression.sqlite"];
	self.managedObjectContext = [NSManagedObjectContext MR_defaultContext];
	
	self.qidsManager = [[EXQIDSManager alloc] init];
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	self.userComManager = [EXUserComManager sharedUserComManager];
	[self.userComManager setAuthor:	self.authorForCurrentUser];
	
	self.trackVC	= [[EXTrackVC alloc] init];
	[self.trackVC setQidsManager:qidsManager];
	self.analyzeVC	= [[EXAnalyzeVC alloc] init];
	self.improveVC	= [[EXImproveVC alloc] init];
	
	
	NSArray * VCs = @[self.trackVC, self.analyzeVC,self.improveVC];
	
	if (deviceIsPad){
		self.navSideBarPad	= [[CKSideBarController alloc] init];
		[self.navSideBarPad setViewControllers:VCs];
		[self.window setRootViewController:self.navSideBarPad];

	}else{
		self.navTabBarPod	= [[UITabBarController alloc] init];
		[self.navTabBarPod setViewControllers:VCs];		
		[self.window setRootViewController:self.navTabBarPod];
	}
	
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - user data
-(EXAuthor*)authorForCurrentUser{
	if (_authorForCurrentUser != nil && [NSThread isMainThread]){
		return _authorForCurrentUser;
	}else {
		EXAuthor * author = nil;
		NSString* userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"localAuthorUserID"];
		if (userID >0 ){
			NSArray * authors = [self.managedObjectContext executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"EXAuthor"] error:nil]; //[EXAuthor objectsWithPredicate:[NSPredicate predicateWithFormat:@"authorID == %@", userID]];
			
			if ([authors count] > 0){
				author = [authors objectAtIndex:0];
			}else{
				author = [self generateLocalUser];
			}
		}else{
			author = [self generateLocalUser];
		}
		
		if (_authorForCurrentUser == nil && [NSThread isMainThread]){
			_authorForCurrentUser = author;
			[self setAuthorForCurrentUser:author];
			return _authorForCurrentUser;
		}else{
			return author;
		}
	}
}

-(EXAuthor*) generateLocalUser{
	NSString* userID = @"101";
	
	EXAuthor * newAuthor = [EXAuthor createInContext:[NSManagedObjectContext contextForCurrentThread]];
	
	[newAuthor setAuthorID:userID];
	[newAuthor setDisplayName:@"newAuthor 101"];
	[newAuthor setQidsSpacingInterval:self.qidsManager.formSpacingInterval];
	[newAuthor setIsOnboarding:@(TRUE)];
	
	[[NSUserDefaults standardUserDefaults] setValue:[newAuthor authorID] forKey:@"localAuthorUserID"];
	
	[self.managedObjectContext saveOnlySelfWithCompletion:nil];
	
	return newAuthor;
}




#pragma mark - app junk

- (void)applicationWillResignActive:(UIApplication *)application{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	[[self managedObjectContext] saveToPersistentStoreAndWait];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
}

- (void)applicationWillTerminate:(UIApplication *)application{
	[MagicalRecord cleanUp];
}

@end
