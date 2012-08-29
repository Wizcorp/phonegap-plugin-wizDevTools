# PLUGIN: 

phonegap-plugin-wizDevTools
Cordova 1.7



# DESCRIPTION :

PhoneGap plugin for accessing the Wizard Development Toolkit. (iOS ONLY)


# INSTALL (iOS): #

Project tree<br />

<pre><code>
project
  / www
		-index.html
		/ phonegap
			/ plugin
				/ exceptionDebugPlugin
					/ exceptionDebugPlugin.js	
	/ Classes
		MainViewController.m
	/ Plugins
		/ ExceptionDebugPlugin
			/ ExceptionDebugPlugin.h
			/ ExceptionDebugPlugin.m
	-project.xcodeproj
</code></pre>



1 ) Arrange files to structure seen above.


2 ) Add to phonegap.plist in the plugins array;<br />
Key : ExceptionDebugPlugin<br />
Type : String<br />
Value : ExceptionDebugPlugin<br />


3 ) Add \<script\> tag to your index.html<br />
\<script type="text/javascript" charset="utf-8" src="phonegap/plugin/exceptionDebugPlugin/exceptionDebugPlugin.js"\>\</script\><br />
(assuming your index.html is setup like tree above)
