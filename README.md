# General

The API end point is at https://glacial-badlands-76799.herokuapp.com/api/v1/.

The API documentation is at https://glacial-badlands-76799.herokuapp.com/apidoc.

The database design is at https://drive.google.com/file/d/14d8_LucGrCv5nJnTJ52IZyyIbZcyxXQH/view?usp=sharing.

# API structure

All API responses have a `response_code` and `response_message`.

Use the `response_code` to navigate appropriately on the client side. Display the `response_message` to the users whenever required to provide feedback.

# Model Concept

Most of the "action" is this project is done via `ActiveRecord` callbacks.

As such, exceptions are used extensively to not only stop the propagation of all `ActiveRecord` transactions, but also trigger a reaction in the controller.

## User

The user's `account_no` is a virtual attribute derived from the primary key, which itself guarantees uniqueness.

A user's `balance` is a virtual attribute derived from `amount` and `escrow`.

The money a user has in his/her account is split into to 2 attributes to fulfill the requirement of deducting the fee only on return and prevent users from borrowing more than what they can afford.

Hence, the design is to process the loan fee using the concept of escrow.

## Book

A `loans_count` is used to collect the historical total loans a book has undergone using `Rails` mechanism. `borrow_count` is a virtual attribute and only shows the number of copies of the book a particular user is currently loaning.

`quantity` holds the number of book available for loaning. It will change accordingly as users borrow and return the books.

## Loan

During a borrow transaction, the fee is base on a constant value stored as an application config constant in `application.rb`.

Loan holds an `amount` value to keep track of how much the transaction fee was at the point of transaction. Should the value of the transaction fee constant change while the loan is still active (ie book has not been returned), the previous transaction fee bearing the old value will be correctly subtracted when the book gets returned. This maintains integrity of the data.

`borrow_at` and `return_at` note the time of transactions.

The `borrow_at` timestamp will determine the correct loan to operate on during a return transaction should the user loan the same book multiple times.

# Deployment

### Heroku

Install heroku accounts plugin to deploy to different accounts
```
heroku plugins:install heroku-accounts
heroku accounts:add <client>
heroku accounts:set <client>
```

Use heroku for deployment.

Login heroku cli
```
heroku login
```

Create heroku app for ekh
```
heroku create --remote ekh
```

View heroku application information
```
heroku info --remote ekh
```

Add cleardb addon for mysql. This requires verification on heroku by adding credit card details. Then setup the configurations. Refer to [here](https://devcenter.heroku.com/articles/cleardb) for more information.

```
heroku addons:add cleardb:ignite --remote ekh
heroku config --remote ekh | grep CLEARDB_DATABASE_URL

# convert to mysql2 based on gem used
heroku config:set DATABASE_URL='mysql2://<CLEARDB_DATABASE_URL>' --remote ekh
heroku config:set CLEARDB_DATABASE_URL='mysql2://<CLEARDB_DATABASE_URL>' --remote ekh
```

Set environment
```

heroku config:set RAILS_ENV=production --remote ekh
heroku config:set RACK_ENV=production --remote ekh
```

Deployment
```
git push ekh master
```

Migrate and seed
```

heroku run rake db:migrate --remote ekh
heroku run rake db:seed --remote ekh
```

Destroy app
```
heroku apps:destroy --remote ekh
```

**Note** that this will add remote to git in the project source code.
