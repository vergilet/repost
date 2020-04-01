<p align="right">
    <a href="https://github.com/vergilet/repost"><img align="" src="https://user-images.githubusercontent.com/2478436/51829223-cb05d600-22f5-11e9-9245-bc6e82dcf028.png" width="56" height="56" /></a>
<a href="https://rubygems.org/gems/repost"><img align="right" src="https://user-images.githubusercontent.com/2478436/51829691-c55cc000-22f6-11e9-99a5-42f88a8f2a55.png" width="56" height="56" /></a>
</p>

<p align="center">
    <a href="https://rubygems.org/gems/repost">
  <img width="460" src="https://user-images.githubusercontent.com/2478436/55672583-44491880-58a5-11e9-945c-939f90470df8.png"></a>
</p>

Gem **Repost** implements Redirect using POST method. 

Implementation story and some details - [Redirect using POST in Rails](https://medium.com/@momlookhowican/redirect-using-post-in-rails-5748da354343)

[![Gem Version](https://badge.fury.io/rb/repost.svg)](https://badge.fury.io/rb/repost)
[![Build Status](https://travis-ci.org/vergilet/repost.svg?branch=master)](https://travis-ci.org/vergilet/repost)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'repost'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install repost



## What problem does it solve?

When you need to send some parameters to an endpoint which should redirect you after execution. There wouldn't be a problem if an endpoint receives [GET], because you can just use `redirect_to post_url(id: @model.id, token: model.token...)`.

But when an endpoint receives [POST], you have to generate html form and submit it. So `repost` gem helps to avoid creation of additional view with html form, just use `redirect_post` method instead.
I faced with this problem when was dealing with bank transactions. You can see the approximate scheme:

<p align="center">
    <a href="https://user-images.githubusercontent.com/2478436/55143646-d0da3500-5147-11e9-91a3-1bac9d560fb2.png">
  <img src="https://user-images.githubusercontent.com/2478436/55143646-d0da3500-5147-11e9-91a3-1bac9d560fb2.png"></a>
</p>


## Usage

If you use Rails, gem automatically includes helper methods to your controllers:

```ruby
repost(...)
```
and, as an alias

```ruby
redirect_post(...)
```

*Under the hood it calls `render` method of current controller with `html:`.*

### Example in Rails app:

```ruby
class MyController < ApplicationController
  ...
  def index
    repost(...)
  end
  ...
  # or
  def show
    redirect_post(...)
  end
end
```
______________

If you use Sinatra, Roda or etc., you need to require it first somewhere in you project:

```ruby
require 'repost'
```

Then ask your senpai to generate a string with html:


```ruby
Repost::Senpai.perform(...)
```

### Example in Sinatra, Roda, etc. app:

```ruby
class MyController < Sinatra::Base
  get '/' do
    Repost::Senpai.perform(...)
  end
end
```



#### *Reminder:*

- *In Rails app use `repost` or `redirect_post` method in your controller which performs 'redirect' when it is called.*

- *In Sinatra, Roda, etc. app or if you need html output - call Senpai*


#### Full example:

*UPD: authenticity token is **turned off** by default. Use `:auto` or `'auto'` to turn on default authenticity token from Rails. Any other string value would be treated as custom auth token value.*

```ruby
# plain ruby
# Repost::Senpai.perform('http://......)


# Rails
redirect_post('http://examp.io/endpoint',           # URL, looks understandable 
  params: {a: 1, b: 2, c: '3', d: "4"},             # Your request body
  options: {
    method: :post,                                  # OPTIONAL - DEFAULT is :post, but you can use others if needed
    authenticity_token: 'auto',                     # OPTIONAL - :auto or 'auto' for Rails form_authenticity_token, string - custom token
    charset: 'Windows-1251',                        # OPTIONAL - DEFAULT is "UTF-8", corresponds for accept-charset
    form_id: 'CustomFormID',                        # OPTIONAL - DEFAULT is autogenerated
    autosubmit: false,                              # OPTIONAL - DEFAULT is true, if you want to get a confirmation for redirect  
    decor: {                                        # If autosubmit is turned off or Javascript is disabled on client
      section: {                                    # ... you can decorate confirmation section and button
        classes: 'red-bg red-text',                 # OPTIONAL - <DIV> section, set classNames, separate with space
        html: '<h1>Press this button, dude!</h1>'   # OPTIONAL - Any html, which will appear before submit button
      },
      submit: {
        classes: 'button-decorated round-border',   # OPTIONAL - <Input> with type submit, set classNames, separate with space
        text: 'c0n71nue ...'                        # OPTIONAL - DEFAULT is 'Continue'
      }
    }
  }
)

```

### Authenticity Token (Rails)

Currently you can pass the **authenticity token** in two ways:

* Recommended:

    *Use `options` and `:auto` to pass the auth token. That should protect you from any implementation changes in future Rails versions*

    ```ruby
    redirect_post('https://exmaple.io/endpoint', options: {authenticity_token: :auto})
    ```
* Or, it is still valid to:

    *use `params` and `form_authenticity_token` method directly from ActionController*
    ```ruby
    redirect_post('https://exmaple.io/endpoint', params: {authenticity_token: form_authenticity_token})
    ```



## License
The gem is available as open source under the terms of the MIT License.

Copyright © 2019 Yaro.

[![GitHub license](https://img.shields.io/badge/license-MIT-brightgreen)](https://raw.githubusercontent.com/vergilet/repost/master/LICENSE.txt)

**That's all folks.**
