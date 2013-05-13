# PLUGIN: 

phonegap-plugin-wizDevTools
Cordova 2.7
last update : 13/05/2013


# DESCRIPTION :

PhoneGap plugin for accessing the Wizard Development Toolkit. (iOS ONLY)


# CHANGELOG: 
- Updated to Cordova 2.7
- Updated to Cordova 2.6
- Updated to Cordova 2.5
- Updated to Cordova 2.4
- Updated to Cordova 2.3
- Updated to Cordova 1.9


# KNOWN ISSUES:
- None.


# INSTALL (iOS): #

Project tree<br />

<pre><code>
www
	/ phonegap
		/ plugin
			/ wizDevTools
				/ wizDevTools.js
ios
	/ project
		/ Plugins
			/ wizDevToolsPlugin
				/ wizDevToolsPlugin.h
				/ wizDevToolsPlugin.m
</code></pre>



1 ) Arrange files to structure seen above.


2 ) Add to Cordova.plist in the plugins array;<br />
Key : wizDevToolsPlugin<br />
Type : String<br />
Value : wizDevToolsPlugin<br />


3 ) Add \<script\> tag to your index.html<br />
\<script type="text/javascript" charset="utf-8" src="phonegap/plugin/wizDevToolsPlugin/wizDevToolsPlugin.js"\>\</script\><br />
(assuming your index.html is setup like tree above)

4 ) Disable the use of private APIs for release (App Store) submission builds by adding NDEBUG=1 as a preprocessor macro in the Xcode build settings.

