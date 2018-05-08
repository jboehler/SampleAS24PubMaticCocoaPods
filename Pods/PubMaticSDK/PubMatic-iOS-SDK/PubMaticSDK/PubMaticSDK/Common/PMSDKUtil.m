/*
 
 * PubMatic Inc. ("PubMatic") CONFIDENTIAL
 
 * Unpublished Copyright (c) 2006-2017 PubMatic, All Rights Reserved.
 
 *
 
 * NOTICE:  All information contained herein is, and remains the property of PubMatic. The intellectual and technical concepts contained
 
 * herein are proprietary to PubMatic and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret or copyright law.
 
 * Dissemination of this information or reproduction of this material is strictly forbidden unless prior written permission is obtained
 
 * from PubMatic.  Access to the source code contained herein is hereby forbidden to anyone except current PubMatic employees, managers or contractors who have executed
 
 * Confidentiality and Non-disclosure agreements explicitly covering such access.
 
 *
 
 * The copyright notice above does not evidence any actual or intended publication or disclosure  of  this source code, which includes
 
 * information that is confidential and/or proprietary, and is a trade secret, of  PubMatic.   ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE,
 
 * OR PUBLIC DISPLAY OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT  THE EXPRESS WRITTEN CONSENT OF PubMatic IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE
 
 * LAWS AND INTERNATIONAL TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE CODE AND/OR RELATED INFORMATION DOES NOT CONVEY OR IMPLY ANY RIGHTS
 
 * TO REPRODUCE, DISCLOSE OR DISTRIBUTE ITS CONTENTS, OR TO MANUFACTURE, USE, OR SELL ANYTHING THAT IT  MAY DESCRIBE, IN WHOLE OR IN PART.
 
 */

#import "PMSDKUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/ASIdentifierManager.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "PMLogger.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <WebKit/WebKit.h>
#import <xlocale.h>

#define LOC_WHEN_IN_USE_DESC    @"NSLocationWhenInUseUsageDescription"

NSString * const kSDKVersionConstant  = @"5.3.1";

NSString * const kPubDeviceOSName  = @"iOS";
NSString * const kNotReachable      =   @"Network Not Available";
NSString * const kReachableViaWWAN  =   @"carrier";
NSString * const kReachableViaWiFi  =   @"wifi";

@interface PMSDKUtil ()<CLLocationManagerDelegate>
@property(nonatomic,strong) CLLocationManager* locationManager;
@property(nonatomic,strong) NSMutableSet * locationObserverObjIds;
@property(nonatomic,strong) NSDictionary * countryCodeDictionary;
@property(nonatomic,strong) CTCarrier * carrier;
@property(nonatomic,strong) NSDateFormatter * dateFormatter;
@property(nonatomic,assign) SCNetworkReachabilityRef reachability;
@property(nonatomic,strong) WKWebView* webView;
@property (nonatomic, assign,readonly) BOOL locationUpdateRunning;
@end


@implementation PMSDKUtil
@synthesize deviceOrientation = _deviceOrientation;
@synthesize vendorID = _vendorID;
@synthesize advertisingID = _advertisingID;
@synthesize appVersion = _appVersion;
@synthesize applicationName = _applicationName;
@synthesize appBundleIdentifier = _appBundleIdentifier;
@synthesize deviceAcceptLanguage = _deviceAcceptLanguage;
@synthesize carrierName = _carrierName;
@synthesize countryCode = _countryCode;
@synthesize mnc = _mnc;
@synthesize mcc = _mcc;
@synthesize userAgent = _userAgent;

typedef enum {
    ConnectionTypeUnknown,
    ConnectionTypeNone,
    ConnectionType3G,
    ConnectionTypeWiFi
} ConnectionType;

- (ConnectionType)connectionType
{
    SCNetworkReachabilityFlags flags;
    BOOL success = SCNetworkReachabilityGetFlags(_reachability, &flags);
    if (!success) {
        return ConnectionTypeUnknown;
    }
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL isNetworkReachable = (isReachable && !needsConnection);
    
    if (!isNetworkReachable) {
        return ConnectionTypeNone;
    } else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        return ConnectionType3G;
    } else {
        return ConnectionTypeWiFi;
    }
}

