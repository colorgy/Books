require 'rest_client'
require 'nokogiri'
require 'iconv'

module NewebPayService
  class << self
    def get_payment_code(order_number, amount, payname: nil, payphone: nil, duedate: nil, detail: false)

      # code
      code = ENV['NEWEB_PAY_CODE']
      post_url = ENV['NEWEB_PAYMENT_API_URL']

      # 準備 post 給 藍星 的 data
      post_data = {
        # 商店編號
        :merchantnumber => ENV['NEWEB_MERCHANT_NUMBER'],
        # 訂單編號
        :ordernumber => order_number.to_s,
        # 金額
        :amount => amount.to_i.to_s,
        # 付款方式: MMK, 超商代碼付款
        :paymenttype => "MMK",
        # 付款期限
        :duedate => nil,
        # 付款者姓名
        :payname => payname.to_s,
        # 付款者手機號碼
        :payphone => payphone.to_s,
        # 是否回傳一段url? 0 => 他們產生網頁給我們, 1 => 他們回傳一段url給我們解析
        :returnvalue => 1,
        # hash = md5(merchantnumber + code + amount + ordernumber)
        :hash => "",
        # 給產生的網頁轉跳的網址, 不會用到
        :nexturl => ""
      }

      if duedate
        duedate = duedate.strftime('%Y%m%d') if duedate.is_a? DateTime
        duedate = duedate.strftime('%Y%m%d') if duedate.is_a? Time
        post_data[:duedate] = duedate
      end

      # 準備 hash = md5(merchantnumber + code + amount + ordernumber)
      post_data[:hash] = Digest::MD5.hexdigest(post_data[:merchantnumber] + code + post_data[:amount] + post_data[:ordernumber])

      # 送出表單並解析內容
      r = RestClient.post post_url, post_data
      ic = Iconv.new("utf-8//translit//IGNORE", "UTF-8")
      n = Nokogiri::HTML(ic.iconv(r.to_s))

      # puts n

      # 回傳資料
      response_data = n.css('p').text.split('&')

      # puts "回傳資料: ", response_data

      # 處理回傳資料
      begin
        response_data_hash = Hash[response_data.map { |v| vs = v.split('='); [ vs[0].to_sym, vs[1] ] }]
        checksum = response_data_hash[:checksum]

        raise if response_data_hash[:rc] != '0'

      rescue
        raise "訂單重複！#{response_data_hash[:message]}" if response_data_hash[:rc] == "70"
        raise "商店編號不存在！#{response_data_hash[:message]}" if response_data_hash[:rc] == "27"
        raise "上限金額高於兩萬！#{response_data_hash[:message]}" if response_data_hash[:rc] == "33"
        raise "未指定支付工具不支援！#{response_data_hash[:message]}" if response_data_hash[:rc] == "-8"
        raise "參數(繳款人姓名(payname))長度超過 100 或者 參數(繳款人電話(payphone))長度超過 20 或者 格式有誤 或者 hash 有誤！#{response_data_hash[:message]}" if response_data_hash[:rc] == "-101"
        raise "錯誤！#{response_data_hash[:message]}"
      end

      # 準備驗證資料
      response_data_in_string = ""
      5.times do |i|
        response_data_in_string += response_data[i] + "&"
      end

      # 驗證碼
      # checksum = md5(response_data + "&code=" + code);
      checker = Digest::MD5.hexdigest(response_data_in_string + "code=" + code)
      raise "資料被篡改！" if checker != checksum

      if detail
        return response_data_hash
      else
        return response_data_hash[:paycode]
      end
    end

    def reget_payment_code(order_number, amount, detail: false)
      code = ENV['NEWEB_PAY_CODE']
      postUrl = post_url = ENV['NEWEB_QUERY_API_URL']

      postData = {
        # 可以選 big-5, UTF-8
        :responseencoding => "UTF-8",
        # 無意義轉跳網址
        :nexturl => "",
        # 查詢是 regetorder
        :operation => "regetorder",
        # 1 => 回傳一段 url
        :returnvalue => "1",
        # 等一下會包起來兒
        :hash => "",
        # 付款方式, 超商為 MMK
        :paymenttype => "MMK",
        # 金額
        :amount => amount.to_s,
        # 訂單編號
        :ordernumber => order_number.to_s,
        # 商店編號
        :merchantnumber => ENV['NEWEB_MERCHANT_NUMBER'],
        # 這欄空下不填
        :bankid => ""
      }

      # hash = md5(merchantnumber+code+amount+ordernumber)
      postData[:hash] = Digest::MD5.hexdigest(postData[:merchantnumber] + code + postData[:amount] + postData[:ordernumber])

      # puts postData[:hash]
      r = RestClient.post postUrl, postData
      ic = Iconv.new("utf-8//translit//IGNORE", "UTF-8")
      n = Nokogiri::HTML(ic.iconv(r.to_s))

      # puts n.css('p').text.split('&')
      response = n.css('p').text.split('&')
      response_data_hash = Hash[response.map { |v| vs = v.split('='); [ vs[0].to_sym, vs[1] ] }]

      if response[0].split('=').last == "0"
        if detail
          return response_data_hash
        else
          return response_data_hash[:paycode]
        end
      elsif response[0].split('=').last == "-4"
        if response[1].split('=').last == "72"
          if detail
            return response_data_hash.merge(paid: true)
          else
            return true
          end
        end
        raise "無此筆訂單！" if response[1].split('=').last == "71"
        raise "金額不符" if response[1].split('=').last == "33"
        raise "hash 驗證碼錯誤" if response[1].split('=').last == "39"
      end
    end
  end
end
