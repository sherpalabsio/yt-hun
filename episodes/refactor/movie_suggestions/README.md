# Run the project locally with Docker

Use the make file:

```bash
# Start the stack with docker compose
make up

# Run the tests in the container
make test

# Run anything in the container
make run rspec spec/requests/movies/suggestions_controller_spec.rb:9

# Get a shell in the container
make conn

# Stop the stack
make down
```
