//
//  PopOverVC.m
//  checkChanDao
//
//  Created by LLZ on 2018/1/23.
//  Copyright © 2018年 LLZ. All rights reserved.
//

#import "PopOverVC.h"
#import "AppDelegate.h"
#import "LoginVC.h"

@interface PopOverVC ()<NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSView *emptyView;

@property (nonatomic, weak) AppDelegate *delegate;
@end

@implementation PopOverVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.emptyView.frame = self.view.bounds;
    self.delegate = [NSApplication sharedApplication].delegate;
    [self.delegate.controller addObserver:self forKeyPath:NSStringFromSelector(@selector(bugs)) options:NSKeyValueObservingOptionNew| NSKeyValueObservingOptionOld context:nil];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    [self.delegate.controller checkChanDao];
}

- (IBAction)toLoginAction:(NSButton *)sender {
    LoginVC *vc = [LoginVC new];
    [self presentViewControllerAsModalWindow:vc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"当前线程：%@",[NSThread currentThread]);
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(bugs))]) {
        if (self.delegate.controller.bugs.count == 0) {
            [self.view addSubview:self.emptyView];
        } else {
            [self.emptyView removeFromSuperview];
        }
        [self.tableView reloadData];
    }
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.delegate.controller.bugs.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSInteger index = 0;
    if (self.delegate.controller.bugs.count > row) {
        index = row;
    } else {
        index = self.delegate.controller.bugs.count;
    }
    bugModel *bug = self.delegate.controller.bugs[index];
    NSString *strIdt = [tableColumn identifier];
    NSTableCellView *cell = [tableView makeViewWithIdentifier:strIdt owner:self];
    cell.textField.stringValue = [bug valueForKey:strIdt];
 
    return cell;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    NSInteger index = 0;
    if (self.delegate.controller.bugs.count > row) {
        index = row;
    } else {
        index = self.delegate.controller.bugs.count;
    }
    bugModel *bug = self.delegate.controller.bugs[index];
    [self.delegate.controller openChanDaoWithID:bug.bugID];
    return YES;
}



@end
