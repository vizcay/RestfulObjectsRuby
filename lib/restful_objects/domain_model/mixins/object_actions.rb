module RestfulObjects::ObjectActions
  def ro_get_action_type(name)
    ro_domain_type.actions[name]
  end

  def ro_get_action_response(name)
    { 'id' => name,
      'parameters' => generate_parameters(name),
      'links' => [ rs_action_link(name), rs_action_up_link, rs_invoke_link(name) ],
      'extensions' => ro_get_action_type(name).metadata
    }.to_json
  end

  def ro_parse_action_arguments(name, arguments, json)
    result = []
    ro_get_action_type(name).parameters.each do |name, parameter|
      case parameter.type
        when :int
          result << arguments[name.to_s]['value'].to_i
        else
          result << arguments[name.to_s]['value']
      end
    end
    result
  end

  def ro_encode_action_result

  end

  def ro_invoke_action_and_get_response(name, json)
    raise 'action does not exists' unless ro_get_action_type(name)

    arguments = json == '' ? {} : JSON.parse(json)

    result = send(name, *ro_parse_action_arguments(name, arguments, json))

    action_link = link_to(:self, "/objects/#{self.class.name}/#{object_id}/actions/#{name}/invoke", :action_result)
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

    response['resultType'] = ro_get_action_type(name).kind_result_type.to_s
    if result.nil?
      response['result'] = nil
    else
      case ro_get_action_type(name).kind_result_type
        when :scalar
          response['resultType'] = 'scalar'
          response['result']['value'] = encode_value(result, ro_get_action_type(name).result_type)
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
            [ link_to(:element_type, "/domain-types/#{ro_get_action_type(name).result_type.to_s}", :domain_type) ]
          list = []
          result.each do |member|
            member_link = link_to(:element, "/objects/#{ro_get_action_type(name).result_type.to_s}/#{member.ro_instance_id}", :object)
            member_link['title'] = member.ro_title
            list << member_link
          end
          response['result']['value'] = list
      end
    end

    response.to_json
  end

#   def action_return_type(name)
#     ro_get_action_type(name).result_type
#   end

  protected

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

  def generate_parameters(action_name)
    result = {}
    ro_get_action_type(action_name).parameters.each do |name, parameter|
      result[name] = { 'links' => [], 'extensions' => parameter.metadata }
    end
    result
  end

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
