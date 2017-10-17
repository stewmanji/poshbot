require 'rubygems'
require 'selenium-webdriver'

USER = ""
PASSWORD = ""
CLOSET = ""
SLEEP = 0.1
DRIVER = Selenium::WebDriver.for :chrome

# login requires a driver, user and password.
# login returns a boolean indicating if the login was successful or not
def login(driver, user, password)
  driver.get "https://poshmark.com/login"
  driver.find_element(:id, "login_form_username_email").send_keys user
  driver.find_element(:id, "login_form_password").send_keys password
  driver.find_element(:id, "login_form_password").submit
  begin
    Selenium::WebDriver::Wait.new(:timeout => 60).until { driver.title.start_with? "Feed" }
    return true
  rescue
    puts "Login failed"
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
def load_closet(driver, closet)
  driver.get "https://poshmark.com/closet/" + closet + "?availability=available"
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
    puts " WARN: Sharing #{item.attribute("data-pa-attr-listing_id")} failed, retrying..."
    return false
  end
end

# share_items requires a driver and items array
# share_items returns no value
def share_items(driver, items)
  items.reverse.each_with_index do |i, index| 
    until share_item(driver, i) do
      share_item(driver, items[0])
    end 
  end
  puts " INFO: Successfully shared #{items.size} items with your followers"
end

# Initialize the script
if login(DRIVER, USER, PASSWORD)
  puts " INFO: Logged in successfully as #{USER}"
  items_to_share = load_closet(DRIVER, CLOSET)
  puts " INFO: Found #{items_to_share.size} items from #{CLOSET}'s closet"
  puts " INFO: Starting to share, this may take some time"
  share_items(DRIVER, items_to_share)
  if logout(DRIVER)
    puts " INFO: Successfully logged out of Poshmark"
  end
end
