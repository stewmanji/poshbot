require 'rubygems'
require 'selenium-webdriver'
require 'logger'

#Initialize logger
LOGGER = Logger.new(STDOUT)
LOGGER.level = Logger::DEBUG
LOGGER.formatter = proc do |severity, datetime, progname, msg|
  "#{datetime}: #{(severity+"     ").slice(0,5)}  #{msg}\n"
end

# User Properties
USER = ""
PASSWORD = ""
CLOSETS = [""]

# Custom Properties
HEADLESS = true
LIMIT = -1
SLEEP = 0.15
LOGGER.debug("Custom properties are HEADLESS=#{HEADLESS.to_s}, LIMIT=#{LIMIT.to_s}, SLEEP=#{SLEEP.to_s}")

# Initialize driver
LOGGER.debug("Initializing driver")
if HEADLESS 
  DRIVEROPTS = Selenium::WebDriver::Chrome::Options.new
  DRIVEROPTS.add_argument('--headless')
  DRIVER = Selenium::WebDriver.for :chrome, options: DRIVEROPTS
else 
  DRIVER = Selenium::WebDriver.for :chrome
end
LOGGER.debug("Driver initialized successfully")

# login requires a driver, user and password.
# login returns a boolean indicating if the login was successful or not
def login(driver, user, password)
  driver.get "https://poshmark.com/login"
  LOGGER.debug("Login page loaded successfully")
  driver.find_element(:id, "login_form_username_email").send_keys user
  driver.find_element(:id, "login_form_password").send_keys password
  driver.find_element(:id, "login_form_password").submit
  LOGGER.debug("Login submitted")
  begin
    Selenium::WebDriver::Wait.new(:timeout => 60).until { driver.title.start_with? "Feed" }
    LOGGER.info("Logged in successfully as #{USER}")
    return true
  rescue
    LOGGER.error("Login failed.")
    return false
  end
end

# logout requires a driver
# logout returns a boolean indicating if the login was successful or not
def logout(driver)
  driver.get "https://poshmark.com/logout"
  begin
    Selenium::WebDriver::Wait.new(:timeout => 3).until { driver.title.start_with? "Poshmark" }
    driver.quit
    return true
  rescue
    return false
  end
end

# load_closet requires a driver and closet name
# load_closet returns an array of all the available items 
def load_closet(driver, closet, limit=-1)
  driver.get "https://poshmark.com/closet/" + closet + "?availability=available"
  LOGGER.debug("Loaded the first page of #{closet}'s closet")
  loader = driver.find_element(:id, "load-more")
  old_shares = driver.find_elements(:class, "share")
  shares = []

  while (old_shares.size != shares.size) do 
    old_shares = shares
    driver.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    if loader.displayed? 
      sleep 1
      Selenium::WebDriver::Wait.new(:timeout => 10).until { !driver.find_element(:id, "load-more").displayed? }
    end
    sleep SLEEP*2
    shares = driver.find_elements(:class, "share")
    if ((limit != -1) && (shares.size >= limit))
      return shares
    end
  end
  return shares
end 

# share_item requires a driver and an item
# share_item returns if the item was shared successfully
def share_item(driver, item)
  begin
    spot = item.location
    driver.execute_script("window.scrollTo(#{spot.x}, #{spot.y - 400})")
    item.click
    sleep SLEEP
    driver.find_element(:class, "pm-followers-share-link").click
    Selenium::WebDriver::Wait.new(:timeout => 1).until { driver.find_element(:class, "flash-con").displayed? }
    sleep SLEEP
    driver.execute_script("$('.flash-con').hide()")
    sleep SLEEP
    return true
  rescue
    LOGGER.warn("Sharing #{item.attribute("data-pa-attr-listing_id")} failed, retrying...")
    sleep 1
    return false
  end
end

# share_items requires a driver and items array
# share_items returns no value
def share_items(driver, items, limit)
  if (limit == -1)
    items_to_share = items
  else
    items_to_share = items[0..limit-1]
  end 
  items_to_share.reverse.each_with_index do |i, index| 
    unless share_item(driver, i)
      until share_item(driver, i) do
        share_item(driver, items[0])
      end 
    end
    LOGGER.debug("Shared #{index+1} items so far")
  end
  LOGGER.info("Successfully shared #{items_to_share.size} items with your followers")
end

# Begin logic
LOGGER.debug("Script is beginning")
if login(DRIVER, USER, PASSWORD)
  # Share Each Closet
  CLOSETS.each do |closet|
    items_to_share = load_closet(DRIVER, closet, LIMIT)
    LOGGER.info( "Found #{items_to_share.size} items from #{closet}'s closet")
    unless (LIMIT == -1)
      LOGGER.info( "Shares limited manually to #{LIMIT}.")
    end 
    LOGGER.info( "Starting to share, this may take some time")
    share_items(DRIVER, items_to_share, LIMIT)
  end

  if logout(DRIVER)
    LOGGER.info("Successfully logged out of Poshmark")
  end
end
LOGGER.debug("Script is completed")
