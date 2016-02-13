//
//  CollectionViewController.m
//  Food Swipe
//
//  Created by JS-K on 1/23/16.
//  Copyright © 2016 JS-K. All rights reserved.
//

#import "CategoryViewController.h"
#import "AppDelegate.h"
#import "Restaurant.h"
#import "CategoryCell.h"
#import <AFNetworking/AFNetworking.h>
#import "RestaurantDetailViewController.h"
#import "GluttonNavigationController.h"

// progress
#import <MBProgressHUD/MBProgressHUD.h>
// yelp Data get
#import "YelpYapper.h"
// Filter option setup
#import "FilterTableVC.h"
// Select Dishi
#import "SelDishiViewController.h"
//NSMutableDictionary *searchOptions;
NSMutableDictionary *searchOptions;

@interface CategoryViewController () <UIViewControllerPreviewingDelegate>

@property (strong, nonatomic) NSMutableArray *restaurantsToRate;
@property (strong, nonatomic) NSMutableArray *restaurantsRated;

//restaurantVC
@property (strong, nonatomic) UIButton *filterButton;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) FilterTableVC *filterController;

@property (strong, nonatomic) SelDishiViewController *selDishiViewController;


// get Category
@property (strong, nonatomic) NSString *defaultZipCode;
@property (strong, nonatomic) NSMutableArray *categorys;
@property (strong, nonatomic) NSMutableDictionary *category_Dic;
@property (strong, nonatomic) NSMutableDictionary *categoryImage_Dic;
@property (strong, nonatomic) NSArray *orderedKeys;
@property (strong, nonatomic) MBProgressHUD *loader;
@property (strong, nonatomic) NSMutableArray *restaurants;

// get location Info
@property (nonatomic) CLLocationCoordinate2D currentLocation;

@end

@implementation CategoryViewController

static NSString * const reuseIdentifier = @"cell";
static int restaurantsCnt = 0;
static int iMaxCount = 550;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getLocationInfo];
    
    // Do any additional setup after loading the view.
    self.restaurantsRated = [[NSMutableArray alloc] init];
    [self registerForPreviewingWithDelegate:(id)self sourceView:self.collectionView];
    

    if ([[searchOptions objectForKey:@"IsSearch"] isEqualToString:@"1"]) { // Run Search from FilterTableCV
        [self RunSearch];
        [searchOptions setObject:@"0" forKey:@"IsSearch"];
    }else{
        // get default categorys
        _category_Dic = [[NSMutableDictionary alloc]init];
        _categoryImage_Dic = [[NSMutableDictionary alloc]init];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (![self.category_Dic isEqualToDictionary:[defaults objectForKey:@"default_categorys"]]) {
            
            self.category_Dic = [[defaults objectForKey:@"default_categorys"] mutableCopy];
            self.categoryImage_Dic = [[defaults objectForKey:@"default_categorysIamge"] mutableCopy];
            // ordering keys
            [self sortCategories];
            [self.collectionView reloadData];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  //  [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];
    
    

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.category_Dic count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
//    NSDictionary *restaurant = [self.restaurantsToRate objectAtIndex:indexPath.row];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sample.jpg"]];
   
    //   Configure the cell
    //  image loading
    [cell.picLoading setHidesWhenStopped:YES];
    [cell.picLoading startAnimating];
    
    
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 5.0;
    cell.imageView.clipsToBounds = YES;
    
    cell.layer.masksToBounds = YES;
//    cell.layer.cornerRadius = 5.0;
//    cell.layer.shadowRadius = 5.0;
//    cell.layer.shadowOffset = CGSizeMake(4, 4);
//    cell.layer.shadowColor = [[UIColor blackColor] CGColor];
//    cell.layer.shadowRadius = 2.0f;
//    cell.layer.shadowOpacity = 0.60f;
//    cell.layer.shadowPath = [[UIBezierPath bezierPathWithRect:cell.imageView.layer.bounds] CGPath];
    
    cell.layer.cornerRadius = 5.0;
    cell.backgroundColor = [UIColor clearColor];
    cell.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.layer.shadowOffset = CGSizeMake(0,0);
    cell.layer.shadowOpacity = 0.30f;
    cell.layer.shadowRadius = 10.0;
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds cornerRadius:30.0].CGPath;
    
   
    //cell.imageView.layer.backgroundColor = [UIColor colorWithRed:0.0 green:192.0/255.0 blue:1.0 alpha:1.0].CGColor;
    //cell.imageView.layer.borderWidth = 2.0;
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[_categoryImage_Dic objectForKey:_orderedKeys[indexPath.row]] stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"o.jpg"]]]];
    [requestOperation setResponseSerializer:[AFImageResponseSerializer serializer]];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [cell.picLoading stopAnimating];
        cell.imageView.image = responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [cell.picLoading stopAnimating];
        cell.imageView.image = [UIImage imageNamed:@"sample"];
    }];
    [requestOperation start];
    
   // cell.imageView.image = [UIImage imageNamed:@"sample"];
    cell.categoryNameLabel.text = [_category_Dic objectForKey:_orderedKeys[indexPath.row]];
    [cell.contentView sendSubviewToBack:cell.imageView];
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //    NSInteger _numberOfCells = NUMBEROFCELLS;
    //    NSInteger viewWidth = COLLECTIONVIEW_WIDTH;
    //    NSInteger totalCellWidth = CELL_WIDTH * _numberOfCells;
    //    NSInteger totalSpacingWidth = CELL_SPACING * (_numberOfCells -1);
    //
    //    NSInteger leftInset = (viewWidth - (totalCellWidth + totalSpacingWidth)) / 2;
    //    NSInteger rightInset = leftInset;
    
    //return UIEdgeInsetsMake(0, leftInset, 0, rightInset);
    return UIEdgeInsetsMake(13, 15, 13, 15);
}


