# frozen_string_literal: true

# build mods xml document: see https://www.loc.gov/standards/mods/mods-outline-3-5.html
module ModsSolrDocument
  extend ActiveSupport::Concern

  def to_oai_mods
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.mods('xmlns' => 'http://www.loc.gov/mods/v3',
               'version' => '3.5',
               'xmlns:xlink' => 'http://www.w3.org/1999/xlink',
               'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
               # rubocop:disable Metrics/LineLength
               'xsi:schemaLocation' => 'http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd') do
        # rubocop:enable Metrics/LineLength
        # titleInfo
        load_title(xml)
        # name
        load_name(xml)
        # typeOfResource
        load_type(xml)
        # identifier
        load_identifier(xml)
        # genre
        # originInfo
        load_origin(xml)
        # language
        load_language(xml)
        # physicalDescription
        load_phyical(xml)
        # tableOfContents
        # targetAudience
        # note
        # subject
        load_subject(xml)
        # relatedItem
        # location
        load_location(xml)
        # accessCondition
        load_access(xml)
        # part
        # extension
        # recordInfo
        load_record(xml)
      end
    end
    Nokogiri::XML(builder.to_xml).root.to_xml
  end

  private

    def oai_url
      @oai ||= "https://#{Site.account.cname}/catalog/oai"
    end

    # titleInfo
    def load_title(xml)
      xml.titleInfo do
        title&.each { |title| xml.title title.to_s }
        alternative_title&.each { |title| xml.title({ type: 'alternative' }, title.to_s) }
      end
    end

    # name
    def load_name(xml)
      name_terms.each do |name_term|
        send(name_term)&.each do |term|
          xml.name do
            xml.namePart(term.to_s)
            xml.role do
              xml.roleTerm("Creator")
            end
          end
        end
      end
    end

    # typeOfResource
    def load_type(xml)
      resource_type&.each { |resource_type| xml.typeOfResource(resource_type) }
    end

    # identifier
    def load_identifier(xml)
      xml.identifier({ type: 'uuid' }, self[:id])

      identifier_terms.each do |identifier_term|
        send(identifier_term)&.each do |term|
          xml.identifier({ type: identifier_term.to_s }, term)
        end
      end
    end

    # originInfo
    def load_origin(xml)
      xml.originInfo do
        date_created&.each { |value| xml.dateCreated value.to_s }
      end
    end

    # language
    def load_language(xml)
      language&.each { |language| xml.languageTerm(language.to_s) }
    end

    # physicalDescription
    def load_phyical(xml)
      xml.physicalDescription do
        extent&.each { |extent| xml.extent(extent.to_s) }
        form_terms.each do |form_term|
          send(form_term)&.each { |form| xml.form(form.to_s) }
        end
      end
    end

    # abstract
    def load_abstract(xml)
      abstract_term.each do |abstract_term|
        send(abstract_term)&.each { |term| xml.abstract term.to_s }
      end
    end

    # subject
    def load_subject(xml)
      xml.subject do
        subject_terms.each do |subject_term|
          send(subject_term)&.each { |term| xml.topic(term.to_s) }
        end
      end
    end

    # location
    def load_location(xml)
      xml.location do
        location_terms.each do |location_term|
          send(location_term)&.each { |term| xml.physicalLocation term.to_s }
        end
      end
    end

    # accessCondition
    def load_access(xml)
      access_terms.each do |access_term|
        Array.wrap(send(access_term))&.each do |access|
          xml.accessCondition(type: 'use and reproduction', valueUri: access.to_s)
        end
      end
    end

    # recordInfo
    def load_record(xml)
      xml.recordInfo do
        xml.recordIdentifier(self[:id])
        xml.recordOrigin(oai_url)
        xml.recordCreationDate(self[:system_create_dtsi])
        xml.recordChangeDate(self[:system_modified_dtsi])
      end
    end

    # terms arrays

    def abstract_terms
      %i[abstract
         description]
    end

    def identifier_terms
      %i[identifier]
    end

    def name_terms
      %i[creator
         contributor]
    end

    def form_terms
      %i[]
    end

    def subject_terms
      %i[subject
         keyword]
    end

    def location_terms
      %i[based_near]
    end

    def access_terms
      %i[rights_statement
         license]
    end
end
