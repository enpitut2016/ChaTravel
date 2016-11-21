module RoomsHelper

require "uri"

def meesage_format(text,id)

	gnavi = false;
	if text.match('-gnavi-')!=nil && id==1 then #ぐるなびかどうかを判別（ボットがしゃべってるかも判別）
		text = text.gsub(/-gnavi-/, ""); #-gnavi-を削除
		gnavi = true;       

	end

	text_url_to_link(text); #url挿入

	if gnavi then
		text << "<a href='http://www.gnavi.co.jp/'><img class='gnavi-icon' src='http://apicache.gnavi.co.jp/image/rest/b/api_155_20.gif' alt='グルメ情報検索サイト　ぐるなび'></a>" 
	end

	return text

end	

#urlにaタグを挿入する関数
def text_url_to_link text

  URI.extract(text, ['http']).uniq.each do |url|
    sub_text = ""
    sub_text << "<a href=" << url << " target=\"_blank\">" << url << "</a>"

    text.gsub!(url, sub_text)
  end
  return text
end

end
