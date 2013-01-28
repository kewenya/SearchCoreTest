//
//  ContactPeople.m
//  SearchCoreTest
//
//  Created by Apple on 28/01/13.
//  Copyright (c) 2013 kewenya. All rights reserved.
//

#import "ContactPeople.h"

@implementation ContactPeople
@synthesize localID;
@synthesize name;
@synthesize phoneArray;

- (void)dealloc
{
    self.localID = nil;
    self.name = nil;
    self.phoneArray = nil;
    
    [super dealloc];
}

@end
