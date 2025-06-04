sub init()
  m.Poster = m.top.findNode("poster")
end sub

sub itemContentChanged()
  m.Poster.loadDisplayMode = "scaleToZoom"
  if m.top.height < 400 and m.top.width < 400 then
    m.Poster.loadWidth = 300
    m.Poster.loadHeight = 150
  end if
  updateLayout()
  if m.top.itemContent <> invalid then
    m.Poster.uri = m.top.itemContent.HDPOSTERURL
  else
    m.Poster.uri = invalid
  end if
end sub

sub updateLayout()
  if m.top.height > 0 and m.top.width > 0 then
    m.Poster.width = m.top.width
    m.Poster.height = m.top.height
  end if
end sub
