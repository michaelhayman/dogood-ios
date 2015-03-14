Do Good iOS App
======

Introduction
---

Welcome to the repository for the Do Good iOS App.

Do Good is a not-for-profit organization which seeks to increase the amount
of social good in the world by making people more aware of opportunities
available near them and by rewarding people for doing socially responsible
and honorable things.  In turn it is hoped this will inspire more people to do good.

It consists of a Web site, an iOS app and an API.  It was written over a
period from June 2013 to July 2014.  Recently the app was updated with more test
coverage and to fix a few changes that came with the iOS 8 SDK, notably
around location permissions.

Installation instructions
---

1. Clone the repository and go to it in the terminal
2. Install cocoapods by running `gem install cocoapods`
3. Run `pod install`
4. Open `DoGood.xcworkspace`
5. Verify that the app runs in the simulator

Test coverage
---

The following classes have close to 100% test coverage for demonstration purposes:

- `DGGoodCommentsViewController`
- `DGComment`
- `CommentCell`
- `DGExploreCategoriesViewController`
- `DGLocator`
- `GoodTableView`
- `NoResultsCell`

Models are also tested.

Test coverage for the rest of the app is a work-in-progress.

Feel free to submit a pull request with tests for existing code.

Press `⌘+u` to run the test suite after the app has been set up in Xcode.

Test methodology
---

The following packages are used for testing:

- XCTest is the testing framework provided by Xcode 5+;
- OCMock is a stub and mocking library;
- OHHTTPStub replaces network requests at the Cocoa level to allow for a
  minimum amount of method-based stubbing;
- KIF tests the user interface with acceptance tests (coming soon)

The tests have been kept simple for maintainability.
As such a minimum of testing packages are used (in contrast with a lot of test packages
like Specta, Kiwi, etc, which are better suited to larger teams of developers).

Features
---

Do Good is a fully-featured social network site.  As such, it includes:

* Posts
* Find nearby posts using GPS
* User profiles (biography, sign in, sign out, etc)
* Activity feeds
* Comments
* Likes
* Follows
* Hash tags
* Detective typing in EntityHandler, e.g. start typing `@` and a list of users will pop up;
 start typing `#` and a list of trending hash tags will pop up
* Photo uploads
* Find friends on Twitter, Address Book, Facebook
* Post to Twitter when you make a post
* Gain points & notoriety for votes
* Invite a friend
* Redeem rewards

To do
---

* Increase test coverage
* Stub out all network traffic by creating a subclass of \`XCTestCase\`
* Add Tab-based layout
* Activity feed tailored to the user instead of a category listing on homepage
* Make nomination process more user-friendly
* Add content
* Promote

How to contribute
---

We love PRs.

If you fix a bug or know of a useful feature to add, please submit a pull request
with test coverage.

API
---

The iOS app connects to the Do Good API, which is written in Ruby and has 100%
test coverage.  The API can be viewed in a separate repository on request.

Credits
---

Code, concept & UI: Michael Hayman

Graphic Design: Sam McLoughlin

License
---

The source code for Do Good is private and must not be redistributed without
explicit permission from Michael Hayman.

Contact
---

Please contact <michael@springbox.ca> if you have any issues installing
the app or if you would like for licensing permission.

