module RestfulObjects
  module Router
    module SupportingResources
      def self.registered(router)
        # B.5 Homepage
        router.get '/' do
          model.get_homepage
        end

        # B.6 User
        router.get '/user' do
          model.get_user_as_json
        end

        # B.7 Services
        router.get '/services' do
          model.get_services
        end

        # B.8 Version
        router.get '/version' do
          model.get_version
        end

        # B.9 Objects of Type Resource
        router.post '/objects/:domain_type' do
          model.types[params[:domain_type]].post_prototype_object(request.body.read)
        end
      end
    end
  end
end

