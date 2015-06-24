Books
=======

[![Build Status](https://img.shields.io/travis/colorgy/Books/master.svg?style=flat)](https://travis-ci.org/colorgy/Books)
[![Coverage Status](https://img.shields.io/coveralls/colorgy/Books/master.svg?style=flat)](https://coveralls.io/r/colorgy/Books?branch=master)
[![Code Climate](https://img.shields.io/codeclimate/github/colorgy/Books.svg?style=flat)](https://codeclimate.com/github/colorgy/Books)
[![Dependency Status](https://img.shields.io/gemnasium/colorgy/Books.svg?style=flat)](https://gemnasium.com/colorgy/Books)

大專院校教科書團訂平台。A part of the Colorgy platform。


## Requirements

### 課程資料

需要 Core 的 data API 提供各校的課程資料，API path 固定為 `{org_code}/courses`，並需要以下欄位：

- `year`: (integer) 課程的學年度，使用公元表示。
- `term`: (integer) 課程的學期，1 或 2。
- `code`: (string) 橫跨年度、學期的課程唯一代碼，且不被上課時間、地點等細部改變影響。
- `name`: (string) 課程名稱。
- `lecturer`: (string) 課程的教師姓名。

以下欄位為選用：

- `general_code`: (string) 課程的通用代碼。跨年度開的同一門課，此代碼將會一樣。
- `department_code`: (string) 開課系所代碼。


## Development Setup

Just run:

```bash
$ ./bin/setup
```

and configure the app's environment variables, which lays in `.env`. The information for connecting to Colorgy Core will be always required.


## Testing

Run the following command to execute all test suites:

```bash
$ bundle exec rake

```


## Contributing

1. Fork it.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -m 'add some feature'`).
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request.
