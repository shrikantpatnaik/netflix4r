class EpisodeBuilder
  def self.from_xml(xml)
    return [] unless xml

    noko_xml = Nokogiri.XML(xml)

    noko_xml.xpath('//catalog_title')
  end
end