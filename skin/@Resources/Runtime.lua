-- Shared native renderer. LIVE reads a strict snapshot; DEMO never collects.
local M,F,L,data,events
local mode="DEMO"
local nextCollect=0
local collectingUntil=0
local liveSnapshot=nil
local active=nil
local scenario=1
local serial=0
local scale=1
local offset=0
local opts={}
local lastLayout={}
local root
local detailShown={}
local detailMeters={'DetailBackground','DetailHeading','DetailSubheading','DetailClose','DetailUncertain','DetailError','DetailExtra','DetailIdentity','DetailOmitted','EventTitle','EventBody','EventAck'}
for _,prefix in ipairs({'DetailWeekly','DetailSession'}) do
  for _,suffix in ipairs({'Title','Percent','Track','Bar','Reset','Date','Age'}) do detailMeters[#detailMeters+1]=prefix..suffix end
end
local function option(m,k,v)
  v=tostring(v);local id=m..':'..k
  if opts[id]~=v then SKIN:Bang('!SetOption',m,k,v);opts[id]=v end
end
local function show(m,yes)
  if m:match('^Detail') or m:match('^Event') then detailShown[m]=yes end
  option(m,'Hidden',yes and 0 or 1)
end
local function number(name,default,low,high)
  local n=tonumber(SKIN:GetVariable(name)) or default
  if n~=n then n=default end
  return math.max(low,math.min(high,n))
end
local function color(name,default,alpha)
  local raw=SKIN:GetVariable(name,default)
  local r,g,b,a=raw:match('^(%d+),(%d+),(%d+),?(%d*)$')
  if not r or tonumber(r)>255 or tonumber(g)>255 or tonumber(b)>255 then return default end
  return r..','..g..','..b..','..tostring(alpha or tonumber(a) or 255)
end
local function text(m,value,x,y,w,h,size,c)
  option(m,'Text',value);option(m,'X',x);option(m,'Y',y);option(m,'W',w);option(m,'H',h)
  option(m,'FontSize',size);option(m,'FontColor',c);show(m,true)
end
local function rect(m,x,y,w,h,r,fill,stroke)
  option(m,'X',x);option(m,'Y',y)
  option(m,'Shape',string.format('Rectangle 0,0,%.3f,%.3f,%.3f | Fill Color %s | StrokeWidth %s | Stroke Color %s',w,h,r,fill,stroke and '1' or '0',stroke or fill))
  show(m,true)
end
local function ring(prefix,q,x,y,d,thickness,inset,c)
  local a=M.arc(q)
  local radius=d/2-inset-thickness/2
  for _,suffix in ipairs({'Track','Fill'}) do
    local meter=prefix..suffix
    option(meter,'X',x);option(meter,'Y',y);option(meter,'W',d);option(meter,'H',d)
    option(meter,'LineStart',radius-thickness/2);option(meter,'LineLength',radius+thickness/2)
    option(meter,'LineColor',suffix=='Track' and color('TrackColor','64,65,82',160) or c)
    show(meter,a.track and (suffix=='Track' or a.used>0))
  end
  option(prefix..'Value','Formula',a.used)
  SKIN:Bang('!UpdateMeasure',prefix..'Value')
  for _,cap in ipairs({'Start','End'}) do
    local angle=cap=='Start' and -math.pi/2 or a.end_angle
    option(prefix..cap,'X',x+d/2+radius*math.cos(angle)-thickness/2)
    option(prefix..cap,'Y',y+d/2+radius*math.sin(angle)-thickness/2)
    option(prefix..cap,'Shape',string.format('Ellipse %.3f,%.3f,%.3f | Fill Color %s | StrokeWidth 0',thickness/2,thickness/2,thickness/2,c))
    show(prefix..cap,a.caps)
  end
end
local function resetDate(q)
  if not q.reset_at then return nil end
  return 'Reset: '..os.date('%d.%m.%Y  %H:%M:%S  %z',q.reset_at)
end
local function detailBlock(prefix,q,title,x,y,w,s,c,now)
  local pale=color('MutedColor','157,158,177')
  text(prefix..'Title',title,x,y,w-90*s,22*s,10.5*s,color('TextColor','244,243,250'))
  text(prefix..'Percent',M.percent(q)..' využité',x+w,y,100*s,22*s,10.5*s,c)
  local a=M.arc(q)
  if a.track then rect(prefix..'Track',x,y+27*s,w,4*s,2*s,color('TrackColor','64,65,82')) end
  if a.used>0 then rect(prefix..'Bar',x,y+27*s,w*a.used/100,4*s,2*s,c) end
  text(prefix..'Reset',q.availability=='absent' and 'Týždenný limit nie je dostupný' or M.countdown(q,now),x,y+39*s,w,18*s,9*s,pale)
  local date=resetDate(q)
  text(prefix..'Date',date or 'Reset neodhadujeme.',x,y+57*s,w,18*s,8.7*s,pale)
  text(prefix..'Age',(mode=='LIVE' and L.freshness(q,now) or M.freshness(q,now)),x,y+76*s,w,18*s,8*s,pale)
end
local function render()
  if not data then return end
  detailShown={}
  local now=os.time()
  local s=scale
  local d=number('Diameter',140,120,180)*s
  local gap=number('CircleGap',48,24,80)*s
  local w=2*d+gap+48*s
  local base=d+96*s
  local pale=color('MutedColor','157,158,177')
  local white=color('TextColor','244,243,250')
  local purple=color('WeeklyColor','169,103,246')
  local amber=color('SessionColor','245,176,92')
  local selected=active and data[active]
  local hasEvent=events.active~=nil
  local detailUnits=0
  if selected then
    detailUnits=180
    if selected.session.availability=='present' then detailUnits=detailUnits+104
    elseif selected.session.availability=='unknown' then detailUnits=detailUnits+26 end
    if selected.error then detailUnits=detailUnits+38 end
    if mode=='LIVE' then detailUnits=detailUnits+24+#selected.extras*83+(selected.omitted>0 and 28 or 0) end
  end
  if hasEvent then detailUnits=detailUnits+96 end
  local desired=detailUnits>0 and (detailUnits+10)*s or 0
  local anchor=SKIN:GetY()+offset
  local workTop=tonumber(SKIN:GetVariable('WORKAREAY')) or 0
  local workHeight=tonumber(SKIN:GetVariable('WORKAREAHEIGHT')) or 1080
  local workX=tonumber(SKIN:GetVariable('WORKAREAX')) or 0
  local workWidth=tonumber(SKIN:GetVariable('WORKAREAWIDTH')) or 1920
  anchor=math.max(workTop,math.min(anchor,workTop+workHeight-base))
  local layout=M.layout(anchor,base,desired,workTop,workHeight)
  local newX=math.max(workX,math.min(SKIN:GetX(),workX+workWidth-w))
  offset=layout.offset
  local targetX,targetY=math.floor(newX+0.5),math.floor(anchor-offset+0.5)
  if targetX~=SKIN:GetX() or targetY~=SKIN:GetY() then
    SKIN:Bang('!Move',targetX,targetY)
  end
  lastLayout={above=layout.above,offset=offset,width=w,height=layout.height,anchor=anchor,work_top=workTop,work_height=workHeight,ratio=layout.ratio}
  option('Bounds','W',w);option('Bounds','H',layout.height)
  local y=offset
  text('Drag',mode=='DEMO' and 'DEMO  ·  presuň' or '',22*s,y+4*s,190*s,25*s,8.5*s,pale)
  text('ScaleButton',string.format('%.0f %%',scale*100),w-72*s,y+2*s,50*s,28*s,9*s,pale)
  show('ScaleButton',mode=='DEMO')
  for i,id in ipairs({'codex','claude'}) do
    local p=data[id];local x=24*s+(i-1)*(d+gap);local cy=y+34*s
    local stale=p.weekly.quality~='fresh'
    local wc=color('WeeklyColor','169,103,246',stale and 135 or 255)
    local sc=color('SessionColor','245,176,92',p.session.quality~='fresh' and 135 or 255)
    ring(id..'Weekly',p.weekly,x,cy,d,number('WeeklyThickness',8,4,12)*s,0,wc)
    ring(id..'Session',p.session,x,cy,d,number('SessionThickness',5,3,8)*s,15*s,sc)
    option(id..'Hit','X',x);option(id..'Hit','Y',cy)
    option(id..'Hit','Shape',string.format('Ellipse %.3f,%.3f,%.3f | Fill Color 0,0,0,1 | StrokeWidth 0',d/2,d/2,d/2))
    text(id..'Percent',M.percent(p.weekly),x+d/2,cy+d*0.28,d-35*s,42*s,25*s,stale and pale or white)
    text(id..'Name',id:upper(),x+d/2,cy+d*0.58,d-30*s,20*s,8.7*s,white)
    text(id..'Subtitle','týždenný limit',x+d/2,cy+d*0.73,d-30*s,20*s,7.7*s,pale)
    show(id..'Subtitle',mode=='DEMO')
    text(id..'Handle',active==id and '⌃' or '⌄',x+d/2,cy+d+1*s,90*s,28*s,16*s,pale)
    local unread=events.active and events.active.provider==id
    text(id..'Badge',unread and '●' or '!',x+d-3*s,cy+10*s,20*s,24*s,11*s,unread and purple or amber)
    show(id..'Badge',unread or stale or p.session.quality=='stale' or p.session.quality=='error')
  end
  local toolbar=y+d+68*s
  if mode=='DEMO' then
  text('Previous','‹',20*s,toolbar-5*s,34*s,28*s,18*s,pale)
  text('Scenario',string.format('%02d/%02d · %s',scenario,#F.order,F.names[F.order[scenario]] or 'Chyba'),60*s,toolbar+2*s,w-165*s,25*s,8.2*s,pale)
  text('Next','›',w-93*s,toolbar-5*s,34*s,28*s,18*s,pale)
  text('TestEvent','TEST',w-49*s,toolbar,44*s,28*s,8*s,purple)
  else
    for _,meter in ipairs({'Previous','Next','TestEvent'}) do show(meter,false);option(meter,'X',0);option(meter,'Y',0) end
    show('Scenario',false);option('Scenario','X',0);option('Scenario','Y',0)
  end
  if detailUnits>0 and layout.ratio>0 then
    local ds=s*layout.ratio;local py=layout.detail_y+5*ds
    local ph=detailUnits*ds
    rect('DetailBackground',1,py,w-2,ph,14*ds,color('PanelColor','21,23,33,252'),color('BorderColor','64,66,86'))
    local contentY=py
    if selected then
      text('DetailHeading',active:upper(),18*s,py+14*ds,w-74*s,24*ds,13*ds,white)
      text('DetailSubheading',mode=='DEMO' and 'DEMO · syntetické údaje' or ('LIVE · '..(selected.source or 'zdroj čaká')),18*s,py+40*ds,w-60*s,20*ds,8*ds,pale)
      show('DetailSubheading',mode=='DEMO')
      text('DetailClose','×',w-45*s,py+8*ds,32*s,34*ds,18*ds,pale)
      detailBlock('DetailWeekly',selected.weekly,'Týždenný limit · všetky modely',18*s,py+69*ds,w-36*s,ds,purple,now)
      contentY=py+169*ds
      if mode=='LIVE' then
        local message=selected.identity_known and 'Účet rozlíšený zdrojom' or 'Zdroj neuvádza identitu účtu'
        text('DetailIdentity',message,18*s,contentY,w-36*s,22*ds,8*ds,pale)
        contentY=contentY+24*ds
      end
      if selected.session.availability=='present' then
        detailBlock('DetailSession',selected.session,'5-hodinový limit',18*s,contentY,w-36*s,ds,amber,now)
        contentY=contentY+104*ds
      elseif selected.session.availability=='unknown' then
        text('DetailUncertain','5h: dostupnosť neoverená',18*s,contentY,w-36*s,24*ds,8.5*ds,pale)
        contentY=contentY+26*ds
      end
      if mode=='LIVE' and #selected.extras>0 then
        local lines={}
        for _,extra in ipairs(selected.extras) do
          lines[#lines+1]=extra.title..': '..M.percent(extra.quota)..' využité'
          lines[#lines+1]=M.countdown(extra.quota,now)
          lines[#lines+1]=resetDate(extra.quota) or 'Čas resetu nie je známy'
          lines[#lines+1]=''
        end
        text('DetailExtra',table.concat(lines,'\n'),18*s,contentY,w-36*s,#selected.extras*83*ds,9*ds,pale)
        contentY=contentY+#selected.extras*83*ds
      end
      if mode=='LIVE' and selected.omitted>0 then
        text('DetailOmitted','Ďalšie kvóty: pozri Win-CodexBar ('..selected.omitted..')',18*s,contentY,w-36*s,26*ds,8*ds,pale)
        contentY=contentY+28*ds
      end
      if selected.error then
        text('DetailError',selected.error,18*s,contentY,w-36*s,36*ds,8.2*ds,amber)
        contentY=contentY+38*ds
      end
    end
    if hasEvent then
      local ey=selected and contentY+4*ds or py+12*ds
      text('EventTitle','TEST / DEMO · '..events.active.provider:upper(),18*s,ey,w-36*s,24*ds,9.5*ds,purple)
      text('EventBody','Syntetická udalosť. Nejde o skutočný reset.',18*s,ey+25*ds,w-36*s,20*ds,8.5*ds,pale)
      text('EventAck','Potvrdiť',18*s,ey+50*ds,105*s,30*ds,9*ds,white)
    end
  end
  -- Hide only unused meters, without hiding/recreating the whole card each tick.
  -- Rainmeter 4.5 also counts positions of hidden meters in its window size.
  for _,meter in ipairs(detailMeters) do
    if not detailShown[meter] then show(meter,false);option(meter,'X',0);option(meter,'Y',0) end
  end
  SKIN:Bang('!UpdateMeter','*');SKIN:Bang('!Redraw')
end
function LoadScenario(key)
  if mode~='DEMO' then return end
  local selectedIndex
  for i,id in ipairs(F.order) do if id==key then selectedIndex=i end end
  if not selectedIndex then key='invalid';selectedIndex=#F.order end
  scenario=selectedIndex;serial=serial+1
  local ok,raw=pcall(F.build,key,os.time(),serial)
  if not ok then raw={codex={},claude={}} end
  data={}
  for _,id in ipairs({'codex','claude'}) do
    local p=raw[id] or {}
    data[id]={weekly=M.quota(p.weekly),session=M.quota(p.session),error=p.error}
  end
  data.anchor=raw.anchor
  if raw.event then M.receive_event(events,raw.event) end
  render();CaptureState()
end
function Step(direction) if mode~='DEMO' then return end;local index=(scenario-1+direction)%#F.order+1;LoadScenario(F.order[index]) end
function Toggle(id)
  if id~='codex' and id~='claude' then return end
  if active==id then active=nil else active=id end
  render();CaptureState()
end
function Close() active=nil;render();CaptureState() end
function SetScale(value) scale=math.max(0.75,math.min(1.5,tonumber(value) or 1));render();CaptureState() end
function ToggleScale() SetScale(scale==1 and 1.5 or 1) end
function TestEvent()
  if mode~='DEMO' then return end
  serial=serial+1;M.receive_event(events,{event_id='demo-'..os.time()..'-'..serial,provider=active or 'codex'})
  render();CaptureState()
end
function Acknowledge() M.acknowledge(events);render();CaptureState() end
function Initialize()
  root=SKIN:GetVariable('@')
  M=dofile(root..'Model.lua');events=M.event_state()
  mode=SKIN:GetVariable('Mode','DEMO')
  if mode=='DEMO' then F=dofile(root..'Fixtures.lua') else mode='LIVE';L=dofile(root..'Live.lua') end
  scale=number('Scale',1,0.75,1.5)
  if mode=='DEMO' then LoadScenario(SKIN:GetVariable('InitialScenario','normal')) else CollectionFinished(true) end
end
function CollectionFinished(initial)
  if mode~='LIVE' then return end
  collectingUntil=0
  local snapshot=L.read(root..'State\\snapshot.txt')
  if snapshot then liveSnapshot=snapshot end
  local now=os.time()
  nextCollect=now+number('RefreshSeconds',180,180,3600)
  for _,id in ipairs({'codex','claude'}) do
    local due=liveSnapshot and tonumber(liveSnapshot[id..'.next_at'])
    if due and due>now then nextCollect=math.min(nextCollect,due) end
    if initial and (not due or due<=now) then nextCollect=now end
  end
  data=L.data(liveSnapshot,M,os.time(),not snapshot);render()
end
function Update()
  if mode=='LIVE' then
    local now=os.time()
    local snapshot=L.read(root..'State\\snapshot.txt')
    if snapshot then liveSnapshot=snapshot end
    data=L.data(liveSnapshot,M,now,not snapshot)
    if now>=nextCollect and now>=collectingUntil then
      nextCollect=now+number('RefreshSeconds',180,180,3600);collectingUntil=now+90
      SKIN:Bang('!CommandMeasure','Collector','Run')
    end
  end
  render();return 0
end
-- Explicit local diagnostics for native QA, never written on every redraw.
function CaptureState()
  if not root or not data then return end
  local file=io.open(root..'State\\inspection.txt','w')
  if not file then return end
  local function put(k,v) file:write(k..'='..tostring(v)..'\n') end
  put('mode',mode);put('scenario',mode=='DEMO' and F.order[scenario] or 'live');put('active',active or 'none');put('scale',scale)
  for _,meter in ipairs({'Drag','ScaleButton','Scenario','Previous','Next','TestEvent','codexSubtitle','claudeSubtitle','DetailSubheading'}) do
    put('ui.'..meter..'.hidden',opts[meter..':Hidden'] or 'unknown')
  end
  put('ui.Drag.empty',opts['Drag:Text']=='')
  put('window.x',SKIN:GetX());put('window.y',SKIN:GetY());put('window.w',SKIN:GetW());put('window.h',SKIN:GetH())
  put('anchor',data.anchor);put('announcements',events.announcements);put('event_unread',events.active~=nil)
  for k,v in pairs(lastLayout) do put('layout.'..k,v) end
  for _,id in ipairs({'codex','claude'}) do
    for _,kind in ipairs({'weekly','session'}) do
      local q=data[id][kind];put(id..'.'..kind..'.used',q.used or 'unknown')
      put(id..'.'..kind..'.availability',q.availability);put(id..'.'..kind..'.quality',q.quality)
      put(id..'.'..kind..'.reset',q.reset_at or 'unknown')
    end
  end
  file:close()
end
function RunTests()
  if mode~='DEMO' then return end
  local runner=dofile(root..'Tests\\demo_spec.lua')
  local report=runner(M,F)
  local liveRunner=dofile(root..'Tests\\live_spec.lua')
  report=report..liveRunner(M,dofile(root..'Live.lua'))
  local file=assert(io.open(root..'State\\test-results.txt','w'))
  file:write(report);file:close()
end