- (NSMutableArray *)restaurantsToRate {
    return _restaurantsToRate ?: [[NSMutableArray alloc] init];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"restaurantSwipeView"]) {
////        RestaurantDetailViewController *detail = (RestaurantDetailViewController *)segue.destinationViewController;
////        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
////        [detail setRestaurant:[Restaurant deserialize:[self.restaurantsToRate objectAtIndex:indexPath.row]]];
////        [detail setSegueIdentifierUsed:segue.identifier];
//        
//    }
//}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[_category_Dic objectForKey:_orderedKeys[indexPath.row]] forKey:@"categoryTitle"];
    [defaults setObject:_orderedKeys[indexPath.row] forKey:@"categoryKey"];
//    self.tabBarController.tabBar.items;
    [defaults setObject:@"1" forKey:@"from_category"];
    [self.tabBarController setSelectedIndex:1];
    return YES;
}


- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    if ([self.presentedViewController isKindOfClass:[RestaurantDetailViewController class]]) {
        return nil;
    }
    if (CGRectContainsPoint([self.view convertRect:self.collectionView.frame fromView:self.collectionView.superview], location)) {
        CGPoint locationInTableview = [self.collectionView convertPoint:location fromView:self.view];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:locationInTableview];
        if (indexPath) {
            UICollectionViewLayoutAttributes *cellAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
            [previewingContext setSourceRect:cellAttributes.frame];
            RestaurantDetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"restaurantDetail"];
            [detail setRestaurant:[Restaurant deserialize:[self.restaurantsToRate objectAtIndex:indexPath.row]]];
            return detail;
        }
    }
    
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    RestaurantDetailViewController *detail = (RestaurantDetailViewController *)viewControllerToCommit;
    [detail setSegueIdentifierUsed:@"other"];
    
    [self showViewController:detail sender:self];
}



