//
//  ViewController.m
//  SearchCoreTest
//
//  Created by Apple on 28/01/13.
//  Copyright (c) 2013 kewenya. All rights reserved.
//

#import "ViewController.h"
#import "SearchCoreManager.h"
#import "ContactPeople.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize tableView;
@synthesize searchBar;
@synthesize contactDic;
@synthesize searchByName;
@synthesize searchByPhone;

- (void)tableViewInit {
    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f-44.0f)] autorelease];
    self.tableView.dataSource=self;
	self.tableView.delegate=self;
	self.tableView.backgroundColor=[UIColor clearColor];
	[self.view addSubview:self.tableView];
}
- (void)searchBarInit {
     self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 310.0f, 44.0f)] autorelease];
    
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.keyboardType = UIKeyboardTypeDefault;
	self.searchBar.backgroundColor=[UIColor clearColor];
	searchBar.translucent=YES;
	self.searchBar.placeholder=@"搜索";
	self.searchBar.delegate = self;
	self.searchBar.barStyle=UIBarStyleDefault;
    
    self.tableView.tableHeaderView=self.searchBar;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   
    
    [self tableViewInit];
    [self searchBarInit];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    self.contactDic = dic;
    [dic release];
    
    NSMutableArray *nameIDArray = [[NSMutableArray alloc] init];
    self.searchByName = nameIDArray;
    [nameIDArray release];
    NSMutableArray *phoneIDArray = [[NSMutableArray alloc] init];
    
    self.searchByPhone = phoneIDArray;
    [phoneIDArray release];
    
    
    
    ContactPeople *contact = [[ContactPeople alloc] init];
    contact.localID = [NSNumber numberWithInt:0];
    contact.name = @"西藏";
    
    NSMutableArray *phoneArray = [[NSMutableArray alloc] init]; 
    [phoneArray addObject:@"13800138000"];
    [phoneArray addObject:@"10086"];
    contact.phoneArray = phoneArray;
    [phoneArray release];
    
    [self.contactDic setObject:contact forKey:contact.localID];
    
    //添加到搜索库
    [[SearchCoreManager share] AddContact:contact.localID name:contact.name phone:contact.phoneArray];
    
    [contact release];
    
    
    for (int i = 1; i < 20; i ++) {
        ContactPeople *contact = [[ContactPeople alloc] init];
        contact.localID = [NSNumber numberWithInt:i];
        contact.name = [NSString stringWithFormat:@"测试%d",i];
        [[SearchCoreManager share] AddContact:contact.localID name:contact.name phone:contact.phoneArray];
        [self.contactDic setObject:contact forKey:contact.localID];
        [contact release];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44;
}
- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.searchBar.text length] <= 0) {
        return [self.contactDic count];
    } else {
        return [self.searchByName count] + [self.searchByPhone count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell*)[_tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:indentifier] autorelease];
		cell.selectionStyle=UITableViewCellSelectionStyleBlue;
	}
   
    if ([self.searchBar.text length] <= 0) {
        ContactPeople *contact = [[self.contactDic allValues] objectAtIndex:indexPath.row];
        cell.textLabel.text = contact.name;
        cell.detailTextLabel.text = @"";
        return cell;
    }
    
    NSNumber *localID = nil;
    NSMutableString *matchString = [NSMutableString string];
    NSMutableArray *matchPos = [NSMutableArray array];
    if (indexPath.row < [searchByName count]) {
        localID = [self.searchByName objectAtIndex:indexPath.row];
        
        //姓名匹配 获取对应匹配的拼音串 及高亮位置
        if ([self.searchBar.text length]) {
            [[SearchCoreManager share] GetPinYin:localID pinYin:matchString matchPos:matchPos];
        }
    } else {
        localID = [self.searchByPhone objectAtIndex:indexPath.row-[searchByName count]];
        NSMutableArray *matchPhones = [NSMutableArray array];
        
        //号码匹配 获取对应匹配的号码串 及高亮位置
        if ([self.searchBar.text length]) {
            [[SearchCoreManager share] GetPhoneNum:localID phone:matchPhones matchPos:matchPos];
            [matchString appendString:[matchPhones objectAtIndex:0]];
        }
    }
    ContactPeople *contact = [self.contactDic objectForKey:localID];

    cell.textLabel.text = contact.name;
    cell.detailTextLabel.text = matchString;

    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    [[SearchCoreManager share] Search:searchText searchArray:nil nameMatch:searchByName phoneMatch:self.searchByPhone];
    
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
