require 'rubygems'
require 'json'
require 'net/http'
require 'rexml/document'


module Format
  Json = "json"
  Xml = "xml"
end

module Media
  public
  News = "news"
  Image = "image"
  Video = "video"
end

module Style
  Day = "day"
  Week = "week"
end


class TweetMeme
  
  TWEET_MEME_URI = 'http://api.tweetmeme.com/stories/popular'
  
  attr_accessor :format
  attr_accessor :media
  attr_accessor :style
  attr_accessor :category

  def initialize(format=Format::Json, category="technology", media=Media::News, style=Style::Day)
    self.format=format
    @category = category
    self.media = media
    self.style = style 
  end
  
  def format=(new_format)
    if (new_format != Format::Json && new_format != Format::Xml) then
      raise "The format (#{new_format}) is not a valid format."
    else
      @format=new_format
    end
  end
  
  def media=(new_media)
    if (new_media != Media::News && new_media != Media::Image && new_media != Media::Video) then
      raise "The media (#{new_media}) is not a valid media."
    else
      @media=new_media
    end
  end
  
  def style=(new_style)
    if (new_style != Style::Day && new_style != Style::Week) then
      raise "The style (#{new_style}) is not a valid style."
    else
      @style=new_style
    end
  end
  
  def getMemes
    uri = TWEET_MEME_URI+"."+@format;
    
    firstParam = true
    
    if (!@category.nil?) then
         uri= add_param_to_uri(uri, :category.to_s, "#{@category}")
    end
    
    if (!@style.nil?) then
         uri= add_param_to_uri(uri, :style.to_s, "#{@style}")
    end
    
    if (!@media.nil?) then
         uri= add_param_to_uri(uri, :media.to_s, "#{@media}")
    end
    
    uri_result = Net::HTTP.get URI.parse(uri)
    memes = []
    i = 0;
    if(@format.eql?(Format::Json)) then
      begin       
        json = JSON.parse(uri_result)
        if(json["status"].eql?("success")) then
          json["stories"].each do |story| 
            meme = Meme.new story["title"], story["url"], @media, story["created_at"], story["excerpt"]
            memes[i] = meme
            i=i+1
          end
          memes
        end
      rescue Exception => e
         puts e.backtrace.inspect
      end
    else
       begin     
        document = REXML::Document.new(uri_result)
        status = document.root.text("/result/status")
        if(status.eql?("success")) then
            document.elements.each("/result/stories/story") do |story|
            meme = Meme.new story.text("title"), story.text("url"), @media, story.text("created_at"), story.text("excerpt")
            memes[i] = meme
            i=i+1
          end
          memes
        end
      rescue Exception => e
        puts e.backtrace.inspect
      end
    end
  end
  
  private
  
  def add_param_to_uri(uri, param, value)
    if (!uri.include? "\?") then
      uri +="\?"
    else
      uri +="&"
    end
    uri +=(param + "=" + value)
  end

  
end

class Meme
  attr_reader :title
  attr_reader :url
  attr_reader :media_type
  attr_reader :created_at
  attr_reader :excerpt

  def initialize(title, url, media_type=Media::News, created_at="", excerpt="")
    @title = title
    @url = url
    @media_type = media_type
    @created_at=created_at
    @excerpt=excerpt
  end
end  