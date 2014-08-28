module RestfulObjects
  class HttpResponse
    attr_accessor :body, :content_type, :status

    def initialize(body, content_type, status = 200)
      @body = body
      @content_type = content_type
      @status = status
    end
  end
end
