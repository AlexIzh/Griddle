
Pod::Spec.new do |s|

  s.name         = "Griddle"
  s.version      = "1.0.2"
  s.summary      = "Manager for simple work with UITableView, UICollectionView and any others collection structured views."

  s.description  = <<-DESC 
                    It is layer for working with table view, collection view and any other views, which has collection structure. It lets to use collections and tables in one page without a lot of code.
                   DESC

  s.homepage     = "https://github.com/AlexIzh/Griddle"

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "https://github.com/AlexIzh/Griddle/blob/master/LICENSE" }

  s.author             = { "Alex Severyanov" => "alex.severyanov@gmail.com" }

  s.ios.deployment_target = "8.0"

  s.source       = { :git => "https://github.com/AlexIzh/Griddle.git", :tag => "#{s.version}" }

  s.source_files  = "Griddle/Classes/*.swift"

end