// Setup restaurant
//
//- (void)setupFilterButton:(NSString *)buttonTitle {
//    self.filterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
//   // [self.filterButton setBackgroundColor:[UIColor redColor]];
//    [self.filterButton.layer setBorderWidth:1.5f];
//    [self.filterButton.layer setBorderColor:[UIColor brownColor].CGColor];
//    [self.filterButton setTitle:buttonTitle forState:UIControlStateNormal];
//    [self.filterButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.filterButton addTarget:self action:@selector(filterButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    NSString *strDishi = [defaults objectForKey:@"sel_dishi"];
//    if (!strDishi) {
//        strDishi = @"Dishi";
//    }
//    
//    self.dishiButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
//    // [self.filterButton setBackgroundColor:[UIColor redColor]];
//    [self.dishiButton.layer setBorderWidth:1.5f];
//    [self.dishiButton.layer setBorderColor:[UIColor brownColor].CGColor];
//    [self.dishiButton setTitle:strDishi forState:UIControlStateNormal];
//    [self.dishiButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.dishiButton addTarget:self action:@selector(DishiButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    
//}
//
//- (void)setupSearchBar {
//    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(100.0f, 10.0f, 100.0f, 15.0f)];
//    [self.searchBar setPlaceholder:[[NSString alloc] initWithFormat:@"Zip code %@", self.defaultZipCode]];
//    self.searchBar.delegate = self;
//    self.searchBar.showsCancelButton = YES;
//    //self.searchBar.keyboardType = UIKeyboardTypeNumberPad;
//    self.searchBar.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
//    UIBarButtonItem *filterBarRight = [[UIBarButtonItem alloc] initWithCustomView:self.filterButton];
//    
//    [self.navigationItem setTitleView:self.searchBar];
//    [self.navigationItem setRightBarButtonItem:filterBarRight];
//    
//    UIBarButtonItem *filterBarLeft = [[UIBarButtonItem alloc] initWithCustomView:self.dishiButton];
//    
//    [self.navigationItem setTitleView:self.searchBar];
//    [self.navigationItem setLeftBarButtonItem:filterBarLeft];
//    
//    //    [self.navigationController.navigationBar setBackgroundColor:[UIColor redColor]];
//    //    [self.navigationController.navigationBar setTintColor:[UIColor redColor]];
//    //[self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
//    [self.navigationController.navigationBar setTranslucent:NO];
//    [self.navigationController.navigationBar setAlpha:1.0f];
//    
//    
//    
//    //    self.myNavigationBarItem.titleView = searchBar;
//    //    UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
//    //    self.navigationBarItem.rightBarButtonItem = searchBarItem;
//    //    self.myNavigationBarItem.leftBarButtonItem = filterBarItem;
//    
//    //    [self.navigationController setToolbarHidden:YES];
//}

//- (void)setupFilterView {
//    self.filterController = [[FilterTableVC alloc] initWithNibName:@"FilterTableVC" bundle:nil];
//    
//}
//
//- (void)filterButtonAction {
//    if(!self.filterController)
//        NSLog(@"filter is nil");
//    [self.navigationController pushViewController: self.filterController animated:YES];
//}
//
//- (void)setupDishiView {
//    
//    _selDishiViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"selDishiViewController"];
//}
//
//- (void)DishiButtonAction {
////    if(!self.selDishiVC)
////        NSLog(@"Select Dishi is nil");
//    
//    if (!self.selDishiViewController) {
//        NSLog(@"Select Dishi ViewController is nil");
//    }
//    [self.navigationController pushViewController: self.selDishiViewController animated:YES];
//    
//}


//- (void)setupSearchOptions {
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//
//    searchOptions = [[defaults objectForKey:@"searchOption"] mutableCopy]; // read searchOption
//    if (searchOptions == nil) {
//        searchOptions = [[NSMutableDictionary alloc] init];
//        NSNumber *match = [[NSNumber alloc] initWithLong:0]; //BestMatch
//        [searchOptions setObject:match forKey:@"sort"];
//        NSNumber *num = [[NSNumber alloc] initWithDouble:3]; //3 mile
//        [searchOptions setObject:num forKey:@"distance"];
//        //    NSMutableArray *category = [[NSMutableArray alloc] initWithObjects:@"thai", nil];
//        //    [searchOptions setObject:category forKey:@"category"];
//    }
//     NSString *strLocation = [[NSString alloc]initWithFormat:@"%f,%f",_currentLocation.latitude, _currentLocation.longitude];
//    [searchOptions setObject:strLocation forKey: @"ll"];
//    [searchOptions setObject:@"0" forKey:@"IsSearch"];
//}


////#pragma mark - UISearchBar delegate
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    [searchBar resignFirstResponder];
//    [self.searchBar setPlaceholder:@"Zip code"];
//   
//    NSLog(@"Calcel Button Clicked");
//}
//-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
//    NSLog(@"TextDidEndEditing");
//}
//
//-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
//    NSLog(@"TextDidBeginEditing");
//    //reset the search bar
////    searchBar.text = self.defaultZipCode;
//}
//
//-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    [searchBar resignFirstResponder];
//    if (![self.defaultZipCode isEqualToString:searchBar.text]) {
//         self.defaultZipCode = searchBar.text;
//        [self RunSearch];
//    }
//}

// Search request
- (void)sendRequest {
    //    // self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    //    if (self) {
    //        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
    //        //default search keyword
    //        [self.client searchWithTerm:@"Thai" success:^(AFHTTPRequestOperation *operation, id response) {
    //            NSLog(@"success");
    //            [self setupData:response];
    //        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //            NSLog(@"error: %@", [error description]);
    //        }];
    //    }
}

