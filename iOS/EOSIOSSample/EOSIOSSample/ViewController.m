//
//  ViewController.m
//  TestFramework
//
//  Created by Satish Kumar Jakkula on 11/13/18.
//  Copyright © 2018 Prarysoft. All rights reserved.
//

#import "ViewController.h"
#import <EOSIOS/EOSIOS.h>
#import <EOSIOS/EOSAction.h>

#define DEFAULT_WALLET_NAME @"WALLET_NAME"
#define DEFAULT_WALLET_PRIVATE_KEY @"YOUR_PRIVATE_KEY"

@interface ViewController ()
{
    
}

@property (nonatomic, strong)   EOSIOS  *eosios;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _eosios = [[EOSIOS alloc] initWithRPCChainURL:@"http://127.0.0.1:8888" andWalletURL:@"http://192.168.0.108"];
    _eosios.delegate = self;
    [self getAccountDetails];
    //[self getTableRows];
    //[self pushTransaction];
}

- (void)getAccountDetails
{
    EOSAction *action = [[EOSAction alloc] init];
    action.action_wallet_name = DEFAULT_WALLET_NAME;
    action.action_wallet_private_key = DEFAULT_WALLET_PRIVATE_KEY;
    action.url_endpoint_key = @"get_currency_balance";
    action.args = @"\"code\" : \"eosio.token\", \"account\" : \"satish\", \"symbol\" : \"SYS\"";
    [_eosios getAccountDetails:action];
}

- (void)getTableRows
{
    EOSAction *_currentActionObject = [[EOSAction alloc] init];
    _currentActionObject.url_endpoint_key = @"get_table_rows";
    _currentActionObject.args = [NSString stringWithFormat:@"\"scope\" : \"%@\", \"code\" : \"%@\", \"table\" : \"%@\", \"json\" : true", @"cogneos", @"cogneos", @"studentstb"];
    //    if (![Utility isEmptyString:object.lowerBound] || ![Utility isEmptyString:object.upperBound])
    //    {
    //        _currentActionObject.args = [NSString stringWithFormat:@"%@, \"index_position\" : %@, \"key_type\" : \"%@\"", _currentActionObject.args, object.indexId, object.indexType];
    //        if (![Utility isEmptyString:object.lowerBound])
    //        {
    //            _currentActionObject.args = [NSString stringWithFormat:@"%@, \"lower_bound\" : %@", _currentActionObject.args, object.lowerBound];
    //        }
    //        if (![Utility isEmptyString:object.upperBound])
    //        {
    //            _currentActionObject.args = [NSString stringWithFormat:@"%@, \"upper_bound\" : %@", _currentActionObject.args, object.upperBound];
    //        }
    //    }
    _currentActionObject.action_wallet_name = DEFAULT_WALLET_NAME;
    _currentActionObject.action_wallet_private_key = DEFAULT_WALLET_PRIVATE_KEY;
    [_eosios getTableRows:_currentActionObject];
}

- (void)pushTransaction
{
    EOSAction *addRewardAction = [[EOSAction alloc] init];
    addRewardAction.account = @"cogneos";
    addRewardAction.auth_userid = @"cogneos";
    addRewardAction.scope = @"active";
    
    addRewardAction.action = @"addcourse";
    addRewardAction.args = @"\"user\" : \"cogneos\", \"teacher_id\" : 0, \"course_name\" : \"EOS Smart Contract Developement\", \"course_desc\" : \"EOS Smart Contract Developement\", \"duration\" : 60, \"reward\" : 15";
    addRewardAction.action_wallet_name = DEFAULT_WALLET_NAME;
    addRewardAction.action_wallet_private_key = DEFAULT_WALLET_PRIVATE_KEY;
    [_eosios initiateTransaction:[NSArray arrayWithObjects:addRewardAction, nil]];
}

#pragma mark - Get Account Details

- (void)getAccountDetailsResponse:(NSArray *)data request:(EOSAction *)eosAction
{
    NSLog(@"Data %@", data);
}

- (void)getAccountDetailsFailed:(NSString *)error
{
    NSLog(@"Error %@", error);
}

#pragma mark - Get table Rows


- (void)getTableRowsResponse:(NSArray *)data request:(EOSAction *)eosAction
{
    NSLog(@"getTableRowsResponse %@", data);
}

- (void)getTableRowsFailed:(NSString *)error
{
    NSLog(@"Error %@", error);
}

#pragma mark - Push Transaction

- (void)pushTransactionResponse:(NSDictionary *)data request:(NSArray *)eosActions
{
    NSLog(@"pushTransactionResponse %@", data);
}


- (void)pushTransactionFailed:(NSString *)error
{
    NSLog(@"Error %@", error);
}
@end
