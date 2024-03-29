//
//  EXQIDSChartDatasource.m
//  Domo Depression
//
//  Created by Alexander List on 1/16/13.
//  Copyright (c) 2013 ExoMachina. All rights reserved.
//

#import "EXQIDSChartDatasource.h"
#import "EXQIDSQuestionPage.h"

@implementation EXQIDSChartDatasource
@synthesize currentAuthor = _currentAuthor;

-(id)init{
	if (self = [super init]){
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_dataUpdated:) name:newQIDSSubmittedNotification object:nil];
	}
	return self;
}


-(void)_dataUpdated:(id)sender{
	
}

-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(NSArray*) QIDSSubmissionsToDisplayBetweenOlderDate:(NSDate*)olderDate newerDate:(NSDate*)newerDate{
#pragma MARK TODO: #optimize by pre-fetching
	
	NSFetchRequest * submissionRequest = [EXQIDSSubmission createFetchRequest];
//	[submissionRequest setPropertiesToFetch:@[@"completionDate",@"qidsSeverity",@"qidsValue",@"dueDate"]];
	[submissionRequest  setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"completionDate" ascending:FALSE]]];
	[submissionRequest setPredicate:[NSPredicate predicateWithFormat:@"(completionDate > %@) AND (completionDate < %@)",olderDate,newerDate]];
	
	NSArray * submissions = [EXQIDSSubmission executeFetchRequest:submissionRequest];
	
	_lastFetchedQIDSSubmissions = submissions;
	
	return submissions;
}

-(EXQIDSSubmission*)displayedQIDSSubmissionAtIndex:(NSInteger) displayIndex{
	
	if ([_lastFetchedQIDSSubmissions count] > displayIndex){
		return [_lastFetchedQIDSSubmissions objectAtIndex:displayIndex];
	}
	
	return nil;
}

-(NSTimeInterval) secondsSinceFirstQIDSSubmission{

	EXQIDSSubmission * submission = [EXQIDSSubmission findFirstWithPredicate:[NSPredicate predicateWithFormat:@"completionDate != nil"] sortedBy:@"completionDate" ascending:TRUE];
	
	NSTimeInterval secondsSince = [[submission completionDate] timeIntervalSinceNow];

	return secondsSince;
	
}

@end
