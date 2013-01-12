//
//  EXQIDSQuestionPage.m
//  Domo Depression
//
//  Created by Alexander List on 1/11/13.
//  Copyright (c) 2013 ExoMachina. All rights reserved.
//

#import "EXQIDSQuestionPage.h"
#import "MGLineStyled.h"
#import "MGTableBoxStyled.h"

@implementation EXQIDSQuestionPage
@synthesize pageNumber, questionValues, formInfoHeaderText,formInfoFooterCornerText;
@synthesize primaryQTable;
@synthesize rowSize, headerFont;
@synthesize delegate;

-(id)initWithDelegate:(id<EXQIDSQuestionPageDelegate>) tDelegate frame:(CGRect)frame{
	if (self =[super initWithFrame:frame]){
		[self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
		
		self.delegate = tDelegate;
		
		self.headerFont = [UIFont fontWithName:@"HelveticaNeue" size:18];
		
		[self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"crisp_paper_ruffles"]]];
		
		if (deviceIsPad){
			self.rowSize = (CGSize){400, 50};
		}else{
			self.rowSize = (CGSize){304, 40};
		}
		
		double tableHeight = (deviceIsPad)? 580 : 400;
		self.primaryQTable = [MGBox boxWithSize:CGSizeMake(self.width, tableHeight)];
		double margin = ceil( (self.size.width- self.primaryQTable.width)/2);
		[self.primaryQTable setOrigin:CGPointMake(margin, (deviceIsPad)? IPAD_TOP_MARGIN-QUESTION_SPACING : IPHONE_TOP_MARGIN-QUESTION_SPACING)];
		[self.primaryQTable setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight];
		[self addSubview:self.primaryQTable];
	}
	return self;
}


-(MGBox*) generateQuestionBoxWithTitle:(NSString*)title qNumber:(NSInteger)qNumber responseValues:(NSArray*)responseVals{
	MGTableBoxStyled *newBox = [MGTableBoxStyled box];
	[newBox setTopMargin:30];
	[newBox setRasterize:TRUE];
	
	double margin = ceil( (self.size.width- self.rowSize.width)/2);
	[newBox setLeftMargin:margin];
		
	MGLineStyled *head = [MGLineStyled lineWithLeft:title right:nil size:self.rowSize];
	[newBox.topLines addObject:head];
	head.font = self.headerFont;
	
	for (NSString * response in responseVals){
		MGLineStyled * responseLine = [MGLineStyled lineWithLeft:[UIImage imageNamed:@"MNMRadioGroupUnselected"] multilineRight:response width:self.rowSize.width minHeight:self.rowSize.height];
		[responseLine setTopPadding:5];
		[responseLine setBottomPadding:5];
		[responseLine setRightItemsTextAlignment:NSTextAlignmentRight];
		[newBox.topLines addObject:responseLine];
	}
	
	return newBox;
}

-(void) updateViewWithQIDSSubmission:(EXQIDSSubmission*)submission qidsManager:(EXQIDSManager*)qidsManager pageNumber:(NSInteger)tPageNumber{
	
	[self prepareForReuse];
	
	self.pageNumber = tPageNumber;
	
	NSInteger questionsPerPage = (deviceIsPad)?IPAD_MAXQUESTIONS_PER_PAGE:IPHONE_MAXQUESTIONS_PER_PAGE;
	NSInteger startQNumber = tPageNumber*questionsPerPage;
	NSRange qRange = NSMakeRange(startQNumber, MIN(questionsPerPage, [[qidsManager questions] count]-startQNumber));
	
	NSArray * pageQuestions = [[qidsManager questions] subarrayWithRange:qRange];
	
	for (NSDictionary * question in pageQuestions){
		[self.primaryQTable.boxes addObject:[self generateQuestionBoxWithTitle:[question valueForKey:@"prompt"] qNumber:(startQNumber + [pageQuestions indexOfObject:question]) responseValues:[question valueForKey:@"values"]]];
	}
	
	self.formInfoFooterCornerText = [NSDateFormatter localizedStringFromDate:[submission officialDate] dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
	
	if (self.pageNumber == 0){
		self.formInfoHeaderText = [qidsManager title];
	}
	
	[self updatePageUI];
}

-(void) updatePageUI{
	[self.primaryQTable layoutWithSpeed:0 completion:nil];
	//and then do traditional labels, if we include them.
}

-(void) prepareForReuse{
	[self.primaryQTable.boxes removeAllObjects];
	self.questionValues = nil;
	self.formInfoHeaderText = nil;
	self.formInfoFooterCornerText = nil;
}

@end
