-- Runs under Rainmeter's actual Lua 5.1 interpreter, no external test framework.
return function(M,F)
  local lines,passed,failed={},0,0
  local function test(name,fn)
    local ok,err=pcall(fn)
    if ok then passed=passed+1;lines[#lines+1]='PASS '..name
    else failed=failed+1;lines[#lines+1]='FAIL '..name..': '..tostring(err) end
  end
  local function eq(a,b) assert(a==b,tostring(a)..' ~= '..tostring(b)) end
  local function quota(n) return M.quota({availability='present',quality='fresh',used=n,observed_at=1000,reset_at=2000}) end
  for _,p in ipairs({0,25,50,65,100}) do
    test('arc '..p..' percent: clockwise / degrees / caps',function()
      local a=M.arc(quota(p));eq(a.track,true);assert(math.abs(a.degrees-p*3.6)<0.00001)
      eq(a.caps,p>0 and p<100);assert(math.abs(a.end_angle-(-math.pi/2+p/100*2*math.pi))<0.00001)
    end)
  end
  for i,raw in ipairs({{}, {used=0}, {availability='present'}, {availability='present',used='0'}, {availability='present',used=-1}, {availability='present',used=101}, {availability='present',used=0/0}, {availability='present',used=math.huge}}) do
    test('invalid/missing input '..i..' is not zero',function() local q=M.quota(raw);eq(M.percent(q),'—');eq(M.arc(q).track,false) end)
  end
  test('valid zero keeps track, no fill caps',function() local q=quota(0);eq(M.percent(q),'0%');eq(M.arc(q).caps,false);eq(M.arc(q).track,true) end)
  test('absent quota has no track even with prior value',function() local q=M.quota({availability='absent'},quota(65));eq(q.availability,'absent');eq(M.arc(q).track,false) end)
  test('failed refresh retains prior value and reset',function() local q=M.quota({availability='unknown',quality='error'},quota(65));eq(q.used,65);eq(q.reset_at,2000);eq(q.quality,'error');eq(q.availability_uncertain,true) end)
  test('unknown 5h without history is uncertain',function() eq(M.quota({availability='unknown'}).availability,'unknown') end)
  test('unknown observation time is not fresh',function() eq(M.quota({availability='present',used=25,quality='fresh'}).quality,'unknown') end)
  test('weekly missing never uses session',function() local d=F.build('weeklyMissing',1000,1);eq(M.percent(M.quota(d.codex.weekly)),'—');eq(d.codex.session.used,65) end)
  test('normal Codex has no 5h, Claude has 65 percent',function() local d=F.build('normal',1000,1);eq(d.codex.session.availability,'absent');eq(d.claude.session.used,65) end)
  test('Codex supports a present zero 5h',function() local d=F.build('codex5hzero',1000,1);eq(M.arc(M.quota(d.codex.session)).track,true);eq(d.codex.session.used,0) end)
  test('reset anchored once and not moved by countdown',function() local d=F.build('resetDue',1000,1);local q=M.quota(d.codex.weekly);eq(q.reset_at,1005);M.countdown(q,1003);eq(q.reset_at,1005);eq(q.used,65) end)
  test('expired reset retains percent',function() local q=quota(65);eq(M.countdown(q,2001),'Čaká na nový údaj po resete');eq(q.used,65) end)
  test('unknown reset is not estimated',function() eq(M.countdown(M.quota({availability='present',used=25}),1000),'Čas resetu nie je známy') end)
  test('one service failure does not change the other',function() local d=F.build('stale',1000,1);eq(d.codex.weekly.quality,'stale');eq(d.codex.weekly.used,65);eq(d.claude.weekly.quality,'error');eq(d.claude.session.used,65) end)
  test('all fixtures have exactly the two DEMO providers',function() for _,key in ipairs(F.order) do local d=F.build(key,1000,1);assert(d.codex and d.claude);assert(not d.codex.account and not d.claude.account) end end)
  for _,s in ipairs({1,1.5}) do
    test('layout below, scale '..s,function() local l=M.layout(100,236*s,286*s,0,1080);eq(l.above,false);eq(l.offset,0);eq(l.height,522*s) end)
    test('layout above preserves ring anchor, scale '..s,function() local anchor=1080-236*s-20;local l=M.layout(anchor,236*s,286*s,0,1080);eq(l.above,true);eq((anchor-l.offset)+l.offset,anchor);assert(anchor-l.offset>=0);assert(anchor+236*s<=1080) end)
  end
  test('negative-origin monitor stays in its work area',function() local l=M.layout(-400,236,286,-1080,1080);eq(l.above,true);assert(-400-l.offset>=-1080) end)
  test('close panel shrinks entire window',function() local l=M.layout(500,236,0,0,1080);eq(l.height,236);eq(l.offset,0) end)
  test('tight work area compacts detail only',function() local l=M.layout(300,354,429,0,850);assert(l.ratio<1 and l.ratio>0);eq(l.height-l.offset,354) end)
  test('same event ID deduplicates through redraw/ack',function()
    local state=M.event_state();local e={event_id='demo-test-1',provider='codex'}
    eq(M.receive_event(state,e),true);for i=1,25 do eq(M.receive_event(state,e),false) end
    M.acknowledge(state);eq(state.active,nil);eq(M.receive_event(state,e),false);eq(state.announcements,1)
    eq(M.receive_event(state,{event_id='demo-test-2',provider='claude'}),true);eq(state.announcements,2)
  end)
  test('host OS local timezone roundtrip winter/summer',function()
    for _,month in ipairs({1,7}) do
      local epoch=os.time({year=2026,month=month,day=15,hour=12,min=0,sec=0})
      local localtime=os.date('*t',epoch);eq(localtime.hour,12);eq(localtime.month,month)
    end
  end)
  table.insert(lines,1,string.format('DEMO Lua %s: %d PASS, %d FAIL',_VERSION,passed,failed))
  lines[#lines+1]='INFO OS local winter: '..os.date('%Y-%m-%d %H:%M %z',os.time({year=2026,month=1,day=15,hour=12,min=0,sec=0}))
  lines[#lines+1]='INFO OS local summer: '..os.date('%Y-%m-%d %H:%M %z',os.time({year=2026,month=7,day=15,hour=12,min=0,sec=0}))
  return table.concat(lines,'\n')..'\n'
end
