# Extend from the official Elixir image.
FROM elixir:1.7-alpine

# Create app directory and copy the Elixir projects into it.
RUN mkdir /app
COPY . /app
WORKDIR /app

# Install Hex package manager.
# By using `--force`, we don’t need to type “Y” to confirm the installation.
RUN mix local.hex --force

# Get all dependencies
RUN mix deps.get

# Compile the project.
RUN mix do compile

EXPOSE 4000

CMD ["mix phx.server"]