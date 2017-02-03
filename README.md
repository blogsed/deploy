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
5. Make a deployment using `bin/blogs-deploy`.
6. Create an AWS Lambda using the [`LambdaHandler`](config/aws_lambda.rb) class. Two triggers are supported:
  - CloudWatch Scheduled Events
  - SNS GitHub notifications
7. Build a JAR archive for AWS Lambda with `rake`
7. Push the JAR to AWS Lambda using `rake deploy`