- (void)sendRequest:(NSMutableDictionary *)filter {
    //    if (self) {
    //        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
    //        //default search keyword
    //        [self.client searchWithDict:filter success:^(AFHTTPRequestOperation *operation, id response) {
    //            NSLog(@"success");
    //            [self setupData:response];
    //        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //            NSLog(@"error: %@", [error description]);
    //        }];
    //    }
}
- (void)sendSearchRequest:(NSString *)keyWord {
    //    if (self) {
    //        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
    //
    //        [self.client searchWithTerm:keyWord success:^(AFHTTPRequestOperation *operation, id response) {
    //            NSLog(@"success");
    //            [self setupData:response];
    //        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //            NSLog(@"error: %@", [error description]);
    //        }];
    //    }
}


// get Categories Data

- (void)getBusinesses_for_getCategory {
    
    // loader start
    self.loader = [MBProgressHUD showHUDAddedTo:self.navigationController.view  animated:YES];
    self.loader.labelText = @"Please wait a moment to gather data";
    self.loader.labelFont = [UIFont fontWithName:@"Bariol-Bold" size:[UIFont systemFontSize]];
    
    restaurantsCnt = 0;
    iMaxCount = 550;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [[manager HTTPRequestOperationWithRequest:[YelpYapper searchRequest_for_getCategory:self.defaultZipCode withOffset:0] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([[responseObject objectForKey:@"total"] unsignedLongValue] < iMaxCount) {
            iMaxCount = (int) [[responseObject objectForKey:@"total"] unsignedLongValue];
        }
        NSArray *cat_array = [[NSArray alloc] init];
        NSString *imageURL = [[NSString alloc]init];
         for(NSDictionary *r in [responseObject objectForKey:@"businesses"]) {
            restaurantsCnt++;
            cat_array = [r objectForKey:@"categories"];
             imageURL = [r objectForKey:@"image_url"];
            for (NSArray *cat_one in cat_array) {
                [_category_Dic setObject:cat_one[0] forKey:cat_one[1]];
                if ([_categoryImage_Dic objectForKey:@"image_url"] == nil && imageURL != nil) {
                    [_categoryImage_Dic setObject:imageURL forKey:cat_one[1]];
                }
                // select one only of categories
                break;
            }
        }
        
        if (iMaxCount > restaurantsCnt) {
            [self getRestOfBusinesses_for_getCategory:restaurantsCnt];
        }else{
            // save and display category
            [self save_and_display_Category];
            [self.loader hide:YES];
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [self save_and_display_Category];
        [self.loader hide:YES];
        //UIAlertView to let them know that something happened with the network connection...
    }] start];
}


- (void)getRestOfBusinesses_for_getCategory:(long)offset {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [[manager HTTPRequestOperationWithRequest:[YelpYapper searchRequest_for_getCategory:self.defaultZipCode withOffset:offset] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *cat_array = [[NSArray alloc] init];
        NSString *imageURL = [[NSString alloc]init];
        
        for(NSDictionary *r in [responseObject objectForKey:@"businesses"]) {
            restaurantsCnt++;
            cat_array = [r objectForKey:@"categories"];
            imageURL = [r objectForKey:@"image_url"];
            for (NSArray *cat_one in cat_array) {
                [_category_Dic setObject:cat_one[0] forKey:cat_one[1]];
                if ([_categoryImage_Dic objectForKey:@"image_url"] == nil && imageURL != nil) {
                    [_categoryImage_Dic setObject:imageURL forKey:cat_one[1]];
                }
                // select one only of categories
                break;
            }
        }
        
        if (iMaxCount > restaurantsCnt) {
            [self getRestOfBusinesses_for_getCategory:[self.restaurants count]];
        }
        else{
            // save and display category
            [self save_and_display_Category];
            [self.loader hide:YES];
        }
    

    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [self save_and_display_Category];
        [self.loader hide:YES];
        //UIAlertView to let them know that something happened with the network connection...
    }] start];
}

// get Categories Data

