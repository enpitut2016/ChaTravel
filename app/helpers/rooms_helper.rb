module RoomsHelper

require "uri"

def meesage_format(text,id)

	gnavi = false;
	rakuten = false;
	if text.match('-gnavi-')!=nil && id==1 then #ぐるなびかどうかを判別（ボットがしゃべってるかも判別）
		text = text.gsub(/-gnavi-/, ""); #-gnavi-を削除
		gnavi = true;       
	elsif text.match('-rakuten-')!=nil && id==1 then #楽天かどうかを判別（ボットがしゃべってるかも判別）
		text = text.gsub(/-rakuten-/, ""); #-rakuten-を削除
		text = text.gsub(/-mainS-/, "<div class='rakuten_result'>"); #タブに変換
		text = text.gsub(/-imgS-/, "<div class='col-md-5'>");
		text = text.gsub(/-textS-/, "<div class='col-md-7'>");
		text = text.gsub(/-rowS-/, "<div class='row'>");
		text = text.gsub(/-E-/, "</div>");
		text = text.gsub(/-br-/, "<br>");
		rakuten = true; 
	end

	if gnavi then
		URI.extract(text, ['http']).uniq.each do |url|
    		sub_text = ""
    		sub_text << "<a href=" << url << " target=\"_blank\">詳しくはこちら</a>"
    		text.gsub!(url, sub_text)
  		end
		text << "<div class='api_banner'><a href='http://www.gnavi.co.jp/'><img class='gnavi-icon' src='http://apicache.gnavi.co.jp/image/rest/b/api_155_20.gif' alt='グルメ情報検索サイト　ぐるなび'></a></div>" 
	elsif rakuten then
		URI.extract(text, ['http']).uniq.each do |url|
    		sub_text = ""
    		if url.include?(".jpg") then
    			sub_text << "<img class='thumbnail' src='" << url << "' alt='ホテル画像'> "
    		else
    			sub_text << "<a href=" << url << " target=\"_blank\">詳しくはこちら</a>"
    		end
    		text.gsub!(url, sub_text)
  		end
  		text << "<div class='api_banner col-md-12'>"
		text << "<!-- Rakuten Web Services Attribution Snippet FROM HERE -->"
        text << '<a href="http://webservice.rakuten.co.jp/" target="_blank"><img src="https://webservice.rakuten.co.jp/img/credit/200709/credit_22121.gif" border="0" alt="楽天ウェブサービスセンター" title="楽天ウェブサービスセンター" width="221" height="21"/></a>'
        text << "<!-- Rakuten Web Services Attribution Snippet TO HERE -->"
        text << "</div>"
    else
    	text_url_to_link(text); #urlにaタグ挿入
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
