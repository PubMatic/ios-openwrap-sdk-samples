## This is an iOS tableview application written in Swift to demonstrate the use of OpenWrap SDK + TAM parallel header bidding into GAM SDK.

To use this application, you need to open the application in Xcode and run the application on iPhone  or simulator.

-  By default tableview contains 100 feed items and at every 19th interval banner ad is shown. To update these default values you need to open Constants.swift file and follow below steps

      -  Search for MAX_FEEDS constant and update its value as per your requirement
      -  To update banner interval search for AD_INTERVAL and update its value as per your requirement
      
-  By default ad unit id's are set to In-Banner Video ads with size 300x250, to update it to Display Banner you need to open Constants.swift file and update PROFILE_ID constant value to Display Banner profile id as mentioned in the inline comments.

