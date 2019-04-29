# Spreader - A distributed work system

This is a proof of concept work for creating a distributed work system, based on a system I created with a friend under previous employment.

The prerequisites for using this project are:
* You likely already have a Database Server somewhere.
    * That server is probably already pretty beefy. You've spent good money on this thing!
    * Database servers (PostgreSQL, MySQL, MS-SQL, Oracle) already know how to effectively handle caching requests and data.
* You probably already have a Web server somewhere.
    * You're a developer, you probably know how to access your Database Server from your preferred web clients.
    * You likely already know how to keep your webpages secure, so that outsiders can't see the status of your processing system.
* You don't really want to spend money on the extra handware to spin up any other servers.
* You would really like to put a large number of low-powered machines to use for various tasks, but...
* You may not want to open a potential hole by running an Untrusted server someone created on the internet.

Anyone should have access to a distributed work system which is simple to work with!

What we'd like to do is let our awesome Database server handle the heavy lifting, by running stored procedures on our preferred flavor of database. Along with that, let people develop clients in whatever their preferred language is, since everyone likely has their own data layer they're already working with.

Overall Project Goals:
* Develop Stored Procedures for some of the most common databases (MySQL, MSSQL, PostgreSQL) to be used with our clients.
* Create Bootstrap code in Python (since that's my primary language currently) to demonstrate usage of our system.
* Create an Example Web GUI to monitor our system.
    * I'll be using .Net Core 2.2 to create the initial Reference Web GUI, since we have an abundance of IIS servers available already.
    * Our templates will be able to be modified to suit whichever server/dialect/etc you prefer, thanks to the Razor being an easy to use template engine.
    * But I'm sure someone will contribute some other Web GUIs eventually!
* Another project, [PySpreader Client Package](https://github.com/LukeCroteau/pyspreader_client_package) contains a fully built Python client, available via PyPI, and will be kept up to date with new functionality
    * I'm sure someone will create some basic clients for other languages...
