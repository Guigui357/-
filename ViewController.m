#import "ViewController.h"
#import "exploit.h"

@interface ViewController ()
@property (nonatomic, strong) UIButton *jailbreakButton;
@property (nonatomic, strong) UITextView *logTextView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL isRunning;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"Jailbreak";
    self.isRunning = NO;
    
    [self setupUI];
}

- (void)setupUI {
    // ----- 1. TÍTULO -----
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = @"🔓 iOS Jailbreak";
    titleLabel.font = [UIFont boldSystemFontOfSize:28];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor systemBlueColor];
    [self.view addSubview:titleLabel];
    
    // ----- 2. TEXTVIEW (logs) -----
    self.logTextView = [[UITextView alloc] init];
    self.logTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.logTextView.editable = NO;
    self.logTextView.selectable = YES;
    self.logTextView.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1.0];
    self.logTextView.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    self.logTextView.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightBold];
    self.logTextView.layer.cornerRadius = 12;
    self.logTextView.layer.masksToBounds = YES;
    self.logTextView.layer.borderWidth = 1;
    self.logTextView.layer.borderColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:0.5].CGColor;
    self.logTextView.text = @"═══════════════════════════════\n";
    self.logTextView.text = [self.logTextView.text stringByAppendingString:@"  🔓 JAILBREAK TOOL\n"];
    self.logTextView.text = [self.logTextView.text stringByAppendingString:@"  Aguardando início...\n"];
    self.logTextView.text = [self.logTextView.text stringByAppendingString:@"═══════════════════════════════\n"];
    self.logTextView.contentInset = UIEdgeInsetsMake(12, 12, 12, 12);
    [self.view addSubview:self.logTextView];
    
    // ----- 3. BOTÃO (AQUI ESTÁ O BOTÃO!) -----
    self.jailbreakButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.jailbreakButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.jailbreakButton setTitle:@"🚀 INICIAR JAILBREAK" forState:UIControlStateNormal];
    [self.jailbreakButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.jailbreakButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.jailbreakButton setBackgroundColor:[UIColor systemBlueColor]];
    self.jailbreakButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.jailbreakButton.layer.cornerRadius = 14;
    self.jailbreakButton.layer.masksToBounds = YES;
    [self.jailbreakButton addTarget:self
                             action:@selector(startJailbreak)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.jailbreakButton];
    
    // ----- 4. ACTIVITY INDICATOR (dentro do botão) -----
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.color = [UIColor whiteColor];
    [self.jailbreakButton addSubview:self.activityIndicator];
    
    // ----- 5. CONSTRAINTS -----
    [NSLayoutConstraint activateConstraints:@[
        // Título
        [titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [titleLabel.heightAnchor constraintEqualToConstant:40],
        
        // Log TextView
        [self.logTextView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:12],
        [self.logTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.logTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.logTextView.heightAnchor constraintEqualToConstant:420],
        
        // BOTÃO
        [self.jailbreakButton.topAnchor constraintEqualToAnchor:self.logTextView.bottomAnchor constant:25],
        [self.jailbreakButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.jailbreakButton.widthAnchor constraintEqualToConstant:280],
        [self.jailbreakButton.heightAnchor constraintEqualToConstant:60],
        
        // Activity Indicator
        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.jailbreakButton.centerXAnchor],
        [self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.jailbreakButton.centerYAnchor],
    ]];
}

- (void)startJailbreak {
    if (self.isRunning) return;
    self.isRunning = YES;
    
    [self.jailbreakButton setEnabled:NO];
    [self.jailbreakButton setTitle:@"" forState:UIControlStateNormal];
    [self.jailbreakButton setBackgroundColor:[UIColor systemGrayColor]];
    [self.activityIndicator startAnimating];
    
    [self appendLog:@"═══════════════════════════════"];
    [self appendLog:@"[+] 🚀 Iniciando jailbreak..."];
    [self appendLog:@"[+] 📱 Modelo: %@", [UIDevice currentDevice].model];
    [self appendLog:@"[+] 📲 iOS: %@", [UIDevice currentDevice].systemVersion];
    [self appendLog:@"═══════════════════════════════"];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int result = run_jailbreak();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.activityIndicator stopAnimating];
            [weakSelf.jailbreakButton setEnabled:YES];
            
            if (result == 0) {
                [weakSelf.jailbreakButton setTitle:@"✅ JAILBREAK OK!" forState:UIControlStateNormal];
                [weakSelf.jailbreakButton setBackgroundColor:[UIColor systemGreenColor]];
                [weakSelf appendLog:@"═══════════════════════════════"];
                [weakSelf appendLog:@"[+] ✅ JAILBREAK CONCLUÍDO!"];
                [weakSelf appendLog:@"[+] 🎉 Dispositivo jailbroken!"];
                [weakSelf appendLog:@"[+] 🔑 SSH: root@localhost -p 2222"];
                [weakSelf appendLog:@"═══════════════════════════════"];
            } else {
                [weakSelf.jailbreakButton setTitle:@"❌ FALHOU" forState:UIControlStateNormal];
                [weakSelf.jailbreakButton setBackgroundColor:[UIColor systemRedColor]];
                [weakSelf appendLog:@"═══════════════════════════════"];
                [weakSelf appendLog:@"[!] ❌ JAILBREAK FALHOU!"];
                [weakSelf appendLog:@"[!] Código: %d", result];
                [weakSelf appendLog:@"═══════════════════════════════"];
            }
            
            weakSelf.isRunning = NO;
        });
    });
}

- (void)appendLog:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *currentText = weakSelf.logTextView.text;
        if (currentText.length > 0) {
            weakSelf.logTextView.text = [currentText stringByAppendingFormat:@"\n%@", msg];
        } else {
            weakSelf.logTextView.text = msg;
        }
        // Scroll para o final
        NSRange range = NSMakeRange(weakSelf.logTextView.text.length - 1, 1);
        [weakSelf.logTextView scrollRangeToVisible:range];
    });
}

@end
