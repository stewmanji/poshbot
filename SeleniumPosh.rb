require 'rubygems'
require 'selenium-webdriver'

USER = ""
PASSWORD = ""
CLOSET = ""
SLEEP = 0.1

driver = Selenium::WebDriver.for :chrome
wait = Selenium::WebDriver::Wait.new(:timeout => 60)
rand = Random.new

# Login
driver.get "https://poshmark.com/login"
driver.find_element(:id, "login_form_username_email").send_keys USER
driver.find_element(:id, "login_form_password").send_keys PASSWORD
driver.find_element(:id, "login_form_password").submit
wait.until { driver.title.start_with? "Feed" } 

# Load Full Closet
driver.get "https://poshmark.com/closet/" + CLOSET + "?availability=available"
loader = driver.find_element(:id, "load-more")
old_shares = driver.find_elements(:class, "share")
shares = []

while (old_shares.size != shares.size) do 
  old_shares = shares
  driver.execute_script("window.scrollTo(0, document.body.scrollHeight)")
  if loader.displayed? 
    wait.until { !driver.find_element(:id, "load-more").displayed? }
  end
  sleep SLEEP*2
  shares = driver.find_elements(:class, "share")
#  puts "There are #{shares.size} objects to share"
end

# Share
shares.reverse.each_with_index do |i, index| 
  spot = i.location 
  driver.execute_script("window.scrollTo(#{spot.x}, #{spot.y - 400})")
  i.click
  sleep SLEEP
  driver.find_element(:class, "pm-followers-share-link").click
  wait.until { driver.find_element(:class, "flash-con").displayed? }
  sleep SLEEP
  driver.execute_script("$('.flash-con').hide()")
  sleep SLEEP
#  puts "Shared #{index+1}/#{shares.size}: #{i.attribute("data-pa-attr-listing_id")}"
  if (index+1)%10 == 0
    puts "Shared #{index+1}/#{shares.size}: #{i.attribute("data-pa-attr-listing_id")}"
  end
end

puts "Successfully shared #{shares.size} items with your followers"

# Logout
driver.get "https://poshmark.com/logout"
wait.until { driver.title.start_with? "Poshmark" }

driver.quit