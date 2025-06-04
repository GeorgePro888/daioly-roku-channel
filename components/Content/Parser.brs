' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub init()
  print "Parser.brs - [init]"
end sub

' Parses the response string as XML
' The parsing logic will be different for different RSS feeds
sub parseResponse()
  print "Parser.brs - [parseResponse]"
  jsonstr = m.top.response.content
  num = m.top.response.num

  if jsonstr = invalid return

  jsonData = ParseJSON(jsonstr)
  if type(jsonData) <> "roAssociativeArray" return

  ' Combine all content arrays
  combinedItems = []
  if jsonData.movies <> invalid then combinedItems.Concat(jsonData.movies)
  if jsonData.shortFormVideos <> invalid then combinedItems.Concat(jsonData.shortFormVideos)

  result = []
  
  for each itemData in combinedItems
    if itemData <> invalid 

      content = itemData.content
      if content <> invalid and content.videos.Count() > 0 

        video = content.videos[0]

        item = {}
        item.guid = itemData.id
        item.link = video.url
        item.title = itemData.title
        item.description = itemData.shortDescription
        ' item.content_html = itemData.longDescription
        ' item.summary = itemData.longDescription
        item.pubDate = itemData.releaseDate
        item.stream = {url: video.url}
        item.url = video.url
        item.streamformat = LCase(video.videoType)
        item.hdposterurl = itemData.thumbnail
        item.hdbackgroundimageurl = itemData.thumbnail
        item.uri = itemData.thumbnail

        result.Push(item)
      end if
    end if
  end for

  ' Create categories/rows from metadata
  list = [
    { Title: "Travel", ContentList: result }
    { Title: "XGames", ContentList: result }
    { Title: "Street Art", ContentList: result }
  ]

  contentAA = {}
  content = invalid
  if num = 3
    content = createGrid(result)
  else
    content = createRow(list, num)
  end if

  if content <> invalid
    contentAA[num.toStr()] = content
    if m.UriHandler = invalid then m.UriHandler = m.top.getParent()
    m.UriHandler.contentCache.addFields(contentAA)
  else
    print "Error: content was invalid"
  end if
end sub


'Create a row of content
function createRow(list as object, num as Integer)
  print "Parser.brs - [createRow]"
  Parent = createObject("RoSGNode", "ContentNode")
  row = createObject("RoSGNode", "ContentNode")
  row.Title = list[num].Title
  for each itemAA in list[num].ContentList
    item = createObject("RoSGNode","ContentNode")
    AddAndSetFields(item, itemAA)
    row.appendChild(item)
  end for
  Parent.appendChild(row)
  return Parent
end function

'Create a grid of content - simple splitting of a feed to different rows
'with the title of the row hidden.
'Set the for loop parameters to adjust how many columns there
'should be in the grid.
function createGrid(list as object)
  print "Parser.brs - [createGrid]"
  Parent = createObject("RoSGNode","ContentNode")
  for i = 0 to list.count() step 4
    row = createObject("RoSGNode","ContentNode")
    if i = 0
      row.Title = "The Grid"
    end if
    for j = i to i + 3
      if list[j] <> invalid
        item = createObject("RoSGNode","ContentNode")
        AddAndSetFields(item,list[j])
        row.appendChild(item)
      end if
    end for
    Parent.appendChild(row)
  end for
  return Parent
end function
