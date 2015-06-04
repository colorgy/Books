# Pagination base on Link (HTTP respond header)
LinkPagination = React.createClass
  getDefaultProps: ->
    linkString: ''
    onClick: (payload) ->
      console.log(payload)
    navLinksCount: 5

  parsedLinks: ->
    linkString = @props.linkString
    linkStringArray = linkString.replace(/ /g, '').split(',')
    links = {}
    linkStringArray.forEach (str) ->
      matchs = str.match(/\<([^\>]+)>.*rel="([^"]+)"/)
      links[matchs[2]] = matchs[1] if matchs
    return links

  changeURLForPage: (url, page) ->
    url.replace(/[\?&]page=([0-9]+)/, "page=#{page}")

  render: ->
    links = @parsedLinks()
    window.links = links

    current = null
    if links.next
      sampleURL = links.next
      current = parseInt(links.next.match(/[\?&]page=([0-9]+)/)[1]) - 1
    else if links.prev
      sampleURL = links.prev
      current = parseInt(links.prev.match(/[\?&]page=([0-9]+)/)[1]) + 1

    total = null
    if links.last
      total = parseInt(links.last.match(/[\?&]page=([0-9]+)/)[1])
    else if current
      total = current

    return `<div/>` if !current || !total

    return `<div/>` if total == 1

    hasPrev = current > 1
    hasNext = current < total

    navLinksCount = parseInt(@props.navLinksCount)
    prevNavLinksCount = Math.floor(navLinksCount/2)
    nextNavLinksCount = Math.floor(navLinksCount/2)
    if (current - prevNavLinksCount < 1)
      nextNavLinksCount += prevNavLinksCount - (current - 1)
    else if (current + nextNavLinksCount > total)
      prevNavLinksCount += nextNavLinksCount - (total - current)
    prevNavLinksTruncated = true
    if prevNavLinksCount >= (current - 1)
      prevNavLinksCount = (current - 1)
      prevNavLinksTruncated = false
    nextNavLinksTruncated = true
    if nextNavLinksCount >= (total - current)
      nextNavLinksTruncated = false
      nextNavLinksCount = (total - current)
    navLinksStart = (current - prevNavLinksCount)
    navLinksEnd = (current + nextNavLinksCount)

    navs = []

    (=>
      if hasPrev
        link = links.prev
        callbackPayload =
          link: link
          page: current - 1
        onClick = (e) =>
          e.preventDefault()
          @props.onClick(callbackPayload)
        navs.push \
          `<li key="prev">
            <a href="#" aria-label="Previous" onClick={onClick}>
              <span aria-hidden="true">«</span>
            </a>
          </li>`
      else
        navs.push \
          `<li key="prevDisabled" className="disabled">
            <a href="#" aria-label="Previous">
              <span aria-hidden="true">«</span>
            </a>
          </li>`
    )()

    (=>
      if prevNavLinksTruncated
        link = links.first
        page = 1
        callbackPayload =
          link: link
          page: page
        onClick = (e) =>
          e.preventDefault()
          @props.onClick(callbackPayload)
        navs.push \
          `<li key={page}>
            <a href="#" aria-label="First" onClick={onClick}>
              {page}
            </a>
          </li>`
        navs.push \
          `<li key={page + 1}>
            <span>...</span>
          </li>` if navLinksStart > 2
    )()

    for page in [navLinksStart..navLinksEnd]
      (=>
        link = @changeURLForPage(sampleURL, page)
        callbackPayload =
          link: link
          page: page
        onClick = (e) =>
          e.preventDefault()
          @props.onClick(callbackPayload)
        navs.push \
          `<li key={page} className={classNames({active: (page == current)})}>
            <a href="#" onClick={onClick}>{page}</a>
          </li>`
      )()

    (=>
      if nextNavLinksTruncated
        link = links.last
        page = total
        callbackPayload =
          link: link
          page: page
        onClick = (e) =>
          e.preventDefault()
          @props.onClick(callbackPayload)
        navs.push \
          `<li key={page - 1}>
            <span>...</span>
          </li>` if navLinksEnd < total - 1
        navs.push \
          `<li key={page}>
            <a href="#" aria-label="Last" onClick={onClick}>
              {page}
            </a>
          </li>`
    )()

    (=>
      if hasNext
        link = links.next
        callbackPayload =
          link: link
          page: current + 1
        onClick = (e) =>
          e.preventDefault()
          @props.onClick(callbackPayload)
        navs.push \
          `<li key="next">
            <a href="#" aria-label="Next" onClick={onClick}>
              <span aria-hidden="true">»</span>
            </a>
          </li>`
      else
        navs.push \
          `<li key="nextDisabled" className="disabled">
            <a href="#" aria-label="Next">
              <span aria-hidden="true">»</span>
            </a>
          </li>`
    )()

    return \
      `<ul className="pagination">
        {navs}
      </ul>`

window.LinkPagination = LinkPagination
