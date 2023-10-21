# frozen_string_literal: true

class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  # Adds behaviors for hyrax-doi plugin.
  include Hyrax::DOI::DOIBehavior
  # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::Hyrax::BasicMetadata
  include IiifPrint.model_configuration(
    pdf_split_child_model: self
  )

  validates :title, presence: { message: 'Your work must have a title.' }

  self.indexer = GenericWorkIndexer
end
