module RestfulObjects::LinkGenerator
  HTTP_OK = 200

  def link_to(rel, href, type, options = {})
    link = {
      'rel' => generate_rel(rel, options),
      'href' => RestfulObjects::DomainModel.current.base_url + href,
      'type' => generate_repr_type(type, options[:domain_type], options[:element_type]),
      'method' => options[:method] || 'GET' }

    link['arguments'] = options[:arguments] if options[:arguments]

    link
  end

  def generate_rel(rel, options = {})
    if [:self, :up, :next, :previous, :icon, :help].include?(rel)
      rel.to_s
    elsif rel == :described_by
      'describedby'
    else
      if [:action, :action_param, :collection, :delete, :domain_type, :domain_types, :element, :element_type, :persist,
          :property, :return_type, :services, :update, :user, :version].include?(rel)
        'urn:org.restfulobjects:rels/' + underscore_to_hyphen_string(rel)
      else
        'urn:org.restfulobjects:rels/' +
          case rel
            when :add_to
              'add-to;collection="' + options[:collection] + '"'
            when :attachment
              'attachment;property="' + options[:property] + '"'
            when :choice
              if options[:property]
                'choice;property="' + options[:property] + '"'
              elsif options[:action]
                'choice;action="' + options[:action] + '"'
              elsif options[:param]
                'choice;param="' + options[:param] + '"'
              else
                raise 'option not found for choice rel'
              end
            when :clear
              'clear;property="' + options[:property] + '"'
            when :details
              if options[:property]
                'details;property="' + options[:property] + '"'
              elsif options[:collection]
                'details;collection="' + options[:collection] + '"'
              elsif options[:action]
                'details;action="' + options[:action] + '"'
              else
                raise 'option not found for details rel'
              end
            when :invoke
              if options[:action]
                'invoke;action="' + options[:action] + '"'
              elsif options[:type_action]
                'invoke;typeaction="' + options[:type_action] + '"'
              else
                raise 'option not found for invoke rel'
              end
            when :modify
              'modify;property="' + options[:property] + '"'
            when :remove_from
              'remove-from;collection="' + options[:collection] + '"'
            when :service
              'service;serviceId="' + options[:service_id] + '"'
            when :value
              if options[:property]
                'value;property="' + options[:property] + '"'
              elsif options[:collection]
                'value;collection="' + options[:collection] + '"'
              else
                raise 'option not found for value rel'
              end
            else
              raise "rel invalid: #{rel}"
          end
      end
    end
  end

  def generate_repr_type(type, domain_type = nil, element_type = nil)
    valid_repr = [:homepage, :user, :version, :list, :object, :object_property, :object_collection, :object_action,
     :object_result, :action_result, :type_list, :domain_type, :property_description, :collection_description,
     :action_description, :action_param_description, :type_action_result, :error, :services]

    raise "repr-type invalid: #{type.to_s}" if not valid_repr.include?(type)

    repr = 'application/json;profile="urn:org.restfulobjects:repr-types/' + underscore_to_hyphen_string(type) + '"'

    if domain_type && [:object, :action].include?(type)
      repr += ';x-ro-domain-type="' + domain_type + '"'
    elsif element_type && [:object_collection, :action].include?(type)
      repr +=';x-ro-element-type="' + element_type + '"'
    end

    repr
  end

  def underscore_to_hyphen_string(symbol)
    symbol.to_s.sub('_', '-')
  end

  def ro_content_type_for_object(domain_type)
    "application/json;profile=\"urn:org.restfulobjects:repr-types/object\";x-ro-domain-type=\"#{domain_type}\""
  end

  def ro_content_type_for_property
    "application/json;profile=\"urn:org.restfulobjects:repr-types/object-property\""
  end

  def ro_content_type_for_object_collection(element_type)
    "application/json;profile=\"urn:org.restfulobjects:repr-types/object-collection\";x-ro-element-type=\"#{element_type}\""
  end
end
