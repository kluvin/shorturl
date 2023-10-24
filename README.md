# URL shortener

* get `/` shows a sign of life
* get `/*` (matched first, thus excluding `api` looks for a redirect)
* post `api/redirect/new` sets a new redirect | (takes JSON = {url: <string>, type: <optional ["b62" | "bankid"]>})
* post `api/user/new` creates a user | (takes JSON = {email: <string>, password: <string>}). Don't insert a sensitive password.

Notably, API endpoints correspond to plugs and tables. 

We are using Basic Auth, other authentication mechanisms might be considered if the requirements are known.

## Choices

The choice of using Elixir was decided by a fun-factor. If you squint enough, Ecto + Plug is mostly equivalent to a Python Flask + SQLAlchemy app.

The only large up-front concern I have is speed.

* **Requirement** A redirect should always be served in well under 100ms.[^1]
  * **Solution** SQLite. Using a client/server database with something like redis was an option, but this convoluted and heavy. Redis could be used in isolation but SQLite wins in portability and having persistence as a first-class citizen. Generally, I want my requests to be handled by one machine only.

Going the common Phoenix route was considered, but there is inevitably more boilerplate. Phoenix is transparently using the same dependencies however, so a migration (should be) trivial. The app is deployed on fly.io which invests a lot into to Elixir ecosystem, but generally they will take any Docker image. Lastly, the coolest thing about URL shorteners is the links they create. I am going to have a pluggable architecture for these in the back of my mind[2].

# Post implementation-notes

Plug does not even try to suggest ways of organizing the app, and we can that strucutere changed a little over time.

To note, this was a first of doing a few things, and I haven't written any Elixir except for the exercises from a book over year ago.

The notes for the challenge state to pay attention to architecture, design-patterns, and so forth. I don't think that either of these become very relevant in the 16 hours of creating what is reduced to a web-server and a (hopefully) persisted lookup-table; the important thing is to keep dependencies limited and doors open.

## Unaddressed issues

* My understanding was initially that there was no "views", however, the redirect turns out to very much a view. Now it's a 'different' plug `redirect_dispatch`, but we could set up folders `/api` or `/views` to properly segragate.
* The above point extends to a more general pattern wherein certain organizational changes become obvious, and you think that if we just keep working we will eventually come full circle to the structure of a generaeted Phoenix app.
* There's some discrepancies in the naming of modules. There are other things I'd do differently, but we had to hit time, especially when we got to the user stuff, fast decisions were made.
* `plugs/redirect.ex` We ought to initialize the wordlists at startup.
* More tests, plus setup and their database interaction
* Error-handling in user related parts of the app
* Documentation for the endpoints, right now I will put it is in the readme
* There's a reference to `b62` which does not look to be effective. I suspect a related bug where the `bankid` style shortener does not activate, and accordingly we have misleading test. As such, this would be fixed by reading the value and not checking for existence.
* As a sidenote to above, we should store a `type` column on the `redirect` table.

## Comments on earlier statements

1. Post implementation I realize the domininant factor is still the internet connection, but I presume the application is operating under this constraint.
2. This was a bad idea, as I added an additional requirement. I still believe the idea was fun but it did add stress to reach the timeline.