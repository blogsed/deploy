require "aws/lambda"
require "handler"

AWS::Lambda.functions[:handler] = Handler.new
