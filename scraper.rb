#!/bin/env ruby
# encoding: utf-8

require 'wikidata/fetcher'

USER_AGENT="wikidata-scotparl-fetcher (loudspeek@poteris.co.uk)"

module RestClient::Platform
  def self.default_user_agent
    USER_AGENT
  end
end

module OpenURI
  class << self
    alias open_uri_original_open_loop open_loop # :nodoc:
  end
  def OpenURI.open_loop(uri, options)
    open_uri_original_open_loop uri, options.merge({"User-Agent" => USER_AGENT})
  end
end

Faraday.default_connection = Faraday.new(options = {:headers=>{:user_agent=>USER_AGENT}})
Faraday.default_connection_options.headers = { "User-Agent" => USER_AGENT }

pages = [
  'Category:Members of the Scottish Parliament 1999–2003',
  'Category:Members of the Scottish Parliament 2003–07',
  'Category:Members of the Scottish Parliament 2007–11',
  'Category:Members of the Scottish Parliament 2011–16',
  'Category:Members of the Scottish Parliament 2016–2021',
  'Category:Members of the Scottish Parliament 2021–2026',
  'Category:Members of the Scottish Parliament 2026–2031'
]
names = pages.map { |url| WikiData::Category.new(url, 'en').member_titles }.flatten.uniq

EveryPolitician::Wikidata.scrape_wikidata(names: { en: names })