-(NSNumber *)rtbConnectionType{
    /*
     0     Unknown
     1     Ethernet
     2     WIFI
     3     Cellular Network – Unknown Generation
     4     Cellular Network – 2G
     5     Cellular Network – 3G
     ￼6     Cellular Network – 4G
     */
    
    ConnectionType conectionType = [self connectionType];
    switch (conectionType) {
        case ConnectionTypeNone:
        case ConnectionTypeUnknown:
            return [NSNumber numberWithInt:0];
            break;
            
        case ConnectionType3G:
            return [NSNumber numberWithInt:3];
            break;
            
        case ConnectionTypeWiFi:
            return [NSNumber numberWithInt:2];
            break;
            
        default:
            return [NSNumber numberWithInt:0];;
            break;
    }
}

-(NSString *)netType{
    
    ConnectionType conectionType = [self connectionType];
    switch (conectionType) {
        case ConnectionTypeNone:
        case ConnectionTypeUnknown:
            return nil;
            break;
            
        case ConnectionType3G:
            return @"cellular";
            break;
            
        case ConnectionTypeWiFi:
            return @"wifi";
            break;
            
        default:
            return nil;
            break;
    }
}

#pragma mark -  Initialization
- (id)init {
    
    self = [super init];
    if (self) {
        
        _latitude = nil;
        _longitude = nil;
        CTTelephonyNetworkInfo* networkInfo = [CTTelephonyNetworkInfo new];
        _carrier = [networkInfo subscriberCellularProvider];
        _dateFormatter = [NSDateFormatter new];
        struct sockaddr_in zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sin_len = sizeof(zeroAddress);
        zeroAddress.sin_family = AF_INET;
        _reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
        _isAutoLocationDetectionAllowed = YES;
    }
    return self;
}

-(NSString *)sdkVersion{
    
    return kSDKVersionConstant;
}

#pragma mark -  Overridden methods to make class singleton

static id sharedInstance = nil;

//
// Static functions return the singleton object of Derived class
//
+ (PMSDKUtil *)sharedInstance
{
    @synchronized(self)
    {
        if (nil == sharedInstance || (![sharedInstance isKindOfClass:self]))
            sharedInstance = [[super allocWithZone:NULL] init];
        return sharedInstance;
    }
}

// We don't allocate a new instance, so return the current one.

+ (id)allocWithZone:(NSZone*)zone {
    return [self sharedInstance] ;
}

//  we don't generate multiple copies.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

-(NSNumber *)latitude{
    
    if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)) {
        
        return nil;
    }
    return _latitude;
}

-(NSNumber *)longitude{
    
    if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)) {
        
        return nil;
    }
    return _longitude;
}

/*
 Enables location updates for specified object id, it prevents from creating multiple location manager & reuse same location across all PMBannnerAdView,PMInterstitialAd & PMNativeAd instances
 */
-(void) enableAutoLocationRetrivialForObjectId:(NSString *)objetId
                                distanceFilter:(CLLocationDistance)distanceFilter
                               desiredAccuracy:(CLLocationAccuracy)desiredAccuracy{
    if (!_isAutoLocationDetectionAllowed) {
        return;
    }
    [self.locationObserverObjIds addObject:objetId];
    
    if([self isLocationRetrivalAllowed])
    {
        if(_locationUpdateRunning){
            return;
        }
        if (self.locationManager == nil)
        {
            self.locationManager = [CLLocationManager new];
            self.locationManager.delegate = self;
        }
        
        self.locationManager.distanceFilter = distanceFilter;
        self.locationManager.desiredAccuracy = desiredAccuracy;
        
        if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined ){
            
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            {
                [self.locationManager requestWhenInUseAuthorization];
            }
            
        }
        
        [self.locationManager startUpdatingLocation];
        _locationUpdateRunning = YES;
    }
    else
    {
        [self stopLocationUpdate];
    }
}

/*!
 Disables auto location for instances of PMBannnerAdView,PMInterstitialAd & PMNativeAd, If all instances disable location updates, location updates will stop & will reset location manager
 */
-(void) disableAutoLocationRetrivialForObjectId:(NSString *)objetId
{
    [self.locationObserverObjIds removeObject:objetId];
    if(self.locationObserverObjIds.count){
        return;
    }
    [self stopLocationUpdate];
}

