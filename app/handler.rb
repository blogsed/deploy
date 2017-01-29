class Handler
  def call(event, context)
    yield "failed" unless system "app/deploy.sh"
  end
end
