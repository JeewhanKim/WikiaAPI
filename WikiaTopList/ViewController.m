//
//  WikiaTableViewController.m
//  WikiaTopList
//
//  Created by Jeewhan on 4/20/15.
//  Copyright (c) 2015 MichaelKim. All rights reserved.
//

#import "ViewController.h"
#import "WikiaTableViewCell.h"
#import "UIImageView+WebCache.h"

#define viewWidth self.view.frame.size.width
#define viewHeight self.view.frame.size.height
#define fontNormal16 [UIFont fontWithName:@"HelveticaNeue" size:16]
#define fontLight12 [UIFont fontWithName:@"HelveticaNeue-Light" size:12]
#define fontLight14 [UIFont fontWithName:@"HelveticaNeue-Light" size:14]
#define fontLight16 [UIFont fontWithName:@"HelveticaNeue-Light" size:16]
#define fontLight20 [UIFont fontWithName:@"HelveticaNeue-Light" size:20]
#define fontLight26 [UIFont fontWithName:@"HelveticaNeue-Light" size:26]

@interface ViewController ()
{
    int             _currentPage;
    BOOL            _animated;
    
    // API request & return data models
    NSString        *_requestString;
    NSData          *_responseData;
    NSDictionary    *_dictionary;
    NSMutableArray  *_responseArray;
    
    // Main UI
    UIImageView     *_backgroundImage;
    UITableView     *_tableView;
    UILabel         *_headerLabel;
    UILabel         *_loadingLabel;
    UIButton        *_reloadButton;
    
    // Detail View
    UIScrollView    *_detailScrollView;
    UIImageView     *_detailThumbnail;
    UILabel         *_detailTitle;
    UILabel         *_detailUrl;
    UITextView      *_detailDescription;
    UIButton        *_detailCloseButton;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentPage = 1;
    _animated = NO;
    _responseArray = [[NSMutableArray alloc] init];

    [self initFrames];
    [self initViews];
    [self apiRequest:_currentPage];
}

