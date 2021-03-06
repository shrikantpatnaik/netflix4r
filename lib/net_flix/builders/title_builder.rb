class TitleBuilder

  def self.from_xml(xml)
    return [] unless xml

    nxml = Nokogiri.XML(xml)
    
    titles(nxml).map do |data|
      TitleBuilder.new(data).title
    end
  end

  def self.titles(noko_xml)
    titles = noko_xml.xpath('//catalog_title')
    titles.empty? ? noko_xml.xpath('//title_index_item') : titles 
  end

  def initialize(data)
    @data = data
    @title = NetFlix::Title.new

    #set_actors
    set_delivery_formats
    set_genres
    set_id
    set_release_year
    set_title
    set_web_page
    #set_box_art
    #set_runtime
    #set_mpaa_rating
    #set_synopsis
  end

  def set_id
    node = @data.search('id').first
    @title.id = node.content if node
  end

  def set_release_year
    node = @data.search('release_year').first
    @title.release_year = node.content if node
  end

  def set_title
    node = @data.search('title').first
    @title.title = node['regular'] || node.content if node
  end

  def set_web_page
    node = @data.search('link[@title="web page"]').first
    @title.web_page = node['href'] if node
  end

  def set_delivery_formats
    @title.delivery_formats = FormatBuilder.from_movie(@data)
  end

  def set_genres
    @title.genres = @data.search('category[@scheme="http://api.netflix.com/categories/genres"]').map{|f| f['label'] }
  end

  def set_actors
    @title.actors = ActorBuilder.from_movie(@data)
  end

  def set_box_art
    box_arts = @data.search('box_art')
    @title.box_art = {}
    %w{ small medium large }.each { |size| @title.box_art[size] = box_arts.attr(size).value }
  end

  def set_runtime
    runtime = @data.search('runtime')
    @title.runtime = runtime.present? ? runtime.first.text.to_i : nil
  end

  def set_mpaa_rating
    rating = @data.search('category[@scheme="http://api-public.netflix.com/categories/mpaa_ratings"]')
    @title.mpaa_rating = rating.present? ? rating.first['label'] : nil
  end

  def set_synopsis
    synopses = @data.search('synopsis')
    @title.synopsis = synopses.present? ? synopses.first.text : nil
  end

  def title
    @title
  end
end
