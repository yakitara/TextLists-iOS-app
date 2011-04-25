TextLists iOS App
=================


Notes for a Developer
---------------------
=== Alter "WebServiceURL" defaults
The server URL which the app synchronize with is specified as a user defaults by key "WebServiceURL".
The default value for the key is "http://textlists.yakitara.com/" (in AppDefaults.plist).
On development or debug, you should alter the value for the key by adding a 
"Arguments Passed On Launch" in Xcode scheme editing like this:
    -WebServiceURL http://localhost:3000/

=== TextListsTest cannot run on iOS version prior to 4.3
Because imp_implementationWithBlock() is only available iOS 4.3 or lator



Release Instruction
-------------------
- Be sure that supported version of iOS is suitable (the lower the better)
- Be sure that the status of a version of the app is "Wating For Upload" in iTunes Connect
- Choose "TextLists | iOS Device" scheme from Xcode 4 toolbar
- Open Scheme Editing Dialog -> Archive
  - Option + click left most button on Xcode 4 (pressing Option key to reveal "Archive" button)
  - Select "Archive"
  - Build Configuration: "AppStore"
  - Be sure that "Reveal Archive in Organizer" is checked.
  - Click "Archive"
- Submit the archive from Organizer
  - Choose the right signing identity (maybe "items app store")






Histories
---------
= 0.3 (2011-XX-XX)
* App icons refreshed (retina icon has been added!)
* Synchronizing speed improved
* Reveal version number in Settings

= 0.2 (2010-08-05)
* Fix inconsistency about list order when a new list is added.
* Moving a item to another list makes the item as top of the list (before this change, the position of a moved item taking over from the former list).

= 0.1 
* The first release