- (void)initFrames
{
    // Main UI
    self.view.backgroundColor = [UIColor blackColor];
    _backgroundImage = [[UIImageView alloc] init];
    _backgroundImage.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    _backgroundImage.image = [UIImage imageNamed:@"wikia_bg_01"];
    _backgroundImage.alpha = 0.0f;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 60, viewWidth-20, viewHeight-130) style:UITableViewStylePlain];
    _tableView.alpha = 0;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    
    _headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 60)];
    _headerLabel.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.50];
    _headerLabel.textColor = [UIColor whiteColor];
    _headerLabel.text = @"TOP WIKIS";
    _headerLabel.font = fontLight20;
    _headerLabel.textAlignment = NSTextAlignmentCenter;
    
    _loadingLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    _loadingLabel.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.50];
    _loadingLabel.textColor = [UIColor whiteColor];
    _loadingLabel.text = @"LOADING ...";
    _loadingLabel.font = fontLight26;
    _loadingLabel.textAlignment = NSTextAlignmentCenter;
    
    _reloadButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 60, viewWidth, 60)];
    _reloadButton.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:172.0/255.0 blue:238.0/255.0 alpha:1.00];
    _reloadButton.titleLabel.textColor = [UIColor whiteColor];
    _reloadButton.titleLabel.font = fontNormal16;
    _reloadButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_reloadButton setTitle:@"LOAD 10 MORE" forState:UIControlStateNormal];
    [_reloadButton addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
    _reloadButton.alpha = 0;
    
    // Detail UI
    _detailScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, viewWidth, self.view.bounds.size.height-60)];

    _detailThumbnail = [[UIImageView alloc] initWithFrame:CGRectMake((viewWidth - 250) / 2, 50, 250, 65)];
    
    _detailTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, viewWidth, 30)];
    _detailTitle.textColor = [UIColor whiteColor];
    _detailTitle.text = @"Detail Title";
    _detailTitle.font = fontLight16;
    _detailTitle.textAlignment = NSTextAlignmentCenter;
    
    _detailUrl = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, viewWidth, 20)];
    _detailUrl.textColor = [UIColor yellowColor];
    _detailUrl.text = @"Detail Url";
    _detailUrl.font = fontLight12;
    _detailUrl.textAlignment = NSTextAlignmentCenter;
    
    _detailDescription = [[UITextView alloc] initWithFrame:CGRectMake((viewWidth - 250) / 2, 200, 250, viewHeight-270)];
    _detailDescription.backgroundColor = [UIColor clearColor];
    _detailDescription.text = @"testetsttest";
    _detailDescription.font = fontLight14;
    _detailDescription.textColor = [UIColor whiteColor];
    _detailDescription.editable = NO;
    _detailDescription.scrollEnabled = YES;
    _detailDescription.userInteractionEnabled = YES;
    
    _detailCloseButton = [[UIButton alloc] initWithFrame:CGRectMake(viewWidth - 80, 16, 80, 16)];
    [_detailCloseButton setTitle:@"CLOSE" forState:UIControlStateNormal];
    [_detailCloseButton addTarget:self action:@selector(closeDetailView) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initViews
{
    [self.view addSubview:_backgroundImage];
    [self.view addSubview:_tableView];
    [self.view addSubview:_headerLabel];
    [self.view addSubview:_reloadButton];
    [self.view addSubview:_loadingLabel];
    [self.view addSubview:_detailScrollView];
    
    // Blur Effect
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *bluredEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [bluredEffectView setFrame:_detailScrollView.bounds];
    [_detailScrollView addSubview:bluredEffectView];
    
    [_detailScrollView addSubview:_detailThumbnail];
    [_detailScrollView addSubview:_detailTitle];
    [_detailScrollView addSubview:_detailUrl];
    [_detailScrollView addSubview:_detailDescription];
    [_detailScrollView addSubview:_detailCloseButton];
    
    _animated = YES;
    
    [UIView
     animateWithDuration:1.25
     delay:0.25
     options:UIViewAnimationOptionCurveEaseOut
     animations:^{
         _loadingLabel.alpha = 0.0f;
         _reloadButton.alpha = 1.0f;
     } completion:^(BOOL finished)
     {
         [UIView
          animateWithDuration:1.5
          delay:0.2
          options:UIViewAnimationOptionCurveEaseOut
          animations:^{
              _backgroundImage.alpha = 1.0f;
              _tableView.alpha = 0.85f;
          } completion:^(BOOL finished)
          {
              _animated = NO;
          }];
     }];
}

- (void)loadMore
{
    if(_animated) return;
    _animated = YES;
    
    [UIView
     animateWithDuration:0.25
     delay:0
     options:UIViewAnimationOptionCurveEaseOut
     animations:^{
         _loadingLabel.alpha = 1.0f;
         _reloadButton.alpha = 0;
         _tableView.alpha = 0.5f;
     } completion:^(BOOL finished)
     {
         _currentPage += 1;
         [self apiRequest:_currentPage];
     }];
}

- (void)ErrorHandling
{
    _reloadButton.userInteractionEnabled = NO;
    
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error"
                                                     message:@"Failed to connect to the server. Please try it again."
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles: nil];
    [alert show];
}

