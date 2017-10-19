# poshbot

## Introduction

This repository includes a Ruby script that leverages Selenium to login to Poshmark, navigate to a specific closet, share the entire closet with the logged in user's followers. 

Sharing is limited to available items only and are shared in a manner that preserves the order of the closet when completed successfully. 

## Requirements

In order to utilize the script, the following prerequisities must be met: 

1. Ruby must be installed (minimum version 2.0) [link](https://www.ruby-lang.org/en/downloads/)
2. Google Chrome Browser (minimum version 55.0)
3. ChromeDriver - WebDriver for Chrome (version 2.33) [link](https://chromedriver.storage.googleapis.com/index.html?path=2.33/)
    * [Linux x64](https://chromedriver.storage.googleapis.com/2.33/chromedriver_linux64.zip)
    * [Linux x86](https://chromedriver.storage.googleapis.com/2.33/chromedriver_linux32.zip)
    * [Mac](https://chromedriver.storage.googleapis.com/2.33/chromedriver_mac64.zip)
    * [Windows - Chrome Driver](https://chromedriver.storage.googleapis.com/2.33/chromedriver_win32.zip)

## Usage

1. Edit variables in the SeleniumPosh.rb file
    * USER - This is the username that is used for login
    * PASSWORD - This is the password required for login
    * CLOSETS - This is the username(s) of the closet to share. This is commonly the same value as the USER. 

2. Run the script: `ruby SeleniumPosh.rb`

## Known Issues/Limitations

* Poshmark occassionally intorduces a Captcha validation when logging in. The login may fail unless a human successfully completes the Captcha validation within 60 seconds. If the login fails, Poshbot will exit.
* For large closets (100+ items), Poshmark occassionally triggers a Captcha when attempting to share an item. If this occurs a human must complete the Captcha validation. The log messages will fill with WARN statements indicating an infinity retry. 