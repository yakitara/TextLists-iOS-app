TextLists iOS App
================

Developer Notes
---------------
The server URL whitch the app synchronize with is specified as a user defaults by key "WebServiceURL".
The default value for the key is "http://textlists.yakitara.com/" (in AppDefaults.plist).
You can alter the value for the key by adding a "Arguments Passed On Launch" in Xcode scheme editing like this:
    -WebServiceURL http://localhost:3000/


Histories
---------
= 0.3 (2011-XX-XX)
* App icons refreshed (retina icon has been added!)
* Synchronizing speed improved
* Version number in Settings

= 0.2 (2010-08-05)
* Fix inconsistency about list order when a new list is added.
* Moving a item to another list makes the item as top of the list (before this change, the position of a moved item taking over from the former list).

= 0.1 
* The first release
