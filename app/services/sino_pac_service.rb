module SinoPacService
  REALM = "DataWebService"
  PFNO = ENV['SINO_PAC_PFNO']
  KEY_DATA = ENV['SINO_PAC_KEY_DATA']
  API_BASE_URL = 'http://ecapisandbox.sinopac.com'

  class << self
    def get_virtual_account(order_number, amount, duedate: 3.days.from_now, payname: 'pay', memo: nil, payername: nil, payermobile: nil, payeraddress: nil)
      target_url = "#{API_BASE_URL}/WebAPI/Service.svc/CreateATMorIBonTrans"
      xml_context = <<-EOF
      <ATMOrIBonClientRequest xmlns="http://schemas.datacontract.org/2004/07/SinoPacWebAPI.Contract">
        <ShopNO>#{PFNO}</ShopNO>
        <KeyNum>3</KeyNum>
        <OrderNO>#{order_number}</OrderNO>
        <Amount>#{amount}</Amount>
        <CurrencyID>NTD</CurrencyID>
        <ExpireDate>#{duedate.strftime('%Y%m%d')}</ExpireDate>
        <PayType>A</PayType>
        <PrdtName>#{payname}</PrdtName>
        <Memo>#{memo}</Memo>
        <PayerName>#{payername}</PayerName>
        <PayerMobile>#{payermobile}</PayerMobile>
        <PayerAddress>#{payeraddress}</PayerAddress>
        <PayerEmail></PayerEmail>
        <ReceiverName></ReceiverName>
        <ReceiverMobile></ReceiverMobile>
        <ReceiverAddress></ReceiverAddress>
        <ReceiverEmail></ReceiverEmail>
      </ATMOrIBonClientRequest>
      EOF

      response = post(target_url, xml_context)
      response = Hash.from_xml(response)

      return response['ServerResponse']['PayNO']
    end

    def virtual_account_paid?(order_number)
      target_url = "#{API_BASE_URL}/WebAPI/Service.svc/QueryTradeStatus"
      xml_context = <<-EOF
      <QueryTradeStatusRequest xmlns="http://schemas.datacontract.org/2004/07/SinoPacWebAPI.Contract.QueryTradeStatus">
        <ShopNO>#{PFNO}</ShopNO>
        <KeyNum>3</KeyNum>
        <OrderNO>#{order_number}</OrderNO>
        <PayType>A</PayType>
        <OrderDateS></OrderDateS>
        <OrderTimeS></OrderTimeS>
        <OrderDateE></OrderDateE>
        <OrderTimeE></OrderTimeE>
        <PayFlag>A</PayFlag>
        <PrdtNameFlag>Y</PrdtNameFlag>
        <MemoFlag>Y</MemoFlag>
        <PayerNameFlag>Y</PayerNameFlag>
        <PayerMobileFlag>Y</PayerMobileFlag>
        <PayerAddressFlag>Y</PayerAddressFlag>
        <PayerEmailFlag>Y</PayerEmailFlag>
        <ReceiverNameFlag>Y</ReceiverNameFlag>
        <ReceiverMobileFlag>Y</ReceiverMobileFlag>
        <ReceiverAddressFlag>Y</ReceiverAddressFlag>
        <ReceiverEmailFlag>Y</ReceiverEmailFlag>
        <ParamFlag1>Y</ParamFlag1>
        <ParamFlag2>Y</ParamFlag2>
        <ParamFlag3>Y</ParamFlag3>
      </QueryTradeStatusRequest>
      EOF

      response = post(target_url, xml_context)
      response = Hash.from_xml(response)

      status_code = response['QueryTradeStatusResponse']['ECWebAPI']['PayStatus'].to_i

      if status_code > 15 && status_code < 100
        return true
      else
        return false
      end
    end

    # Send an authorized API POST request
    def post(uri, body)
      RestClient.post(uri, body, :content_type => 'text/xml;charset="utf-8"', :accept => 'text/xml') do |_response, _request, result|
        auth_string = result.header['www-authenticate']
        auth_data = Hash[*auth_string.scan(/(?<k>[a-z]+)="(?<v>[^"]*)"/).flatten]

        request_authorization = gen_auth_digest('POST', uri, body, auth_data)

        RestClient.post(uri, body, :'Authorization' => request_authorization, :content_type => 'text/xml;charset="utf-8"', :accept => 'text/xml') do |response, _request, _result|
          return response
        end
      end
    end

    # Generate auth digest for requests
    def gen_auth_digest(method, url, body, auth_data, shop_no: PFNO, key_data: KEY_DATA)
      cnonce = auth_data['cnonce'] || rand(123_400..9_999_999)
      realm = auth_data['realm']
      nonce = auth_data['nonce']
      qop = auth_data['qop']

      verifycode_part_1 = Digest::SHA256.hexdigest("#{shop_no}:#{realm}:#{key_data}")
      verifycode_part_2 = Digest::SHA256.hexdigest("#{method}:#{url}")

      message = body.gsub(/[\r\n ]/, '')
      verifycode = Digest::SHA256.hexdigest("#{verifycode_part_1}:#{nonce}:#{cnonce}:#{qop}:#{message}:#{verifycode_part_2}")

      request_authorization = "Digest realm=\"#{realm}\", nonce=\"#{nonce}\", uri=\"#{url}\", verifycode=\"#{verifycode}\", qop=#{qop}, cnonce=\"#{cnonce}\""

      return request_authorization
    end
  end

  # A demo request
  def self.demo
    target_url = "http://ecapisandbox.sinopac.com/WebAPI/Service.svc/CreateATMorIBonTrans"
    xml_context = <<-EOF
    <ATMOrIBonClientRequest xmlns="http://schemas.datacontract.org/2004/07/SinoPacWebAPI.Contract">
      <ShopNO>AB0039</ShopNO>
      <KeyNum>3</KeyNum>
      <OrderNO>OD20121220000015</OrderNO>
      <Amount>20000</Amount>
      <CurrencyID>NTD</CurrencyID>
      <ExpireDate>20121231</ExpireDate>
      <PayType>A</PayType>
      <PrdtName>收款名稱</PrdtName>
      <Memo></Memo>
      <PayerName></PayerName>
      <PayerMobile></PayerMobile>
      <PayerAddress></PayerAddress>
      <PayerEmail></PayerEmail>
      <ReceiverName></ReceiverName>
      <ReceiverMobile></ReceiverMobile>
      <ReceiverAddress></ReceiverAddress>
      <ReceiverEmail></ReceiverEmail>
    </ATMOrIBonClientRequest>
    EOF

    puts post(target_url, xml_context)
  end


end
