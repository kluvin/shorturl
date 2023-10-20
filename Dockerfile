FROM elixir:1.15.6

RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /app

COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

COPY lib lib
COPY config config
COPY priv priv
RUN mix do compile

EXPOSE 4001

CMD ["mix", "run", "--no-halt"]
