require 'nokogiri'
require 'open-uri'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  def scrape(uri)
    html = open(uri).read.encode('UTF-8')
    doc = Nokogiri::HTML(html, uri)
    title =  doc.css('//meta[property="og:site_name"]/@content').empty? ? doc.title.to_s : doc.css('//meta[property="og:site_name"]/@content').to_s
    desc = doc.css('//meta[property="og:description"]/@content')
    description = desc.empty? ? doc.css('//meta[name$="escription"]/@content').to_s : desc.to_s
    image = doc.css('//meta[property="og:image"]/@content').to_s

    { title: title, description: description, image: image }
  end
end
