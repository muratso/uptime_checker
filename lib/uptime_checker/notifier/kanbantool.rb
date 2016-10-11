require "albatross-admin-client"
module UptimeChecker
  module Notifier
    class Kanbantool
      
      def self.init_albatross_client
        return if @albatross_initialized
        @albatross_initialized = true
        Albatross::Admin::Client.endpoint = "http://sda.saude.gov.br/albatross-admin/"
        Albatross::Admin::Client.token = 'p5aDsTlKxmZ9dsYHarucLCb0VbviNnA2'
      end

      def self.enabled?
        Config.kanbantool_api_token
      end

      def self.id
        "kanbantool"
      end

      def self.notify(subject, message, options)
        board_id = options[:kanbantool]['board_id']
          if options[:state] == :warning
            init_albatross_client
            incident = Albatross::Admin::Client::Incident.new
            incident.description = "<div>#{subject}  - #{message}<br>Favor verificar a possível causa do incidente.</div>"
            incident.start = options[:ptime]
            application = Albatross::Admin::Client::Application.select(:id).where(slug: options[:name]).first
            incident.relationships[:application] = application
            incident.relationships[:'incident-category'] = Albatross::Admin::Client::IncidentCategory.new(id: 6)

            if incident.save
              params = {
                  api_token: Config.kanbantool_api_token,
                  name: "#{subject} - #{Time.current}",
                  description: "#{message}<br>A aplicação ainda não tinha retornado até o momento da abertura do chamado.<br>http://sda.saude.gov.br/albatross-admin/incidents/#{incident.id}",
                  workflow_stage_id: options[:kanbantool]['workflow_stage_id'],
                  card_type_id: options[:kanbantool]['card_type_id'],
              #    assigned_user_id: options[:kanbantool]['assigned_user_id'],
                  swimlane_id: options[:kanbantool]['swimlane_id'],
                  custom_field_1: "Não"
              }
            else
              params = {
                  api_token: Config.kanbantool_api_token,
                  name: "#{subject} - #{Time.current}",
                  description: "#{message}</br>A aplicação ainda não tinha retornado até o momento da abertura do chamado. </br> Não foi aberto incidente no albatross. Não foi possível encontrar a referência da aplicação",
                  workflow_stage_id: options[:kanbantool]['workflow_stage_id'],
                  card_type_id: options[:kanbantool]['card_type_id'],
              #    assigned_user_id: options[:kanbantool]['assigned_user_id'],
                  swimlane_id: options[:kanbantool]['swimlane_id'],
                  custom_field_1: "Não"
              }
            end
            HttpClient.post("https://xys.kanbantool.com/api/v1/boards/#{board_id}/tasks.xml", params)
          end

        #elsif options[:state] == :warning
        #  params = {
        #      api_token: Config.kanbantool_api_token,
        #      name: subject,
        #      description: message,
        #      workflow_stage_id: options[:kanbantool]['workflow_stage_id'],
        #      card_type_id: options[:kanbantool]['card_type_id'],
        #      #    assigned_user_id: options[:kanbantool]['assigned_user_id'],
        #      swimlane_id: options[:kanbantool]['swimlane_id'],
        #      custom_field_1: "Não"
        #  }
        #  HttpClient.post("https://xys.kanbantool.com/api/v1/boards/#{board_id}/tasks.xml", params

      end
    end
  end
end
