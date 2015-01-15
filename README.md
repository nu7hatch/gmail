# Gmail for Ruby

[![Build Status](https://travis-ci.org/nu7hatch/gmail.png)](https://travis-ci.org/nu7hatch/gmail)
[![Code Climate](https://codeclimate.com/github/nu7hatch/gmail.png)](https://codeclimate.com/github/nu7hatch/gmail)

A Rubyesque interface to Google's Gmail, with all the tools you'll need. Search, 
read and send multipart emails, archive, mark as read/unread, delete emails, 
and manage labels.

It's based on Daniel Parker's ruby-gmail gem. This version has more friendly
API, is well tested, better documented and have many other improvements.

## Installation

You can install it easy using rubygems:

    sudo gem install gmail
    
Or install it manually:

    git clone git://github.com/nu7hatch/gmail.git
    cd gmail
    rake install

gmail gem has the following dependencies (with Bundler all will be installed automatically):

* mail (Ruby 1.8.7 users should lock mail gem version at 2.5.3)
* mime
* gmail_xoauth
* smpt_tls (Ruby < 1.8.7)

## Features

* Search emails
* Read emails (handles attachments)
* Emails: label, archive, delete, mark as read/unread/spam, star
* Manage labels
* Create and send multipart email messages in plaintext and/or html, with inline 
  images and attachments
* Utilizes Gmail's IMAP & SMTP, MIME-type detection and parses and generates 
  MIME properly.

## Basic usage

First of all require the `gmail` library.

    require 'gmail'
    
### Authenticating gmail sessions

This will let you automatically log in to your account. 

    gmail = Gmail.connect(username, password)
    # play with your gmail...
    gmail.logout

If you pass a block, the session will be passed into the block, and the session 
will be logged out after the block is executed.

    Gmail.connect(username, password) do |gmail|
      # play with your gmail...
    end
    
Examples above are "quiet", it means that it will not raise any errors when 
session couldn't be started (eg. because of connection error or invalid 
authorization data). You can use connection which handles errors raising:

    Gmail.connect!(username, password)
    Gmail.connect!(username, password) {|gmail| ... play with gmail ... }
    
You can also check if you are logged in at any time:

    Gmail.connect(username, password) do |gmail|
      gmail.logged_in?
    end

### XOAuth authentication

From v0.4.0 it's possible to authenticate with your Gmail account using XOAuth
method. It's very simple:

    gmail = Gmail.connect(:xoauth, "email@domain.com", 
      :token           => 'TOKEN',
      :secret          => 'TOKEN_SECRET',
      :consumer_key    => 'CONSUMER_KEY',
      :consumer_secret => 'CONSUMER_SECRET'
    )
    
For more information check out the [gmail_xoauth](https://github.com/nfo/gmail_xoauth)
gem from Nicolas Fouché.

### Counting and gathering emails
    
Get counts for messages in the inbox:

    gmail.inbox.count
    gmail.inbox.count(:unread)
    gmail.inbox.count(:read)

Count with some criteria:

    gmail.inbox.count(:after => Date.parse("2010-02-20"), :before => Date.parse("2010-03-20"))
    gmail.inbox.count(:on => Date.parse("2010-04-15"))
    gmail.inbox.count(:from => "myfriend@gmail.com")
    gmail.inbox.count(:to => "directlytome@gmail.com")

Combine flags and options:

    gmail.inbox.count(:unread, :from => "myboss@gmail.com")
    
Browsing labeled emails is similar to work with inbox.

    gmail.mailbox('Urgent').count
    
Getting messages works the same way as counting: Remember that every message in a 
conversation/thread will come as a separate message.

    gmail.inbox.emails(:unread, :before => Date.parse("2010-04-20"), :from => "myboss@gmail.com")

The [gm option](https://developers.google.com/gmail/imap_extensions?csw=1#extension_of_the_search_command_x-gm-raw) enables use of the Gmail search syntax.

    gmail.inbox.emails(gm: '"testing"')

You can use also one of aliases:

    gmail.inbox.find(...)
    gmail.inbox.search(...)
    gmail.inbox.mails(...)    
    
Also you can manipulate each message using block style:

    gmail.inbox.find(:unread).each do |email|
      email.read!
    end
    
### Working with emails!

Any news older than 4-20, mark as read and archive it:

    gmail.inbox.find(:before => Date.parse("2010-04-20"), :from => "news@nbcnews.com").each do |email|
      email.read! # can also unread!, spam! or star!
      email.archive!
    end

Delete emails from X:

    gmail.inbox.find(:from => "x-fiance@gmail.com").each do |email|
      email.delete!
    end

Save all attachments in the "Faxes" label to a local folder (uses functionality from `Mail` gem):

    folder = Dir.pwd # for example
    gmail.mailbox("Faxes").emails.each do |email|
      email.message.attachments.each do |f|
        File.write(File.join(folder, f.filename), f.body.decoded)
      end
    end
     
You can use also `#label` method instead of `#mailbox`: 

    gmail.label("Faxes").emails {|email| ... }

Save just the first attachment from the newest unread email (assuming pdf):

    email = gmail.inbox.find(:unread).first
    email.attachments[0].save_to_file("/path/to/location")

Add a label to a message:

    email.label("Faxes")
    
Example above will raise error when you don't have the `Faxes` label. You can 
avoid this using:

    email.label!("Faxes") # The `Faxes` label will be automatically created now

You can also move message to a label/mailbox:
 
    email.move_to("Faxes")
    email.move_to!("NewLabel")
    
There is also few shortcuts to mark messages quickly:

    email.read!
    email.unread!
    email.spam!
    email.star!
    email.unstar!

### Managing labels

With Gmail gem you can also manage your labels. You can get list of defined 
labels:

    gmail.labels.all

Create new label:
  
    gmail.labels.new("Urgent")
    gmail.labels.add("AnotherOne")
    
Remove labels:

    gmail.labels.delete("Urgent")
    
Or check if given label exists:

    gmail.labels.exists?("Urgent") # => false
    gmail.labels.exists?("AnotherOne") # => true

Localize label names using the LIST special-use extension flags,
:Inbox, :All, :Drafts, :Sent, :Trash, :Important, :Junk, and :Flagged

    gmail.labels.localize(:all) # => "[Gmail]\All Mail"
                                # => "[Google Mail]\All Mail"

### Composing and sending emails

Creating emails now uses the amazing [Mail](http://rubygems.org/gems/mail) rubygem. 
See its [documentation here](http://github.com/mikel/mail). The Ruby Gmail will 
automatically configure your Mail emails to be sent via your Gmail account's SMTP, 
so they will be in your Gmail's "Sent" folder. Also, no need to specify the "From" 
email either, because ruby-gmail will set it for you.

    gmail.deliver do
      to "email@example.com"
      subject "Having fun in Puerto Rico!"
      text_part do
        body "Text of plaintext message."
      end
      html_part do
        content_type 'text/html; charset=UTF-8'
        body "<p>Text of <em>html</em> message.</p>"
      end
      add_file "/path/to/some_image.jpg"
    end

Or, compose the message first and send it later

    email = gmail.compose do
      to "email@example.com"
      subject "Having fun in Puerto Rico!"
      body "Spent the day on the road..."
    end
    email.deliver! # or: gmail.deliver(email)

## Troubleshooting

If you are having trouble connecting to Gmail:
* Please ensure your account is verified
* In [Gmail Security Settings](https://www.google.com/settings/security), enable access for less secure applications.
* Read [this support answer re: suspicious activity](https://support.google.com/mail/answer/78754) and try things like entering a captcha.

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Author(s)

* Kriss 'nu7hatch' Kowalik
* [Daniel Parker of BehindLogic.com](http://github.com/dcparker)

Extra thanks for specific feature contributions from:

* [abhishiv](http://github.com/abhishiv)
* [Michael Young](http://github.com/myoung8)
* [Nicolas Fouché](http://github.com/nfo)
* [Stefano Bernardi](http://github.com/stefanobernardi)
* [Benjamin Bock](http://github.com/bb)
* [Arthur Chiu](http://github.com/achiu)
* [Justin Perkins](http://github.com/justinperkins)
* [Mikkel Malmberg](http://github.com/mikker)
* [Julien Blanchard](http://github.com/julienXX)
* [Federico Galassi](http://github.com/fgalassi)
* [Alex Genco](http://github.com/alexgenco)
* [Justin Grevich](http://github.com/jgrevich)
* [Johnny Shields](http://github.com/johnnyshields)

## Copyright

* Copyrignt (c) 2010 Kriss 'nu7hatch' Kowalik
* Copyright (c) 2009-2010 BehindLogic

See LICENSE for details.

