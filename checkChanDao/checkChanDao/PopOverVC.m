//
//  PopOverVC.m
//  checkChanDao
//
//  Created by LLZ on 2018/1/23.
//  Copyright © 2018年 LLZ. All rights reserved.
//

#import "PopOverVC.h"
#import "Controller.h"
#import "LoginVC.h"

@interface PopOverVC ()<NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSTextField *userTF;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSButton *loginBtn;

@property (nonatomic, strong) NSImageView *emptyView;
@end

@implementation PopOverVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [[Controller shareController].viewModel addObserver:self forKeyPath:NSStringFromSelector(@selector(bugs)) options:NSKeyValueObservingOptionNew context:nil];
    [[Controller shareController].viewModel addObserver:self forKeyPath:NSStringFromSelector(@selector(user)) options:NSKeyValueObservingOptionNew context:nil];
    [[Controller shareController].viewModel addObserver:self forKeyPath:NSStringFromSelector(@selector(isLogin)) options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    [[Controller shareController] checkChanDao];
}

- (IBAction)logoutAction:(NSButton *)sender {
    if ([Controller shareController].viewModel.user.length > 0) {
        [[Controller shareController] logout];
        [[Controller shareController] checkChanDao];
    } else {//去登陆
        LoginVC *vc = [LoginVC new];
        [self presentViewControllerAsModalWindow:vc];
    }
}
- (IBAction)quitAction:(NSButton *)sender {
    [[NSApplication sharedApplication] terminate:self];
//    [[Controller shareController] sendNotice];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"当前线程：%@",[NSThread currentThread]);
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(bugs))]) {
        if ([Controller shareController].viewModel.bugs.count == 0) {
            [self.view addSubview:self.emptyView];
        } else {
            [self.emptyView removeFromSuperview];
        }
        [self.tableView reloadData];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(user))]) {
        if ([Controller shareController].viewModel.user.length > 0) {
            NSString *userString = [NSString stringWithFormat:@"当前登录账号：%@", [Controller shareController].viewModel.user];
            [self.userTF setStringValue:userString];
        } else {
            [self.userTF setStringValue:@"未登录"];
        }
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(isLogin))]) {
        if ([Controller shareController].viewModel.isLogin) {
            [self.loginBtn setTitle:@"退出登录"];
        } else {
            [self.loginBtn setTitle:@"去登录"];
        }
    }
}

- (NSImageView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [NSImageView imageViewWithImage:[NSImage imageNamed:@"empty"]];
        CGRect rect = CGRectMake(self.view.bounds.size.width / 4, self.view.bounds.size.height / 4, self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
        _emptyView.frame = rect;
    }
    return _emptyView;
}

- (void)dealloc
{
    [[Controller shareController].viewModel removeObserver:self forKeyPath:NSStringFromSelector(@selector(bugs))];
    [[Controller shareController].viewModel removeObserver:self forKeyPath:NSStringFromSelector(@selector(user))];
    [[Controller shareController].viewModel removeObserver:self forKeyPath:NSStringFromSelector(@selector(isLogin))];
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [Controller shareController].viewModel.bugs.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSInteger index = 0;
    if ([Controller shareController].viewModel.bugs.count > row) {
        index = row;
    } else {
        index = [Controller shareController].viewModel.bugs.count;
    }
    bugModel *bug = [Controller shareController].viewModel.bugs[index];
    NSString *strIdt = [tableColumn identifier];
    NSTableCellView *cell = [tableView makeViewWithIdentifier:strIdt owner:self];
    cell.textField.stringValue = [bug valueForKey:strIdt];
 
    return cell;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    NSInteger index = 0;
    if ([Controller shareController].viewModel.bugs.count > row) {
        index = row;
    } else {
        index = [Controller shareController].viewModel.bugs.count;
    }
    bugModel *bug = [Controller shareController].viewModel.bugs[index];
    [[Controller shareController] openChanDaoWithID:bug.bugID];
    return YES;
}



@end
