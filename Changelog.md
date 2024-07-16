## 0.9.5 (16th of July, 2024)

Features:

  - Remove non-working obsolete exceptions page

Bugfixes:

  - Garbled list after changing location from recent searches - FIXED

## 0.9.4 (6th of April, 2023)

Bugfixes:

  - Fix routing after Digitransit API key requirement

## 0.9.3 (18th of April, 2022)

Features:

  - Add support for trams and local trains in Tampere
  - Add support for selecting means of transport for all regions

## 0.9.2 (15th of June, 2020)

Features:

  - Add reset to defaults option to settings

Bugfixes:

  - Fix Helsinki live vehicle locations map
  - Fix 'nan' search time after upgrading to 0.9.1
  - Fix initial usage with Helsinki region

## 0.9.1 (17th of February, 2020)

Features:

  - Add Waltti regions for routing
  - Add from and to stops on listing
  - Add configurable parameter to change search interval

## 0.9.0 (28th of April, 2019)

Features:

  - Add Turku region (Föli) - FIXED
  - Add options for tuning willingness to change and walk

## 0.8.2 (9th of February, 2019)

Bugfixes:

  - Fix Helsinki live vehicle locations map

## 0.8.1 (28th of July, 2018)

Features:

  - Show vehicle speed on map in Helsinki

Bugfixes:

  - Use Mqtt API instead of Siri in Helsinki, Siri has not been working for some time
  - Attempt to fix font scaling on Exception Info page

## 0.8.0 (5th of July, 2018)

Bugfixes:

  - Update to use Digitransit API, the old one in Helsinki was closed in May 2018

## 0.7.5 (17th of February, 2017)

Bugfixes:

  - Fix search from cover after changes in time handling

## 0.7.4 (17th of February, 2017)

Bugfixes:

  - Does not work on Sailfish 2.1 - FIXED
  - Fix issues introduced by the Qt5.6 update
  - Fix a bug that caused Favorite routes search fail if the to field
    had input

## 0.7.3 (14th of December, 2016)

Bugfixes:

  - Fix dependencies to always install needed Here mapplugin


## 0.7.2 (13th of December, 2016)

Bugfixes:

  - Update used Map plugin from Nokia to Here needed after Haapajoki update

## 0.7.1 (13th of December, 2016)

Bugfixes:

  - JollaOpas doesn't show map - FIXED

## 0.7.0 (20th of November, 2016)

Features:

  - Save recent destinations automatically

## 0.6.4 (19th of July, 2016)

Bugfixes:

  - Scale the layout for dirrefent screen sizes, tested on JollaPhone,
    JollaTablet and Fairphone2
  - Add scaled icons

## 0.6.3 (29th of October, 2015)

Bugfixes:

  - Text on Exception info was written in fixed grey color, now uses Silica theme
  - Removed non-working GPS switch
  - Improved GPS accuracy when using 'Current location' in query
  - Smaller bugfixes

## 0.6.2 (5th of May, 2015)

Bugfixes:

  - After upgrade to 1.1.4.28: in the main screen, the button for 'Now' (for time selection) is misaligned - FIXED
  - Smaller bugfixes

## 0.6.1 (18th of March, 2015)

Features:

  - Added last updated time to Map views
  - Smaller improvements

## 0.6.0 (2nd of March, 2015)

Features:

  - Added new map to show all routes and vehicles from ResultPage
  - Added map gestures for zooming and returning to current location similar to Jolla Maps gestures
  - Added animations for map usage
  - Added option to change default zoom level of maps
  - Use QtPositioning 5.2 and 5.3 API for animations, adds requirement for Sailfish OS 1.1.0.38 or newer
  - Smaller improvements and bugfixes

## 0.5.2 (12th of February, 2015)

Features:

  - Added line codes to ResultPage cover
  - Added map buttons for easier one handed zooming

## 0.5.1 (26th of October, 2014)

Bugfixes:

  - In Uitukka/Qt5.2: The top of the main page has a 'cancel / choose location' band - FIXED
  - In Uitukka/Qt5.2: The cover show only a bunch of ':00 2 - :00 2' - FIXED

## 0.5.0 (2nd of August, 2014)

Bugfixes:

  - All map tiles are now loaded correctly when opening map
  - Search button is no more enabled before route endpoints are valid

Features:

  - Live vehicle locations are now showed on routemap using Siri APIs
  - Mobile optimized map is now used by default
  - Smaller improvements and bugfixes

## 0.4.2 (1st of July, 2014)

Bugfixes:

  - Locations are now placed correctly on map
  - Add zoom for map view - FIXED
  - Change place of the search indicators - FIXED

Features:

  - Improved layout and elements of the Search page
  - Loading Search page is now smoothier
  - Smaller improvements and bugfixes

## 0.4.1 (23rd of June, 2014)

Bugfixes:

  - Search button location should now work as expected
  - Close button is now easier to spot in split map view

Features:

  - Added button to query favorite routes in the reverse direction
  - Added dialog for easier selection of the map type
  - Adjusted default zoom level to get sharper satellite maps by default
  - Added padding and scroll decorators to Route and Stop pages

## 0.4.0 (7th of June, 2014)

Bugfixes:

  - Fixed time differences in StopPage

Features:

  - Added options to filter U lines and Service lines
  - Added more route details to Cover and Clipboard
  - Improved Search page
  - Smaller improvements and bugfixes

## 0.3.3 (16th of May, 2014)

Bugfixes:

  - Fixes to UI text elements and Finnish translations

## 0.3.2 (16th of May, 2014)

Features:

  - Added Finnish translation

## 0.3.1 (16th of May, 2014)

Bugfixes:

  - Separate favorites between Helsinki and Tampere - FIXED

Features:

  - Rebranded Jopas to JollaOpas
  - Added Search-button to Search page
  - Updated About dialog
  - Smaller improvements and bugfixes

## 0.3.0 (28th of April, 2014)

Bugfixes:

  - About screen showing unsystematic exit titles - FIXED
  - Change margin field name hidden in the settings - FIXED
  - Favorites selection showing only top 7 - FIXED
  - Change the name of the action to apply the initial settings - FIXED
  - The walking speed setting should tell also the speed - FIXED
  - Route selection view is unclear - FIXED

Features:

  - Added proper Cover page with Search information
  - Added possibility to wipe Search fields
  - Added 4 favorite routes to Search page, separated between cities
  - Added possibility to search one saved route from Cover action
  - Added possibility to share route details via Clipboard
  - Reorganized menus

## 0.2.0 (14th of January, 2014)

Bugfixes:

  - Jopas does not start - shows white screen.  FIXED
  - Cannot change active region 

Features: 

  - Rewritten About dialog
  - All version strings now automatically updated from yaml
  - Removed "Jopas" header from main page to fit all content to view port even
    when keyboard is visible 

## 0.1.0 (26th of December, 2013)

  - Initial release 
