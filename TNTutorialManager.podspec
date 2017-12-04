Pod::Spec.new do |s|
	s.name				= 'TNTutorialManager'
	s.version			= '1.3.2'
	s.summary			= 'Tutorial Handler that helps you implement interactive tutorials inside your iOS Apps.'

	s.description		= "TNTutorialManager is a manager that helps you implement interactive tutorials inside your iOS Apps."

	s.homepage			= 'https://github.com/Tawa/TNTutorialManager'
	s.license			= { :type => 'MIT', :file => 'LICENSE' }
	s.author			= { 'TawaNicolas' => 'tawanicolas@gmail.com' }
	s.source			= { :git => 'https://github.com/Tawa/TNTutorialManager', :tag => s.version.to_s }
	s.social_media_url	= 'https://twitter.com/TawaNicolas'

	s.ios.deployment_target = '10.0'

	s.subspec 'TNTutorialManager' do |ss|
		ss.source_files = 'TNTutorialManager'
	end
end