-(BOOL) isLocationRetrivalAllowed
{
    NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:LOC_WHEN_IN_USE_DESC];
    
    if (accessDescription == nil) {
        WarnLog(@"Missing usage description for '%@' key in your plist file. This is required to enable ads to use device location.",LOC_WHEN_IN_USE_DESC);
        return NO;
    }

    BOOL available = YES;
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    
    if ((authStatus == kCLAuthorizationStatusRestricted) || (authStatus == kCLAuthorizationStatusDenied) || ([CLLocationManager locationServicesEnabled] == NO))
    {
        available = NO;
    }
    return available;
}

-(void)stopLocationUpdate{
    
    [self.locationManager setDelegate:nil];
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    _locationUpdateRunning = NO;
}

-(void)setIsAutoLocationDetectionAllowed:(BOOL)isAutoLocationDetectionAllowed{
    
    if (_isAutoLocationDetectionAllowed && !isAutoLocationDetectionAllowed) {
        [self stopLocationUpdate];
    }
    _isAutoLocationDetectionAllowed = isAutoLocationDetectionAllowed;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    ErrorLog(@"Error code: %ld Description: %@", error.code, error.localizedDescription);
    self.latitude = nil;
    self.longitude = nil;
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations{
    
    CLLocation *currentLocation = [locations lastObject];
    self.latitude = [NSNumber numberWithDouble:currentLocation.coordinate.latitude];
    self.longitude = [NSNumber numberWithDouble:currentLocation.coordinate.longitude];
}

#pragma mark -  Accessor Functions

-(NSString *) deviceID{
    return [self advertisingID];
}

-(NSString *) vendorID{
    if (!_vendorID) {
        
        _vendorID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    return _vendorID;
}

-(NSString *) advertisingID{
    
    if (!_advertisingID) {
        
        _advertisingID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    return _advertisingID;
}

-(PubDeviceIDType) pubDeviceIDTypeForIDFAFlag:(BOOL)isIDFAEnabled
{
    return isIDFAEnabled ? kIDFA : kIDFV;
}

-(PubDeviceIDType) pubDeviceIDType
{
    return kIDFA;
}

// Determines whether user has set lmt or not
-(BOOL) limitAdTrackingEnabled
{
    return ![[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
}

-(NSString *)limitAdTracking{
    
    if([self limitAdTrackingEnabled])
    {
        return @"1";
    }
    return @"0";
}

// Get the application name
-(NSString *) applicationName
{
    if (!_applicationName) {

        _applicationName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        if (!_applicationName) {
        _applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        }
        
        if (!_applicationName) {
            _applicationName = [[[NSBundle mainBundle] localizedInfoDictionary]
                                objectForKey:(NSString*)kCFBundleNameKey];
        }
        
        if (!_applicationName) {
            _applicationName = [[[NSBundle mainBundle] infoDictionary]
                                objectForKey:(NSString*)kCFBundleNameKey];
        }
        
        if (!_applicationName) {
        _applicationName = [NSProcessInfo processInfo].processName;
        }
    }
    return _applicationName;
}

// Get the Application version
-(NSString *) appVersion
{
    
    if (!_appVersion) {
        _appVersion = [[[NSBundle mainBundle] infoDictionary]
                       objectForKey:@"CFBundleVersion"];
    }
    return _appVersion;
}

-(NSString *) appBundleIdentifier
{
    if (!_appBundleIdentifier) {
        _appBundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    }
    return _appBundleIdentifier;
}

// Get the Page url
-(NSString *) pageURL
{
    return @"" ;
}


// Retrieve the device locale
-(NSString *) deviceAcceptLanguage
{
    if (!_deviceAcceptLanguage) {
        _deviceAcceptLanguage = [[NSLocale currentLocale] localeIdentifier];
    }
    return _deviceAcceptLanguage;
}

// Get the device OS Name
-(NSString*) deviceOSName
{
    return kPubDeviceOSName;
}


// Get the device OS version
-(NSString*) deviceOSversion
{
    return [[UIDevice currentDevice] systemVersion];
}

// Get the current device make
-(NSString*) deviceMake
{
    return @"Apple";
}

// Get the current device model
-(NSString*) deviceModel
{
    return [[UIDevice currentDevice] model];
}

// Get the device height
-(CGFloat)deviceHeight
{
    return CGRectGetHeight([[UIScreen mainScreen] bounds]);
}

// Get the device width
-(CGFloat)deviceWidth
{
    return CGRectGetWidth([[UIScreen mainScreen] bounds]);
}

// Get the screen resolution
-(NSString*) deviceScreenResolution
{
    return [NSString stringWithFormat:@"%dx%d",(int)self.deviceWidth,(int)self.deviceHeight];
}


// Get the current time
- (NSString*) currentTime
{
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [_dateFormatter stringFromDate:[NSDate date]];
}


// Method for getting current TimeZone
-(double) currentTimeZone
{
    NSTimeZone *localTime = [NSTimeZone systemTimeZone];
    return (double) [localTime secondsFromGMT]/3600;
}

//Method for getting Current Device Orientation
-(int) deviceOrientation
{
    _deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch(_deviceOrientation)
    {
        case UIDeviceOrientationPortrait: return 0;
        case UIDeviceOrientationLandscapeRight: return 1;
        case UIDeviceOrientationPortraitUpsideDown:return 0;
        case UIDeviceOrientationLandscapeLeft:return 1;
        default : return -1;
    }
    return -1;
}

// Generate the randome number in between 0 to 1
-(float) ranreq
{
    float randomNumber=(float)random();
    while(randomNumber>=1)
        randomNumber=randomNumber/10;
    return randomNumber;
}

-(void)retrievUserAgent{
    
    _webView = [WKWebView new];
    [_webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
        if (error == nil) {
            if (result != nil) {
                _userAgent = [NSString stringWithFormat:@"%@", result];
            }
        } else {
            ErrorLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
        _webView = nil;
    }];
}

-(NSString *) userAgent
{
    
    if (!_userAgent) {
        
        if (!_webView) {
            
            runOnMainQueueIfNot(^{
                [self retrievUserAgent];
            });
        }
    }
    return _userAgent;
}

#pragma mark -  Private Methods


-(NSString *)mnc{
    
    if (!_mnc) {
        
        _mnc = [_carrier mobileNetworkCode];;
    }
    return _mnc;
}

-(NSString *)mcc{
    
    if (!_mcc) {
        
        _mcc = [_carrier mobileCountryCode];;
    }
    return _mcc;
}

// Get the carrier information, contry code
-(NSString*) carrierName
{
    if (!_carrierName) {
        CTCarrier *carrier = _carrier;
        if(carrier){
            
            _carrierName = [carrier carrierName];
        }
    }
    return _carrierName;
}

// Get the carrier country code in isoAlpha3
- (NSString*) countryCode
{
    if (!_countryCode) {
        
        CTCarrier *carrier = _carrier;
        
        // Get the ISO Country Code of carrier
        NSString *countryCodeInAlpha2 = [carrier isoCountryCode];
        
        if (countryCodeInAlpha2 != nil)
        {
            // Fetch the corresponding value in ISO-3166-1 Alpha 3
            NSString *countryCodeInAlpha3 = [[self countryCodeDictionary] valueForKey:[countryCodeInAlpha2 uppercaseString]];
            
            if (countryCodeInAlpha3 != nil)
            {
                _countryCode = countryCodeInAlpha3;
            }
        }
    }
    return _countryCode;
}

+ (NSString* )stringFromGender:(int)gender
{
    switch (gender)
    {
        case 0 :
            return @"O";
            
        case 1 :
            return @"M";
            
        case 2:
            return @"F";
            
        default:
            return nil;
            
    }
    return nil;
}

-(NSDictionary * )countryCodeDictionary{
    
    if(!_countryCodeDictionary){
        
        _countryCodeDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"AND",@"AD",@"ARE",@"AE",@"AFG",@"AF",@"ATG",@"AG",@"AIA",@"AI",@"ALB",@"AL",@"ARM",@"AM",@"AGO",@"AO",@"ATA",@"AQ",@"ARG",@"AR",@"ASM",@"AS",@"AUT",@"AT",@"AUS",@"AU",@"ABW",@"AW",@"ALA",@"AX",@"AZE",@"AZ",@"BIH",@"BA",@"BRB",@"BB",@"BGD",@"BD",@"BEL",@"BE",@"BFA",@"BF",@"BGR",@"BG",@"BHR",@"BH",@"BDI",@"BI",@"BEN",@"BJ",@"BLM",@"BL",@"BMU",@"BM",@"BRN",@"BN",@"BOL",@"BO",@"BES",@"BQ",@"BRA",@"BR",@"BHS",@"BS",@"BTN",@"BT",@"BVT",@"BV",@"BWA",@"BW",@"BLR",@"BY",@"BLZ",@"BZ",@"CAN",@"CA",@"CCK",@"CC",@"COD",@"CD",@"CAF",@"CF",@"COG",@"CG",@"CHE",@"CH",@"CIV",@"CI",@"COK",@"CK",@"CHL",@"CL",@"CMR",@"CM",@"CHN",@"CN",@"COL",@"CO",@"CRI",@"CR",@"CUB",@"CU",@"CPV",@"CV",@"CUW",@"CW",@"CXR",@"CX",@"CYP",@"CY",@"CZE",@"CZ",@"DEU",@"DE",@"DJI",@"DJ",@"DNK",@"DK",@"DMA",@"DM",@"DOM",@"DO",@"DZA",@"DZ",@"ECU",@"EC",@"EST",@"EE",@"EGY",@"EG",@"ESH",@"EH",@"ERI",@"ER",@"ESP",@"ES",@"ETH",@"ET",@"FIN",@"FI",@"FJI",@"FJ",@"FLK",@"FK",@"FSM",@"FM",@"FRO",@"FO",@"FRA",@"FR",@"GAB",@"GA",@"GBR",@"GB",@"GRD",@"GD",@"GEO",@"GE",@"GUF",@"GF",@"GGY",@"GG",@"GHA",@"GH",@"GIB",@"GI",@"GRL",@"GL",@"GMB",@"GM",@"GIN",@"GN",@"GLP",@"GP",@"GNQ",@"GQ",@"GRC",@"GR",@"SGS",@"GS",@"GTM",@"GT",@"GUM",@"GU",@"GNB",@"GW",@"GUY",@"GY",@"HKG",@"HK",@"HMD",@"HM",@"HND",@"HN",@"HRV",@"HR",@"HTI",@"HT",@"HUN",@"HU",@"IDN",@"ID",@"IRL",@"IE",@"ISR",@"IL",@"IMN",@"IM",@"IND",@"IN",@"IOT",@"IO",@"IRQ",@"IQ",@"IRN",@"IR",@"ISL",@"IS",@"ITA",@"IT",@"JEY",@"JE",@"JAM",@"JM",@"JOR",@"JO",@"JPN",@"JP",@"KEN",@"KE",@"KGZ",@"KG",@"KHM",@"KH",@"KIR",@"KI",@"COM",@"KM",@"KNA",@"KN",@"PRK",@"KP",@"KOR",@"KR",@"XKX",@"XK",@"KWT",@"KW",@"CYM",@"KY",@"KAZ",@"KZ",@"LAO",@"LA",@"LBN",@"LB",@"LCA",@"LC",@"LIE",@"LI",@"LKA",@"LK",@"LBR",@"LR",@"LSO",@"LS",@"LTU",@"LT",@"LUX",@"LU",@"LVA",@"LV",@"LBY",@"LY",@"MAR",@"MA",@"MCO",@"MC",@"MDA",@"MD",@"MNE",@"ME",@"MAF",@"MF",@"MDG",@"MG",@"MHL",@"MH",@"MKD",@"MK",@"MLI",@"ML",@"MMR",@"MM",@"MNG",@"MN",@"MAC",@"MO",@"MNP",@"MP",@"MTQ",@"MQ",@"MRT",@"MR",@"MSR",@"MS",@"MLT",@"MT",@"MUS",@"MU",@"MDV",@"MV",@"MWI",@"MW",@"MEX",@"MX",@"MYS",@"MY",@"MOZ",@"MZ",@"NAM",@"NA",@"NCL",@"NC",@"NER",@"NE",@"NFK",@"NF",@"NGA",@"NG",@"NIC",@"NI",@"NLD",@"NL",@"NOR",@"NO",@"NPL",@"NP",@"NRU",@"NR",@"NIU",@"NU",@"NZL",@"NZ",@"OMN",@"OM",@"PAN",@"PA",@"PER",@"PE",@"PYF",@"PF",@"PNG",@"PG",@"PHL",@"PH",@"PAK",@"PK",@"POL",@"PL",@"SPM",@"PM",@"PCN",@"PN",@"PRI",@"PR",@"PSE",@"PS",@"PRT",@"PT",@"PLW",@"PW",@"PRY",@"PY",@"QAT",@"QA",@"REU",@"RE",@"ROU",@"RO",@"SRB",@"RS",@"RUS",@"RU",@"RWA",@"RW",@"SAU",@"SA",@"SLB",@"SB",@"SYC",@"SC",@"SDN",@"SD",@"SSD",@"SS",@"SWE",@"SE",@"SGP",@"SG",@"SHN",@"SH",@"SVN",@"SI",@"SJM",@"SJ",@"SVK",@"SK",@"SLE",@"SL",@"SMR",@"SM",@"SEN",@"SN",@"SOM",@"SO",@"SUR",@"SR",@"STP",@"ST",@"SLV",@"SV",@"SXM",@"SX",@"SYR",@"SY",@"SWZ",@"SZ",@"TCA",@"TC",@"TCD",@"TD",@"ATF",@"TF",@"TGO",@"TG",@"THA",@"TH",@"TJK",@"TJ",@"TKL",@"TK",@"TLS",@"TL",@"TKM",@"TM",@"TUN",@"TN",@"TON",@"TO",@"TUR",@"TR",@"TTO",@"TT",@"TUV",@"TV",@"TWN",@"TW",@"TZA",@"TZ",@"UKR",@"UA",@"UGA",@"UG",@"UMI",@"UM",@"USA",@"US",@"URY",@"UY",@"UZB",@"UZ",@"VAT",@"VA",@"VCT",@"VC",@"VEN",@"VE",@"VGB",@"VG",@"VIR",@"VI",@"VNM",@"VN",@"VUT",@"VU",@"WLF",@"WF",@"WSM",@"WS",@"YEM",@"YE",@"MYT",@"YT",@"ZAF",@"ZA",@"ZMB",@"ZM",@"ZWE",@"ZW",@"SCG",@"CS",@"ANT",@"AN",nil ];
    }
    return _countryCodeDictionary;
}

#pragma mark -  Overridden methods to make class singleton

- (void)dealloc
{
    
    self.latitude = nil;
    self.longitude = nil;
    [self.locationManager stopUpdatingLocation];
    [self.locationManager setDelegate:nil];
    self.locationManager = nil;
}

+ (BOOL ) canInternalBrowserOpenURL:(NSURL *)url{
    
    if ([[url.scheme lowercaseString] hasPrefix:@"http"] == NO)
    {
        return NO;
    }
    
    NSString* host = [url.host lowercaseString];
    if ([host hasSuffix:@"itunes.apple.com"] || [host hasSuffix:@"phobos.apple.com"])
    {
        return NO;
    }
    return YES;
}

+ (void)openURL:(NSURL *)url{
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            
        }];
        
    }else{
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] openURL:url];
#pragma clang diagnostic pop
    }
}

