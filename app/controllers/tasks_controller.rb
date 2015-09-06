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

  private

  def check_api_key
    render(json: { error: 403, message: 'Bad token.' }, status: 403) and return if params[:token] != ENV['TASK_API_KEY']
  end
end
