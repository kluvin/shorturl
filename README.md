# URL shortener

* get `/` shows a sign of life
* get `/*` (excluding `api` looks for a redirect)
* post `api/redirects/new` sets a new redirect (todo, authenticate route)
* post `api/user/create` creates a user

I need to talk with the user why they want to authenticate the `api/redirect/new` route out of curiosity and whether it would make sense to implement a token based login. Right now; the most simple thing is to require authentication details as JSON on request.

## Choices

The choice of using Elixir was decided by a fun-factor. If you squint enough, Ecto + Plug is mostly equivalent to a Python Flask + SQLAlchemy app.

The only large up-front concern I have is speed.

* **Requirement** A redirect should always be served in well under 100ms.
  * **Solution** SQLite. Using a client/server database with something like redis was an option, but this convoluted and heavy. Redis could be used in isolation but SQLite wins in portability and having persistence as a first-class citizen. Generally, I want my requests to be handled by one machine only.

Going the common Phoenix / Django route was considered, but there is inevitably more boilerplate. Phoenix is transparently using the same dependencies however, so a migration is trivial.

The app is deployed on fly.io which invests a lot into to Elixir ecosystem, but generally they will take Docker image.

The coolest thing about URL shorteners is the links they create. I am going to have a pluggable architecture for these in the back of my mind.