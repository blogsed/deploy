# BLOGS Deploy

Deploys the [BLOGS website](http://blogs.org.uk) to GitHub Pages.

Fetches data from external services like Facebook, then pushes to master on
[blogsed/blogs.org.uk](https://github.com/blogsed/blogs.org.uk).

The data is updated every hour, and when a webhook is triggered.
The webhook allows immediate builds when the GitHub repository is changed.

## Installing

1. Ensure you have the [correct Ruby version](.ruby-version) and [Bundler](http://bundler.io) installed
2. Clone the repository
3. Change into the project directory
4. Run `bundle` to install dependencies
5. Set up a Cron job to run [deploy.sh](deploy.sh) every hour
6. Start the web server with `bundle exec rackup`
7. Configure a GitHub webhook to the web server.
