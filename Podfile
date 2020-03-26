platform :ios, '10.0'

def pods
    # Clean Architecture
    pod 'MGArchitecture', '~> 1.3.1'
    pod 'MGAPIService', '~> 2.2.1'
    pod 'MGLoadMore', '~> 1.3.1'

    # Rx
    pod 'NSObject+Rx', '~> 5.0'
    pod 'RxDataSources', '~> 4.0'

    # Core
    pod 'ObjectMapper', '~> 3.5'
    pod 'Reusable', '~> 4.1'
    pod 'Then', '~> 2.4'
    pod 'MJRefresh', '~> 3.2'
    pod 'Validator', '~> 3.2.1'

    # Others
    pod 'MBProgressHUD', '~> 1.2'
    pod 'SDWebImage', '~> 5.6'
    pod "YoutubePlayer-in-WKWebView", "~> 0.3.0"
end

def test_pods
    pod 'RxBlocking', '~> 5.1'
end

target 'MGYoutubePlayer' do
    use_frameworks!
    inhibit_all_warnings!
    pods

    target 'MGYoutubePlayerTests' do
        inherit! :search_paths
        test_pods
    end

end
