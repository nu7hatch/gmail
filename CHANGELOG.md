# Gmail gem changelog

## 0.4.0

* Added XOAUTH authentication method (Thanks Stefano Bernardi and Nicolas Fouché)
* Separated clients
* Fixed specs

## 0.3.4

* Fixes in mailbox filters shortcuts (Thanks Benjamin Bock)

## 0.3.3

* Added #expunge to Mailbox (Thanks Benjamin Bock)
* Added more mailbox filters (Thanks Benjamin Bock)
* Added shortcuts for mailbox filters
* Minor bugfixes

## 0.3.2

* Added envelope fetching
* Minor bugfixes

## 0.3.0

* Refactoring
* Fixed bugs
* API improvements
* Better documentation
* Code cleanup
* RSpec for everything

## 0.1.1 / 2010-05-11

* Added explicit tmail dependency in gemspec
* Added better README tutorial content

## 0.0.9 / 2010-04-17

* Fixed content-transfer-encoding when sending email

## 0.0.8 / 2009-12-23

* Fixed attaching a file to an empty message

## 0.0.7 / 2009-12-23

* Improved multipart message parsing reliability

## 0.0.6 / 2009-12-21

* Fixed multipart parsing for when the boundary is marked in quotes.

## 0.0.5 / 2009-12-16

* Fixed IMAP initializer to work with Ruby 1.9's net/imap
* Better logout depending on the IMAP connection itself
* Added MIME::Message#text and MIME::Message#html for easier access to an email body
* Improved the MIME-parsing API slightly
* Added some tests

## 0.0.4 / 2009-11-30

* Added label creation (thanks to Justin Perkins / http://github.com/justinperkins)
* Made the gem login automatically when first needed
* Added an optional block on the Gmail.new object that will login and logout for you
* Added several search options (thanks to Mikkel Malmberg / http://github.com/mikker)

## 0.0.3 / 2009-11-19

* Fixed MIME::Message#content= for messages without an encoding
* Added Gmail#new_message

## 0.0.2 / 2009-11-18

* Made all of the examples in the README possible

## 0.0.1 / 2009-11-18

* Birthday!

