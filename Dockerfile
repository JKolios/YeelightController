# Extend from the official Elixir image.
FROM elixir:1.7-alpine

# Install package dependencies
RUN apk add --no-cache --update \
        inotify-tools \
        nodejs npm yarn

# Create app directory and copy the Elixir projects into it.
RUN mkdir /app
COPY . /app

# Compile npm assets
WORKDIR /app/assets
RUN npm install

# Return to the application root dir
WORKDIR /app

# Install Hex package manager.
# By using `--force`, we don’t need to type “Y” to confirm the installation.
RUN mix local.hex --force

# Get all dependencies
RUN mix deps.get

# Force update rebar
RUN mix local.rebar --force

# Compile the project.
RUN mix do compile

EXPOSE 4000

CMD ["/usr/local/bin/mix", "phx.server"]