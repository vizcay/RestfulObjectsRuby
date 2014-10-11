module RestfulObjects
  class User
    include RestfulObjects::LinkGenerator

    attr_reader :base_url, :user_name
    attr_accessor :friendly_name, :email

    def initialize(base_url, user_name)
      @base_url = base_url
      @user_name = user_name
      @friendly_name = ''
      @email = ''
      @roles = Array.new
    end

    def add_role(role)
      @roles.push(role)
    end

    def get_as_json
      { 'links' => [ gen_link('self', '/user', 'user'), gen_link('up', '/', 'homepage') ],
        'userName' => @user_name,
        'friendlyName' => @friendly_name,
        'email' => @email,
        'roles' => @roles,
        'extensions' => {}
      }.to_json
    end
  end
end

