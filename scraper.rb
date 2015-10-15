#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'
require 'open-uri'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url, read_timeout: 500).read)
end

def rescrape_homepage
  la_url = 'http://asamblea.gob.sv/pleno/pleno-legislativo'
  noko = noko_for(la_url)
  ScraperWiki.save_var('index_last_scraped', Date.today.to_s)
  noko.css('div.buscador-diputados-class dl dt a').each do |a|
    # Leave the 'term' blank to we know that we need to fetch this person
    data = { 
      id: File.basename(a.attr('href')),
      name: a.text.tidy,
      source: a.attr('href'),
    }
    existing = ScraperWiki.select('COUNT(*) AS count FROM data WHERE id = ?', [data[:id]]) rescue [{}]
    next if existing.first['count'] == 1
    warn "New representative: #{data}"
    ScraperWiki.save_sqlite([:id], data)
  end
end

def people_to_scrape
  rescrape_homepage if ScraperWiki.get_var('index_last_scraped') != Date.today.to_s
  ScraperWiki::select('source FROM data WHERE term IS NULL').map { |h| h["source"] } 
end

sleep_between_requests = 20 # (seconds) be kind to El Salvador's server!

# Not scraping this because there seem to be mistakes on the page,
term = "2015-2018"

to_scrape = people_to_scrape
warn "#{to_scrape.count} people to scrape"
to_scrape.each do |person_url|
    puts "source: #{person_url}"

    id = person_url.sub(/.*\//, '')
    puts "id: #{id}"

    begin
        p = noko_for(person_url)
        name = p.css('h1').text
        puts "name: #{name}"

        party_class = 'Grupo Parlamentario'
        group = p.xpath("//span[@class='informacion-diputado'][contains(.,'#{party_class}')]")
            .first.text.sub(/.*#{party_class}/, '').tidy
        puts "faction: #{group}"

        email = p.xpath("//span[.//img[contains(@src,'/emailicon.png')]]/a/@href").text.sub('mailto:', '')
        puts "email: #{email}"

        personal_email = p.xpath("//a[.//img[contains(@src,'personal-emailicon.png')]]/span").text
        puts "personal email: #{personal_email}"

        image = p.xpath("//h1/following-sibling::img[1]/@src").text.sub(/.*\//, "#{person_url}/")
        puts "image: #{image}\n"

        puts "term: #{term}\n"

        district = p.css('img#imagen_departamento_diputado')[0]['title']
        puts "district: #{district}\n\n"
        
        data = {
            id: id,
            name: name,
            faction: group,
            email: email,
            email__personal: personal_email,
            image: image,
            source: person_url,
            term: term,
        }

        ScraperWiki.save_sqlite([:id], data)

    rescue
        warn "Couldn't scrape #{person_url}"
        sleep(sleep_between_requests)
    end
end
