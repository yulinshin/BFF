
# BFF

*Title Banner*


An all-in-one application helps pet owners with pet management.
Recode Pets' life by writing a diary with photos.
# Fetures

## Create pet information and start to write a pet's life diary.
Quickly find the diary of a specific pet, pet photos are no longer scattered everywhere in the mobile phone album. 


## Mange  Pets’ supplies and set reminders.
By entering the inventory and daily consumption to create supply. The app will calculate the inventory daily and push the notification to the user’s phone when the supplies are lower than the set inventory. // with Photo

The user only needs to enter the added number, and the system will automatically adjust the inventory // gif


## Share Pets’ diaries on Pet Community.

The interaction in the pet community is pet-to-pet, can leave comments or like other's diaries.
// with Photo

If the user wants to contact the owner of the pet, can also make a private message
// with Photo

## Quickly find the nearby animal hospital.
The interaction in the pet community is pet-to-pet, can leave comments or like other's diaries.
// with Photo

When a pet has an emergency health condition, the user can quickly find nearby pet hospitals, including hospitals with special pets.
// with Photo



# Techniques:
* Use MVVM architectural pattern to enhance the maintainability, improve testability, and slim down code. 
* Implement Observer pattern to create custom data binding to set up a connection between View and ViewModel. 
* Import Firebase as a database to store users’ info, picture, and authentication data. 
* Apply UICollectionViewCompositionalLayout to establish the complex UI with UICollectionViewDiffableDataSource efficiently manage updates to the view’s data and UI. 
* Notify the status of pet supplies inventory to the user by using Local UserNotification. 
* Implement Sign in with Apple to get users’ info and create users’ data in the database. 
* Collect animal hospital info including exotic animal veterinary hospital and save the data on Google Cloud Platform to provide API for application which use on Search nearby hospital function. 
* Monitor and react to network changes by using Network Framework. 


