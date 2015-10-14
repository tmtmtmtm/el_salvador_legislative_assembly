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

local = ENV['MORPH_LOCAL']
get_all = ENV['MORPH_GET_ALL']
scrape_urls_from_homepage = ENV['MORPH_SCRAPE_URLS_FROM_HOMEPAGE']

puts "local #{local}"
puts "get_all #{get_all}"
puts "scrape_urls_from_homepage #{scrape_urls_from_homepage}"

sleep_between_requests = 20 # (seconds) be kind to El Salvador's server!

# Not scraping this because there seem to be mistakes on the page,
term = "2015-2018"

if local == 'true'
    require 'pry'
    la_url = 'http://localhost:4000/pleno_legislativo.html'
else
    la_url = 'http://asamblea.gob.sv/pleno/pleno-legislativo'
end

puts "getting ids from database"
id_hashes = ScraperWiki::select('id from data')
puts "done"
ids = []

# ids get returned as an array of hashes
id_hashes.each do |hash|
    ids.push(hash["id"])
end

# There are often 'bad gateway' errors on the homepage, maybe bypassing the homepage altogether
# will work?
person_urls = ["http://asamblea.gob.sv/pleno/pleno-legislativo/ana-vilma-albanez-de-escobar",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/jose-antonio-almendariz-rivas",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/ana-marina-alvarenga-barahona",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/rodrigo-avila-aviles",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/lucia-del-carmen-ayala-de-leon",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/ana-lucia-baires-de-martinez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/marta-evelyn-batres-araujo",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/roger-alberto-blandino-nerio-jeremias-nerio",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/manuel-orlando-cabrera-candray",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/yohalmo-edmundo-cabrera-chacon",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/carmen-elena-calderon-sol-de-escalon",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/silvia-alejandrina-castro-figueroa",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/norma-cristina-cornejo-amaya",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/valentin-aristides-corpeno",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/raul-omar-cuellar",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/rene-gustavo-escalante-zelaya",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/margarita-escobar",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/jorge-alberto-escobar-bernal",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/jose-edgar-escolan-batarse",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/julio-cesar-fabian-perez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/santiago-flores-alfaro",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/juan-manuel-de-jesus-flores-cornejo",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/guillermo-antonio-gallegos-navarrete",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/carlos-alberto-garcia",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/ricardo-ernesto-godoy-penate",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/maria-elizabeth-perla-gomez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/medardo-gonzalez-trejo",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/norma-fidelia-guevara-de-ramirios",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/vicente-hernandez-gomez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/karla-elena-hernandez-molina",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/estela-yanet-hernandez-rodriguez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/juan-pablo-herrera-rivas",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/maytee-gabriela-iraheta-escalante",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/bonner-francisco-jimenez-belloso",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/mauricio-roberto-linares-ramirez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/audelia-guadalupe-lopez-de-kleutgens",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/cristina-esmeralda-lopez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/reynaldo-antonio-lopez-cardoza",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/hortensia-margarita-lopez-quintana",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/mario-marroquin-mejia",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/rodolfo-antonio-martinez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/guillermo-francisco-mata-bennett",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/rolando-mata-fuentes",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/calixto-mejia-hernandez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/misael-mejia-mejia",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/jose-santos-melara-yanes",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/juan-carlos-mendoza-portillo",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/jose-francisco-merino-lopez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/ernesto-luis-muyshondt-garcia-prieto",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/jose-serafin-orantes-rodriguez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/silvia-estela-ostorga-de-escobar",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/jose-javier-palomo-nieto",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/rodolfo-antonio-parker-soto",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/lorena-guadalupe-pena-mendoza",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/mario-antonio-ponce-lopez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/rene-alfredo-portillo-cuadra",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/zoila-beatriz-quijada-solis-1",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/norman-noel-quijano-gonzalez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/nelson-de-jesus-quintanilla-gomez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/david-ernesto-reyes-molina",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/carlos-armando-reyes-ramos",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/lorenzo-rivas-echeverria",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/santos-adelmo-rivas-rivas",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/jackeline-noemi-rivera-avalos",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/vilma-carolina-rodriguez-davila",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/abilio-orestes-rodriguez-menjivar",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/sonia-margarita-rodriguez-siguenza",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/alberto-armando-romero-rodriguez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/numan-pompilio-salgado-garcia",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/jaime-orlando-sandoval",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/karina-ivette-sosa-de-lara",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/manuel-rigoberto-soto-lazo",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/mario-alberto-tenorio-guerrero",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/jaime-gilberto-valdez-hernandez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/patricia-elena-valdivieso-de-gallardo",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/juan-alberto-valiente-alvarez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/maria-marta-concepcion-valladares-mendoza-nidia-diaz",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/donato-eugenio-vaquerano-rivas",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/mauricio-ernesto-vargas-valdez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/guadalupe-antonio-vasquez-martinez",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/ricardo-andres-velasquez-parker",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/john-tennant-wright-sol",
               "http://asamblea.gob.sv/pleno/pleno-legislativo/francisco-jose-zablah-safie",
               ]

if local == 'true' and scrape_urls_from_homepage == 'false'
    person_urls = ["localhost:8000/ana_vilma.html",
                   "localhost:8000/alma_cruz.html",
                   ]
elsif scrape_urls_from_homepage == 'true'
    la_url = open(la_url, read_timeout: 500)
    noko = noko_for(la_url)
    person_urls = noko.css('dl dt a')
end

person_urls.each do |a|
    person_url = a

    if scrape_urls_from_homepage == 'true'
        person_url = a.xpath('./@href').text
    end

    if local == 'true'
        person_url.sub!('asamblea.gob.sv/pleno', 'localhost')
    end
    puts "source: #{person_url}"

    id = person_url.sub(/.*\//, '')
    puts "id: #{id}"

    # The server keeps going down, so better to only scrape data we don't already have
    if not ids.include?(id) or get_all == 'true'
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
        puts district
        
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
        sleep(sleep_between_requests)

    else
        puts "already in database"
    end
end
