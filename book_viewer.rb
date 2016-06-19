require "tilt/erubis"
require "sinatra"
require "sinatra/reloader" if development?



before do
    @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").each_with_index.map do |line, index|
      "<p id=paragraph#{index}>#{line}</p>"
    end.join
  end
  def highlight_search(text, term)
    #fix this, it changes the original case of text
    text.gsub(/#{term}/i, %(<strong>#{term}</strong>))
  end
end

get "/" do
  @title = "Adventures of Sherlock Holmes"
  @contents = File.readlines("data/toc.txt")
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @contents[number - 1]
  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = File.read("data/chp#{params[:number]}.txt")
  erb :chapter
end

get "/search" do
  if params[:query]
    @results = @contents.each_with_index.each_with_object([]) do |(chapter, index), results|
      text = File.read("data/chp#{index + 1}.txt")
      paragraphs = text.split("\n\n")
      paragraphs.each_with_index do |paragraph, paragraph_index|
        if paragraph.downcase.include?(params[:query].downcase)
          results << [chapter, index, paragraph, paragraph_index]
        end
      end
    end
  end

  erb :search
end

not_found do
  redirect "/"
end