static NSCharacterSet* tzMarkerCharacterSet = nil;

+ (id)dateFromW3CCalendarDate:(NSString*)dateString
{
    if (tzMarkerCharacterSet == nil)
        tzMarkerCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
    
    if ([dateString length] == 0)
        return nil;
    
    // Needs to have a date and time.
    NSArray* dateAndTime = [dateString componentsSeparatedByString:@"T"];
    if ([dateAndTime count] != 2)
        return nil;
    
    NSString* time = [dateAndTime objectAtIndex:1];
    if ([time hasSuffix:@"Z"])
    {
        // Swap Z for the GMT offset.
        time = [time stringByReplacingOccurrencesOfString:@"Z" withString:@"+0000"];
    }
    else
    {
        NSRange tzMarker = [time rangeOfCharacterFromSet:tzMarkerCharacterSet];
        if (tzMarker.location != NSNotFound)
        {
            // Remove the : from the zone offset.
            NSString* zone = [time substringFromIndex:tzMarker.location];
            NSString* fixedZone = [zone stringByReplacingOccurrencesOfString:@":" withString:@""];
            
            time = [time stringByReplacingOccurrencesOfString:zone withString:fixedZone];
            
            // Add in zero'd seconds if seconds are missing.
            if ([[time componentsSeparatedByString:@":"] count] < 3)
            {
                tzMarker.length = 0;
                time = [time stringByReplacingCharactersInRange:tzMarker withString:@":00"];
            }
        }
        else
        {
            // Add a GMT offset so "something" is there.
            time = [time stringByAppendingString:@"+0000"];
        }
    }
    
    NSString* fixedDateString = [NSString stringWithFormat:@"%@T%@",
                                 [dateAndTime objectAtIndex:0],
                                 time];
    
    struct tm parsedTime;
    const char* formatString = "%FT%T%z";
    strptime_l([fixedDateString UTF8String], formatString, &parsedTime, NULL);
    time_t since = mktime(&parsedTime);
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:since];
    
    return date;
}

void runOnMainQueueIfNot(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end
