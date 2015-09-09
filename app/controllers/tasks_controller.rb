class TasksController < ApplicationController
  before_action :check_api_key, only: [:payment_code_check]
  before_action :authenticate_admin!, only: [:course_books_csv, :lecturer_books_csv]

  def payment_code_check
    unpaid_bills = Bill.where(type: 'payment_code', state: 'payment_pending')

    paid_count = 0
    unpaid_bills.find_each do |bill|
      if NewebPayService.reget_payment_code(bill.uuid, bill.amount) == true
        bill.pay!
        paid_count += 1
      end
    end

    render(json: { success: 200, paid_count: paid_count }, status: 200)
  end

  def course_books_csv
    fn = Rails.root.join('tmp', "course_books_#{Time.now.to_i}.csv")
    CSV.open(fn, 'w') do |csv|
      csv << %w(course_ucode book_isbn book_known updated_by confirmed book_required updater_code created_at updated_at)
      CourseBook.all.each {|cb| csv << [cb.course_ucode, cb.book_isbn, cb.book_known, cb.updated_by, cb.confirmed, cb.book_required, cb.updater_code, cb.created_at, cb.updated_at]  }
    end
    send_file fn
  end

  def lecturer_books_csv
    fn = Rails.root.join('tmp', "unknown_lecturer_books_#{Time.now.to_i}.csv")

    CSV.open(fn, 'w') do |csv|
      errors = []

      csv << %w(課程名稱 老師 Ucode 未對應 isbn)
      CourseBook.where(book_known: false).where.not(updater_code: nil).select{|cb| !cb.updater_code.empty? }.each do |cb|
        if cb.course
          csv << [cb.course.name, cb.course.lecturer_name, cb.course.ucode, cb.book_isbn]
        else
          errors << cb
        end
      end

      csv << []; csv << []; csv << []
      csv << %w(ucode book_isbn book_known updated_by confirmed created_at updated_at book_required updater_code locked updater_type)
      errors.each {|cb| csv << [cb.course_ucode, cb.book_isbn, cb.book_known, cb.updated_by, cb.confirmed, cb.created_at, cb.updated_at, cb.book_required, cb.updater_code, cb.locked, cb.updater_type] }
    end;
    send_file fn
  end

  def invoice_export
    header_row = %w{發票張數 發票日期 品名序號 發票品名 數量 單價 課稅別 稅率 通關方式 買方統編 列印+Email 手機條碼 自然人 愛心碼 會員類別 會員號碼 貨號 國際條碼 發票備註欄位 交易明細備註欄位}

    file_basename = "books_#{Time.now.strftime('%F %T')}.xls"
    fn = Rails.root.join('tmp', file_basename)

    exported_lines = Bill.where('created_at > ?', Date.new(2015, 8, 1)).where(state: :paid).order(amount: :desc).each.with_index.inject([]) do |lines, (bill, bill_index)|
      serial_no = bill_index + 1

      # 懶人開法，每張 bill 開一項
      lines << [
        serial_no, # serial
        Date.today.to_s, # 發票日期
        1, # 品名序號
        "書款", # 發票品名
        1, # 數量
        bill.amount, # 單價
        "1", # 課稅別
        "0.05", # 稅率
        "", # 通關方式
        bill.invoice_uni_num,
        "", # 列印+Email
        bill.invoice_code, # 手機條碼
        bill.invoice_cert, # 自然人
        bill.invoice_love_code, # 愛心碼
        ENV['GATEWAY_ACCOUNT_TYPE'], # 會員類別
        bill.user.sid, # 會員號碼
        "", # 貨號
        "", # 國際條碼
        bill.user.name, # 發票備註欄位
        bill.id, # 交易明細備註欄位
      ]
      # bill.orders.pluck(:book_id).group_by(&:itself).each do |book_id, id_arr|
      lines
    end

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet
    sheet.row(0).concat(header_row)
    exported_lines.each_with_index { |l, i| sheet.row(i+1).concat(l) }
    book.write fn

    send_file fn
  end

  private

  def check_api_key
    render(json: { error: 403, message: 'Bad token.' }, status: 403) and return if params[:token] != ENV['TASK_API_KEY']
  end
end