- (void)apiRequest:(int)page
{
    
    
    // Step 1. Get List
    _requestString = [NSString stringWithFormat:@"http://www.wikia.com/wikia.php?controller=WikisApi&method=getList&lang=en&limit=10&batch=%d", page];
    _responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_requestString]];
    
    if(!_responseData) {
        [self ErrorHandling];
        return;
    }
    
    NSError *error = nil;
    id jsonObjects = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingMutableContainers error:&error];
    
    if (!jsonObjects) {
        [self ErrorHandling];
        return;
    }

    NSArray *itemArray = jsonObjects[@"items"];
    NSString *idStrings = @"";
    
    for (NSDictionary *item in itemArray) {
        NSString *wikiId = [item objectForKey:@"id"];
        if([idStrings isEqualToString:@""]) {
            idStrings = [NSString stringWithFormat:@"%@", wikiId];
        } else {
            idStrings = [NSString stringWithFormat:@"%@,%@", idStrings, wikiId];
        }
    }

    // Step 2. Get Details from Ids
    _requestString = [NSString stringWithFormat:@"http://www.wikia.com/wikia.php?controller=WikisApi&method=getDetails&ids=%@", idStrings];
    _responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_requestString]];
    
    if(!_responseData) {
        [self ErrorHandling];
        return;
    }
    
    jsonObjects = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingMutableContainers error:&error];
    
    if (!jsonObjects) {
        [self ErrorHandling];
        return;
    }
    
    NSArray *itemIds = [idStrings componentsSeparatedByString:@","];
    
    // Step 3. Parse data & Store to the NSDictionary
    for (NSString *itemId in itemIds) {
        NSDictionary *item = jsonObjects[@"items"][itemId];
       
        NSString *wikiTitle =       [item objectForKey:@"title"];
        NSString *wikiThumbnail =   [item objectForKey:@"wordmark"];
        NSString *wikiUrl =         [item objectForKey:@"url"];
        NSString *wikiDescription = [item objectForKey:@"desc"];
    
        _dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                       wikiTitle, @"title",
                       wikiThumbnail, @"thumbnail",
                       wikiUrl, @"url",
                       wikiDescription, @"desc",
                       nil];
        if(page <= 25) [_responseArray addObject:_dictionary];
    }

    if(page > 1) [_tableView reloadData];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    [UIView
     animateWithDuration:0.25
     delay:0
     options:UIViewAnimationOptionCurveEaseOut
     animations:^{
         _loadingLabel.alpha = 0.0f;
         _reloadButton.alpha = 1.0f;
         _tableView.alpha = 1.0f;
     } completion:^(BOOL finished)
     {
         _animated = NO;
     }];
    
    return _responseArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TopWikiCell";

    WikiaTableViewCell *cell = (WikiaTableViewCell *)[theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[WikiaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    NSDictionary *tmpDictionary = [_responseArray objectAtIndex:indexPath.row];
    NSMutableString *titleText, *thumbnailText, *urlText;
    
    titleText = [NSMutableString stringWithFormat:@"%@", [tmpDictionary objectForKeyedSubscript:@"title"]];
    urlText = [NSMutableString stringWithFormat:@"%@", [tmpDictionary objectForKeyedSubscript:@"url"]];
    thumbnailText = [NSMutableString stringWithFormat:@"%@", [tmpDictionary objectForKeyedSubscript:@"thumbnail"]];
    
    cell.wikiTitle.text = titleText;
    cell.wikiUrl.text = urlText;
    [cell.wikiImage sd_setImageWithURL:[NSURL URLWithString:thumbnailText] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
 
    return cell;
}

- (void)closeDetailView
{
    if(_animated) return;
    _animated = YES;
    
    [UIView
     animateWithDuration:0.35
     delay:0.0
     options:UIViewAnimationOptionCurveEaseOut
     animations:^{
         _detailScrollView.frame = CGRectMake(0, self.view.bounds.size.height, viewWidth, self.view.bounds.size.height-60);
     } completion:^(BOOL finished)
     {
         _animated = NO;
     }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_animated) return;
    _animated = YES;
    
    NSDictionary *tmpDictionary = _responseArray[indexPath.row];

    _detailTitle.text = [tmpDictionary objectForKeyedSubscript:@"title"];
    _detailUrl.text = [tmpDictionary objectForKeyedSubscript:@"url"];
    _detailDescription.text = [tmpDictionary objectForKeyedSubscript:@"desc"];
    
    [_detailThumbnail sd_setImageWithURL:[NSURL URLWithString:[tmpDictionary objectForKeyedSubscript:@"thumbnail"]]
                      placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    [UIView
     animateWithDuration:0.35
     delay:0.0
     options:UIViewAnimationOptionCurveEaseOut
     animations:^{
         _detailScrollView.frame = CGRectMake(0, 60, viewWidth, self.view.bounds.size.height-60);
     } completion:^(BOOL finished)
     {
         _animated = NO;
     }];
}

#pragma mark - Table view data source
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - NSURLConnection Delegate
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    [self ErrorHandling];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
