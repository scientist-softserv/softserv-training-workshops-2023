# frozen_string_literal: true

module Hyrax
  module Forms
    # Add new method to filter out access_grants for Collection Roles and Work Roles
    # for Collections and AdminSets, respectively. We do this because access_grants
    # for Roles should never be allowed to be removed.
    #
    # @see app/views/hyrax/dashboard/collections/_form_share_table.html.erb
    module CollectionFormDecorator
      Hyrax::Forms::CollectionForm.terms += %i[department]

      def secondary_terms
        super + %i[department]
      end

      def filter_access_grants_by_access(access)
        roles_to_filter = ::RolesService::COLLECTION_ROLES + ::RolesService::WORK_ROLES
        filtered_access_grants = permission_template.access_grants.select(&access)
        filtered_access_grants.reject! { |ag| roles_to_filter.include?(ag.agent_id) }

        filtered_access_grants || []
      end
    end
  end
end

Hyrax::Forms::CollectionForm.prepend(Hyrax::Forms::CollectionFormDecorator)
