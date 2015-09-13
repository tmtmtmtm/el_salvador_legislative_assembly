#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'open-uri'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

local = true

la_url = 'http://asamblea.gob.sv/pleno/pleno-legislativo'

if local do
	la_url = 'http://localhost:8000/pleno_legislativo.html'
end

noko = noko_for(la_url)

noko.css('dl dt a').each do |a|
	person_url = a.xpath('./@href').text

	if local do
		person_url.sub!('asamblea.gob.sv/pleno', 'localhost')
	end
	puts person_url

	id = person_url.sub(/.*\//, '')
	puts id

	p = noko_for(person_url)
	name = p.css('h1').text
	puts name

	party_class = 'Grupo Parlamentario'
	group = p.xpath("//span[@class='informacion-diputado'][contains(.,'#{party_class}')]")
		.first.text.sub(/.*#{party_class}/, '')
	puts group

	email = p.xpath("//span[.//img[contains(@src,'/emailicon.png')]]/a/@href").text.sub('mailto:', '')
	puts email

	personal_email = p.xpath("//a[.//img[contains(@src,'personal-emailicon.png')]]/span").text
	puts personal_email
	
	data = {
		id: id,
		name: name,
		group: group.tidy,
		email: email,
		email__personal: personal_email
	}
	if local do
		puts data
		break
	else
		ScraperWiki.save_sqlite([:id], data)
	end
end