- (void)getBusinesses_for_getCategory_Location {
    
    // loader start
    self.loader = [MBProgressHUD showHUDAddedTo:self.navigationController.view  animated:YES];
    self.loader.labelText = @"Please wait a moment to gather data";
    self.loader.labelFont = [UIFont fontWithName:@"Bariol-Bold" size:[UIFont systemFontSize]];
    
    restaurantsCnt = 0;
    iMaxCount = 550;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [[manager HTTPRequestOperationWithRequest:[YelpYapper searchRequest_for_getCategory_location:self.currentLocation withOffset:0] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([[responseObject objectForKey:@"total"] unsignedLongValue] < iMaxCount) {
            iMaxCount = (int) [[responseObject objectForKey:@"total"] unsignedLongValue];
        }
        
        NSArray *cat_array = [[NSArray alloc] init];
        NSString *imageURL = [[NSString alloc]init];
        for(NSDictionary *r in [responseObject objectForKey:@"businesses"]) {
            restaurantsCnt++;
            cat_array = [r objectForKey:@"categories"];
            imageURL = [r objectForKey:@"image_url"];
            for (NSArray *cat_one in cat_array) {
                [_category_Dic setObject:cat_one[0] forKey:cat_one[1]];
                if ([_categoryImage_Dic objectForKey:@"image_url"] == nil && imageURL != nil) {
                    [_categoryImage_Dic setObject:imageURL forKey:cat_one[1]];
                }
                // select one only of categories
                break;
            }
        }
        
        if (iMaxCount > restaurantsCnt) {
            [self getRestOfBusinesses_for_getCategory:restaurantsCnt];
        }else{
            // save and display category
            [self save_and_display_Category];
        }
        
        [self.loader hide:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        
        [self save_and_display_Category];
        
        [self.loader hide:YES];
        
        //UIAlertView to let them know that something happened with the network connection...
    }] start];
}


- (void)getRestOfBusinesses_for_getCategory_Location:(long)offset {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [[manager HTTPRequestOperationWithRequest:[YelpYapper searchRequest_for_getCategory_location: self.currentLocation withOffset:offset] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *cat_array = [[NSArray alloc] init];
        NSString *imageURL = [[NSString alloc]init];
        
        for(NSDictionary *r in [responseObject objectForKey:@"businesses"]) {
            restaurantsCnt++;
            cat_array = [r objectForKey:@"categories"];
            imageURL = [r objectForKey:@"image_url"];
            for (NSArray *cat_one in cat_array) {
                [_category_Dic setObject:cat_one[0] forKey:cat_one[1]];
                if ([_categoryImage_Dic objectForKey:@"image_url"] == nil && imageURL != nil) {
                    [_categoryImage_Dic setObject:imageURL forKey:cat_one[1]];
                }
                // select one only of categories
                break;
            }
        }
        
        if (iMaxCount > restaurantsCnt) {
            [self getRestOfBusinesses_for_getCategory:[self.restaurants count]];
        }
        else{
            // save and display category
            [self save_and_display_Category];
            [self.loader hide:YES];
            
        }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [self save_and_display_Category];
        [self.loader hide:YES];
        //UIAlertView to let them know that something happened with the network connection...
    }] start];
}


-(void)save_and_display_Category{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:_category_Dic forKey:@"default_categorys"];
    [defaults setObject:_categoryImage_Dic forKey:@"default_categorysIamge"];
    [self sortCategories];
    [self.collectionView reloadData];
}
-(void)sortCategories{
    _orderedKeys = [_category_Dic keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2];
    }];
}

// get location info
-(void) getLocationInfo{
    self->locationManager = [[CLLocationManager alloc] init];
    self->locationManager.delegate = self;
    self->locationManager.distanceFilter = kCLDistanceFilterNone;
    self->locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self->locationManager startUpdatingLocation];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [self->locationManager requestWhenInUseAuthorization];
    }
    
    self.currentLocation = [self->locationManager location].coordinate;
    
    [self->locationManager stopUpdatingLocation];
    
}

-(void) RunSearch{
     // init _category_Dic
    if (_category_Dic == nil) {
        _category_Dic = [[NSMutableDictionary alloc]init];
        _categoryImage_Dic = [[NSMutableDictionary alloc]init];
    }else{
        [_category_Dic removeAllObjects];
        _category_Dic = nil;
        _category_Dic = [[NSMutableDictionary alloc]init];
        
        [_categoryImage_Dic removeAllObjects];
        _categoryImage_Dic = nil;
        _categoryImage_Dic = [[NSMutableDictionary alloc]init];
    }
    // get Category data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.defaultZipCode = [defaults objectForKey:@"default_zipcode"];
    
    if ([self.defaultZipCode isEqualToString:@"local"]) {
        [self getBusinesses_for_getCategory_Location];
    }else{
        [self getBusinesses_for_getCategory];
    }
}
@end
