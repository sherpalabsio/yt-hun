FROM mcr.microsoft.com/vscode/devcontainers/ruby:3.4

# Install Node.js and Yarn for Rails asset pipeline
# RUN su vscode -c ". /usr/local/share/nvm/nvm.sh && nvm install 18 && nvm use 18 && npm install -g yarn"

# Install additional OS packages if needed
# RUN apt-get update && apt-get install -y <package-name>

# Set working directory
WORKDIR /workspace

# Install bundler
RUN gem install bundler

# Copy Gemfile and Gemfile.lock for faster bundle install
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the app
COPY . .

# Expose Rails default port
EXPOSE 3000

# Set default command
CMD ["bash"]
