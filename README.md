This is (nearly) all the code that powered FirstBargain.com until it was closed down.

FirstBargain was a penny-auction startup founded by students at Cornell University, Taichi Kasahara and Jing Hui Wang. The Ruby and JavaScript code you see here was written primarily by [Caleb Perkins](http://www.calebperkins.com), also a Cornell student. The frontend design, including images, HTML, and CSS, were written by Jing.

Server requirements
===================

* Redis
* Beanstalkd
* Ruby 1.9.2 or better
* Rails 3 (3.1 or later not supported yet)
* Rack based server

Getting started
===============

Make sure Redis and Beanstalkd are running. Run `bundle` followed by `rake db:schema:load`. Start up some workers via `lib/heartbeat start` and `lib/stalker_worker start`.

Caveats
=======

This code scaled well in production but there should be more test coverage.

License
=======

This work is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. See the LICENSE for more information.
