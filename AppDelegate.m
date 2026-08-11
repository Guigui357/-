#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    ViewController *rootVC = [[ViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootVC];
    navController.navigationBar.prefersLargeTitles = NO;
    navController.navigationBar.tintColor = [UIColor systemBlueColor];
    
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    // FORÇA A ATUALIZAÇÃO DA JANELA
    [self.window layoutIfNeeded];
    
    return YES;
}

@end
