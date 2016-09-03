module RestfulObjects
  module ObjectActions
    def actions_members
      members = {}
      ro_domain_type.actions.each do |name, action|
        members[name] = {
          'memberType' => 'action',
          'links' => [
            !ro_is_service? ?
              link_to(:details, "/objects/#{self.class.name}/#{object_id}/actions/#{name}", :object_action, action: name)
              :
              link_to(:details, "/services/#{self.class.name}/actions/#{name}", :object_action, action: name)
          ],
          'extensions' => action.metadata
        }
      end
      members
    end

    def get_action(action)
      { 'id' => action,
        'parameters' => generate_parameters(action),
        'links' => [ rs_action_link(action), rs_action_up_link, rs_invoke_link(action) ],
        'extensions' => ro_domain_type.actions[action].metadata
      }.to_json
    end

    def generate_parameters(action)
      parameters = Hash.new
      ro_domain_type.actions[action].parameters.each do |name, parameter|
        parameters[name] = {
          'links' => [],
          'extensions' => parameter.metadata
        }
      end
      parameters
    end

    def get_action_invoke(action, json)
      raise 'action does not exists' if not ro_domain_type.actions.include?(action)
      action_description = ro_domain_type.actions[action]
      json == '' ? {} : arguments = JSON.parse(json)
      parameters = []
      action_description.parameters.each do |name, parameter|
        case parameter.type
          when :int
            parameters << arguments[name.to_s]['value'].to_i
          else
            parameters << arguments[name.to_s]['value']
        end
      end

      result = send(action.to_sym, *parameters)

      action_link = link_to(:self, "/objects/#{self.class.name}/#{object_id}/actions/#{action}/invoke", :action_result)
      action_link['arguments'] = arguments

      response = {
        'links' => [ action_link ],
        'resultType' => 'scalar',
        'result' => {
          'links' => [],
          'extensions' => { }
        },
        'extensions' => { }
      }

      response['resultType'] = action_description.kind_result_type.to_s
      if result.nil?
        response['result'] = nil
      else
        case action_description.kind_result_type
          when :scalar
            response['resultType'] = 'scalar'
            response['result']['value'] = encode_value(result, action_description.result_type)
            response['result']['links'] = [ link_to(:return_type, '/domain-types/int', :domain_type) ]
          when :object
            response['resultType'] = 'object'
            response['result'] = result.ro_get_representation
          when :proto_object
            response['resultType'] = 'object'
            response['result'] = result
          when :list
            response['resultType'] = 'list'
            response['result']['links'] =
              [ link_to(:element_type, "/domain-types/#{action_description.result_type.to_s}", :domain_type) ]
            list = []
            result.each do |member|
              member_link = link_to(:element, "/objects/#{action_description.result_type.to_s}/#{member.ro_instance_id}", :object)
              member_link['title'] = member.ro_title
              list << member_link
            end
            response['result']['value'] = list
        end
      end

      response.to_json
    end

    def action_return_type(action)
      RestfulObjects::DomainModel.current.types[self.class.name].actions[action].result_type
    end

    private

      def rs_invoke_link(action)
        invoke_link = ro_is_service? ?
          link_to(:invoke, "/services/#{ro_domain_type.id}/actions/#{action}/invoke", :action_result, action: action)
          :
          link_to(:invoke, "/objects/#{ro_domain_type.id}/#{object_id}/actions/#{action}/invoke", :action_result, action: action)
        invoke_link['arguments'] = {}
        ro_domain_type.actions[action].parameters.each do |name, action|
          invoke_link['arguments'][name] = { 'value' => nil }
        end
        invoke_link
      end

      def rs_action_link(action)
        if ro_is_service?
          link_to(:self, "/services/#{self.class.name}/actions/#{action}", :object_action)
        else
          link_to(:self, "/objects/#{self.class.name}/#{object_id}/actions/#{action}", :object_action)
        end
      end

      def rs_action_up_link
        if ro_is_service?
          link_to(:up, "/services/#{ro_domain_type.id}", :object)
        else
          link_to(:up, "/objects/#{self.class.name}/#{object_id}", :object)
        end
      end
  end
end
