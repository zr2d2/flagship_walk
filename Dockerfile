# Use an official Ruby runtime as a parent image
FROM ruby:2.6.3-stretch

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in the Gemfile
RUN gem install bundler
RUN bundle install

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV NAME flagship_walk
ENV APP_ENV :test

# Run app.py when the container launches
CMD ["ruby", "flagship_walk.rb", "-p 80"]