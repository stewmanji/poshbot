# poshbot

===============================================================
Introduction
===============================================================
This repository includes a Ruby script that leverages Selenium 
to login to Poshmark, navigate to a specific closet, share the
entire closet with the logged in user's followers. 

Sharing is limited to available items only and are shared in a 
manner that preserves the order of the closet when completed 
successfully. 

===============================================================
Requirements
===============================================================
In order to utilize the script, the following prerequisities 
must be met: 

1. Ruby must be installed (minimum version 2.0)
2. Google Chrome Browser (minimum version 55.0)
3. ChromeDriver - WebDriver for Chrome (version 2.33)

===============================================================
Usage
===============================================================
1. Edit variables in the SeleniumPosh.rb file
    * USER - This is the username that is used for login
    * PASSWORD - This is the password required for login
    * CLOSET - This is the username of the closet to share. 
               This is commonly the same value as the USER. 

2. Run the script: `ruby SeleniumPosh.rb`
