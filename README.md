# SSSpider
Secure Score Spider - Get the Azure Secure Score of every subscription (in any tenant) your account can access... with enough privileges, of course.

# To Do
Lots od ToDos, here... No error handling that deserves its name, hardcoded filenames, no support for non-interactive identities... This is a very early prototype to validate the concept.

# Prerequisites
Tested with Windows PowerShell, should work with the good (v7) PowerShell. Will need the Azure Az PowerShell modules.

# How to test this
Just copy the ssspider.ps1 script to your favorite location, make sure you can execute unsigned PowerShell scripts (Set-ExecutionPolicy is your friend, choose your favorite policy if necessary), and run it. You'ii be asked for credentials (be aware that the logon window almost invariably pops up BEHIND your current window; I can assure you you'll missit the first couple of times...). After a non-trivial amount of time, the script will finish executing and you'll be presented with a file creatively called "x.csv" (I know, I know... gimme a break for now...) in your default directory.
Excel will help you visualizing it.
